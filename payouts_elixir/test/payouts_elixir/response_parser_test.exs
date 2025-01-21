defmodule PayoutsElixir.ResponseParserTest do
  use ExUnit.Case
  alias PayoutsElixir.ResponseParser

  # Verification Response Tests
  describe "parse_verification_response/1" do
    test "parses successful verification with all fields present" do
      xml = """
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <Response>
        <Result>OK</Result>
        <BatchCode>34477</BatchCode>
        <TotalFeeExcludingVAT>3.95</TotalFeeExcludingVAT>
        <UniqueId>ae62d9d7-0166-4dc0-a8d8-875286665683</UniqueId>
        <BanvResults>
          <Result>
            <AccountNumber>123456789101</AccountNumber>
            <IDNumber>5511255173005</IDNumber>
            <Initials>JS</Initials>
            <Name>John Smith</Name>
            <Reference>REF123</Reference>
            <Flags>YYNNYYYY</Flags>
            <Result>Valid account</Result>
          </Result>
        </BanvResults>
        <CDVResults>
          <Result>
            <AccountNumber>123456789101</AccountNumber>
            <BranchCode>632005</BranchCode>
            <CustomerCode>12345</CustomerCode>
            <Reference>REF123</Reference>
            <Result>Valid</Result>
          </Result>
        </CDVResults>
      </Response>
      """

      result = ResponseParser.parse_verification_response(xml)

      assert result.result == "OK"
      assert result.batch_code == "34477"
      assert result.fee == "3.95"
      assert result.unique_id == "ae62d9d7-0166-4dc0-a8d8-875286665683"

      [banv] = result.banv_results
      assert banv.account_number == "123456789101"
      assert banv.id_number == "5511255173005"
      assert banv.initials == "JS"
      assert banv.name == "John Smith"
      assert banv.reference == "REF123"
      assert banv.flags == "YYNNYYYY"
      assert banv.result == "Valid account"

      [cdv] = result.cdv_results
      assert cdv.account_number == "123456789101"
      assert cdv.branch_code == "632005"
      assert cdv.customer_code == "12345"
      assert cdv.reference == "REF123"
      assert cdv.result == "Valid"
    end

    test "parses verification with multiple BANV results" do
      xml = """
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <Response>
        <Result>OK</Result>
        <BatchCode>34477</BatchCode>
        <BanvResults>
          <Result>
            <AccountNumber>111</AccountNumber>
            <Result>Valid</Result>
          </Result>
          <Result>
            <AccountNumber>222</AccountNumber>
            <Result>Invalid</Result>
          </Result>
        </BanvResults>
      </Response>
      """

      result = ResponseParser.parse_verification_response(xml)
      assert length(result.banv_results) == 2
      assert Enum.at(result.banv_results, 0).account_number == "111"
      assert Enum.at(result.banv_results, 1).account_number == "222"
    end

    test "handles verification error response" do
      xml = """
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <Response>
        <Result>Error</Result>
        <BatchCode></BatchCode>
      </Response>
      """

      result = ResponseParser.parse_verification_response(xml)
      assert result.result == "Error"
      assert result.batch_code == ""
      assert result.banv_results == []
      assert result.cdv_results == []
    end
  end

  # Realtime Verification Response Tests
  describe "parse_realtime_verification_response/1" do
    test "parses successful realtime verification" do
      xml = """
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <Response>
        <Result>OK</Result>
        <BatchCode>35308</BatchCode>
        <TotalFeeExcludingVAT>3.95</TotalFeeExcludingVAT>
        <UniqueId>12345678</UniqueId>
        <BanvRealtimeResult>
          <AccountNumber>1234567890</AccountNumber>
          <AccountType>1</AccountType>
          <Flags>YYNNYYYY</Flags>
          <IDNumber>5511255173005</IDNumber>
          <Initials>JS</Initials>
          <Name>John Smith</Name>
          <Reference>REF123</Reference>
          <Result>Valid account</Result>
          <ResultMessage>Account verified</ResultMessage>
        </BanvRealtimeResult>
        <CDVResults>
          <Result>
            <AccountNumber>1234567890</AccountNumber>
            <BranchCode>632005</BranchCode>
            <CustomerCode>12345</CustomerCode>
            <Reference>REF123</Reference>
            <Result>Valid</Result>
            <Message>Success</Message>
          </Result>
        </CDVResults>
      </Response>
      """

      result = ResponseParser.parse_realtime_verification_response(xml)

      assert result.result == "OK"
      assert result.batch_code == "35308"
      assert result.fee == "3.95"
      assert result.unique_id == "12345678"

      banv = result.banv_realtime_result
      assert banv.account_number == "1234567890"
      assert banv.account_type == "1"
      assert banv.flags == "YYNNYYYY"
      assert banv.result_message == "Account verified"

      [cdv] = result.cdv_results
      assert cdv.account_number == "1234567890"
      assert cdv.message == "Success"
    end

    test "handles missing optional fields in realtime verification" do
      xml = """
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <Response>
        <Result>OK</Result>
        <BanvRealtimeResult>
          <AccountNumber>1234567890</AccountNumber>
          <Result>Valid</Result>
        </BanvRealtimeResult>
      </Response>
      """

      result = ResponseParser.parse_realtime_verification_response(xml)

      assert result.result == "OK"
      assert result.banv_realtime_result.account_number == "1234567890"
      assert result.banv_realtime_result.result == "Valid"
      assert result.banv_realtime_result.result_message == nil
      assert result.cdv_results == []
    end
  end

  # CDV Response Tests
  describe "parse_cdv_response/1" do
    test "parses successful CDV response" do
      xml = """
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <Response>
        <Result>OK</Result>
        <BatchCode>12345</BatchCode>
        <TotalFeeExcludingVAT>0.00</TotalFeeExcludingVAT>
        <CDVResults>
          <Result>
            <AccountNumber>62553059942</AccountNumber>
            <BranchCode>211020</BranchCode>
            <Result>Valid</Result>
          </Result>
        </CDVResults>
      </Response>
      """

      result = ResponseParser.parse_cdv_response(xml)

      assert result.result == "OK"
      assert result.batch_code == "12345"
      assert result.fee == "0.00"

      [cdv] = result.cdv_results
      assert cdv.account_number == "62553059942"
      assert cdv.branch_code == "211020"
      assert cdv.result == "Valid"
    end

    test "parses multiple CDV results" do
      xml = """
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <Response>
        <Result>OK</Result>
        <CDVResults>
          <Result>
            <AccountNumber>111</AccountNumber>
            <BranchCode>123</BranchCode>
            <Result>Valid</Result>
          </Result>
          <Result>
            <AccountNumber>222</AccountNumber>
            <BranchCode>456</BranchCode>
            <Result>Invalid</Result>
          </Result>
        </CDVResults>
      </Response>
      """

      result = ResponseParser.parse_cdv_response(xml)
      assert length(result.cdv_results) == 2
      assert Enum.at(result.cdv_results, 0).account_number == "111"
      assert Enum.at(result.cdv_results, 1).account_number == "222"
    end
  end

  # Payment Response Tests
  describe "parse_payment_response/1" do
    test "parses successful payment response" do
      xml = """
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <Response>
        <Result>OK</Result>
        <BatchCode>30104</BatchCode>
        <BatchValueSubmitted>300.00</BatchValueSubmitted>
        <TotalFeeExcludingVAT>0.00</TotalFeeExcludingVAT>
        <UniqueId>f86d4274-5ee2-4cd3-b97b-e6db8f892635</UniqueId>
        <PaymentResults>
          <Result>
            <AccountNumber>123456789</AccountNumber>
            <BranchCode>632005</BranchCode>
            <FirstName>Example</FirstName>
            <Surname>User</Surname>
            <Reference>SALARY</Reference>
            <CustomerCode>000001</CustomerCode>
            <Result>Accepted</Result>
            <ResultMessage>Payment scheduled</ResultMessage>
          </Result>
        </PaymentResults>
        <CDVResults>
          <Result>
            <AccountNumber>123456789</AccountNumber>
            <BranchCode>632005</BranchCode>
            <CustomerCode>000001</CustomerCode>
            <Reference>SALARY</Reference>
            <Result>Valid</Result>
          </Result>
        </CDVResults>
      </Response>
      """

      result = ResponseParser.parse_payment_response(xml)

      assert result.result == "OK"
      assert result.batch_code == "30104"
      assert result.batch_value == "300.00"
      assert result.fee == "0.00"
      assert result.unique_id == "f86d4274-5ee2-4cd3-b97b-e6db8f892635"

      [payment] = result.payment_results
      assert payment.account_number == "123456789"
      assert payment.first_name == "Example"
      assert payment.surname == "User"
      assert payment.result == "Accepted"
      assert payment.result_message == "Payment scheduled"

      [cdv] = result.cdv_results
      assert cdv.account_number == "123456789"
      assert cdv.branch_code == "632005"
      assert cdv.result == "Valid"
    end

    test "parses payment error response" do
      xml = """
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <Response>
        <Result>Error</Result>
        <PaymentResults>
          <Result>
            <AccountNumber>123456789</AccountNumber>
            <Result>Rejected</Result>
            <ResultMessage>ACCOUNT CLOSED</ResultMessage>
          </Result>
        </PaymentResults>
      </Response>
      """

      result = ResponseParser.parse_payment_response(xml)
      assert result.result == "Error"
      [payment] = result.payment_results
      assert payment.result == "Rejected"
      assert payment.result_message == "ACCOUNT CLOSED"
    end

    test "parses multiple payment results" do
      xml = """
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <Response>
        <Result>OK</Result>
        <PaymentResults>
          <Result>
            <AccountNumber>111</AccountNumber>
            <Result>Accepted</Result>
          </Result>
          <Result>
            <AccountNumber>222</AccountNumber>
            <Result>Rejected</Result>
          </Result>
        </PaymentResults>
      </Response>
      """

      result = ResponseParser.parse_payment_response(xml)
      assert length(result.payment_results) == 2
      assert Enum.at(result.payment_results, 0).account_number == "111"
      assert Enum.at(result.payment_results, 1).account_number == "222"
    end
  end
end

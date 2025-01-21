defmodule PayoutsElixir.ResponseParserTest do
  use ExUnit.Case
  alias PayoutsElixir.ResponseParser

  @verification_response """
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

  @payment_response """
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

  describe "parse_verification_response/1" do
    test "parses successful verification response" do
      result = ResponseParser.parse_verification_response(@verification_response)

      assert result.result == "OK"
      assert result.batch_code == "34477"
      assert result.fee == "3.95"
      assert result.unique_id == "ae62d9d7-0166-4dc0-a8d8-875286665683"

      [banv_result] = result.banv_results
      assert banv_result.account_number == "123456789101"
      assert banv_result.id_number == "5511255173005"
      assert banv_result.flags == "YYNNYYYY"

      [cdv_result] = result.cdv_results
      assert cdv_result.account_number == "123456789101"
      assert cdv_result.branch_code == "632005"
      assert cdv_result.result == "Valid"
    end
  end

  describe "parse_payment_response/1" do
    test "parses successful payment response" do
      result = ResponseParser.parse_payment_response(@payment_response)

      assert result.result == "OK"
      assert result.batch_code == "30104"
      assert result.batch_value == "300.00"
      assert result.unique_id == "f86d4274-5ee2-4cd3-b97b-e6db8f892635"

      [payment_result] = result.payment_results
      assert payment_result.account_number == "123456789"
      assert payment_result.first_name == "Example"
      assert payment_result.surname == "User"
      assert payment_result.result == "Accepted"

      [cdv_result] = result.cdv_results
      assert cdv_result.account_number == "123456789"
      assert cdv_result.branch_code == "632005"
      assert cdv_result.result == "Valid"
    end
  end

  # Add more test cases for other response types...
end

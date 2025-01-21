defmodule PayoutsElixir.ResponseParser do
  import SweetXml

  def parse_verification_response(xml_string) do
    xml_string
    |> xpath(~x"//Response",
      result: ~x"./Result/text()"s,
      batch_code: ~x"./BatchCode/text()"s,
      fee: ~x"./TotalFeeExcludingVAT/text()"s,
      unique_id: ~x"./UniqueId/text()"s,
      banv_results: [
        ~x"./BanvResults/Result"l,
        account_number: ~x"./AccountNumber/text()"s,
        id_number: ~x"./IDNumber/text()"s,
        initials: ~x"./Initials/text()"s,
        name: ~x"./Name/text()"s,
        reference: ~x"./Reference/text()"s,
        flags: ~x"./Flags/text()"s,
        result: ~x"./Result/text()"s
      ],
      cdv_results: [
        ~x"./CDVResults/Result"l,
        account_number: ~x"./AccountNumber/text()"s,
        branch_code: ~x"./BranchCode/text()"s,
        customer_code: ~x"./CustomerCode/text()"s,
        reference: ~x"./Reference/text()"s,
        result: ~x"./Result/text()"s
      ]
    )
  end

  def parse_realtime_verification_response(xml_string) do
    xml_string
    |> xpath(~x"//Response",
      result: ~x"./Result/text()"s,
      batch_code: ~x"./BatchCode/text()"s,
      fee: ~x"./TotalFeeExcludingVAT/text()"s,
      unique_id: ~x"./UniqueId/text()"s,
      banv_realtime_result: [
        ~x"./BanvRealtimeResult",
        account_number: ~x"./AccountNumber/text()"s,
        account_type: ~x"./AccountType/text()"s,
        flags: ~x"./Flags/text()"s,
        id_number: ~x"./IDNumber/text()"s,
        initials: ~x"./Initials/text()"s,
        name: ~x"./Name/text()"s,
        reference: ~x"./Reference/text()"s,
        result: ~x"./Result/text()"s,
        result_message: ~x"./ResultMessage/text()"o
      ],
      cdv_results: [
        ~x"./CDVResults/Result"l,
        account_number: ~x"./AccountNumber/text()"s,
        branch_code: ~x"./BranchCode/text()"s,
        customer_code: ~x"./CustomerCode/text()"s,
        reference: ~x"./Reference/text()"s,
        result: ~x"./Result/text()"s,
        message: ~x"./Message/text()"o
      ]
    )
  end

  def parse_cdv_response(xml_string) do
    xml_string
    |> xpath(~x"//Response",
      result: ~x"./Result/text()"s,
      batch_code: ~x"./BatchCode/text()"s,
      fee: ~x"./TotalFeeExcludingVAT/text()"s,
      cdv_results: [
        ~x"./CDVResults/Result"l,
        account_number: ~x"./AccountNumber/text()"s,
        branch_code: ~x"./BranchCode/text()"s,
        result: ~x"./Result/text()"s
      ]
    )
  end

  def parse_payment_response(xml_string) do
    xml_string
    |> xpath(~x"//Response",
      result: ~x"./Result/text()"s,
      batch_code: ~x"./BatchCode/text()"s,
      batch_value: ~x"./BatchValueSubmitted/text()"s,
      fee: ~x"./TotalFeeExcludingVAT/text()"s,
      unique_id: ~x"./UniqueId/text()"s,
      payment_results: [
        ~x"./PaymentResults/Result"l,
        account_number: ~x"./AccountNumber/text()"s,
        branch_code: ~x"./BranchCode/text()"s,
        first_name: ~x"./FirstName/text()"s,
        surname: ~x"./Surname/text()"s,
        reference: ~x"./Reference/text()"s,
        customer_code: ~x"./CustomerCode/text()"s,
        result: ~x"./Result/text()"s,
        result_message: ~x"./ResultMessage/text()"s
      ],
      cdv_results: [
        ~x"./CDVResults/Result"l,
        account_number: ~x"./AccountNumber/text()"s,
        branch_code: ~x"./BranchCode/text()"s,
        customer_code: ~x"./CustomerCode/text()"s,
        reference: ~x"./Reference/text()"s,
        result: ~x"./Result/text()"s
      ]
    )
  end
end

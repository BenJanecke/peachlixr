defmodule PayoutsElixir.RequestBuilder do
  import XmlBuilder
  alias PayoutsElixir.Structs.{VerificationRequest, PaymentRequest, CDVRequest, PaymentDetails}

  def build_verification_xml(%VerificationRequest{} = request) do
    element("APIVerificationRequest", [
      build_header(request.base_request),
      element("Records", [
        element("FileContents", [
          element("AccountNumber", request.account_number),
          element("BranchCode", request.branch_code),
          element("IdNumber", request.id_number),
          element("Initials", request.initials),
          element("Name", request.name),
          element("Reference", request.reference || generate_reference())
        ])
      ]),
      build_totals(request, :verification)
    ])
    |> XmlBuilder.generate()
  end

  def build_verification_xml(params), do: params |> VerificationRequest.new() |> build_verification_xml()

  def build_realtime_verification_xml(params) do
    element("APIRealTimeVerificationRequest", [
      build_header(params),
      element("Records", [
        element("FileContents", [
          element("Name", params[:name]),
          element("IdNumber", params[:id_number]),
          element("AccountNumber", params.account_number),
          element("Reference", params[:reference] || generate_reference()),
          element("BranchCode", params.branch_code)
        ])
      ]),
      build_totals(params, :verification)
    ])
    |> XmlBuilder.generate()
  end

  def build_cdv_xml(params) do
    element("APICDVRequest", [
      build_header(params),
      element("Records", [
        element("FileContents", [
          element("AccountNumber", params.account_number),
          element("BranchCode", params.branch_code)
        ])
      ]),
      build_totals(params)
    ])
    |> XmlBuilder.generate()
  end

  def build_payment_xml(%PaymentRequest{} = request) do
    element("APIPaymentsRequest", [
      build_header(request.base_request),
      element("Payments", [
        for payment <- request.payments do
          element("FileContents", build_payment_details(payment))
        end
      ]),
      build_totals(request, :payment)
    ])
    |> XmlBuilder.generate()
  end

  def build_payment_xml(params), do: params |> PaymentRequest.new() |> build_payment_xml()

  defp build_header(params) do
    base = [
      element("PsVer", "2.0.1"),
      element("Client", params.client_code)
    ]

    optional = [
      {:callback_url, "CallbackUrl"},
      {:service, "Service"},
      {:service_type, "ServiceType"},
      {:due_date, "DueDate"},
      {:reference, "Reference"}
    ]
    |> Enum.map(fn {key, xml_key} ->
      if params[key], do: element(xml_key, params[key])
    end)
    |> Enum.reject(&is_nil/1)

    element("Header", base ++ optional ++ [element("UniqueId", generate_uuid())])
  end

  defp build_account_details(params) do
    [
      element("AccountNumber", params.account_number),
      element("BranchCode", params.branch_code),
      element("IdNumber", params[:id_number]),
      element("Name", params[:name]),
      element("Reference", params[:reference] || generate_reference())
    ]
  end

  defp build_payment_details(%PaymentDetails{} = payment) do
    [
      element("Initial", payment.initial),
      element("FirstName", payment.first_name),
      element("Surname", payment.surname),
      element("BranchCode", payment.branch_code),
      element("AccountNumber", payment.account_number),
      element("FileAmount", payment.amount),
      element("AccountType", payment.account_type),
      element("AmountMultiplier", payment.amount_multiplier),
      element("Reference", payment.reference || generate_reference())
    ]
  end

  defp build_totals(params, type \\ nil) do
    base = [
      element("Records", length(List.wrap(params[:payments] || [params]))),
      element("BranchHash", calculate_branch_hash(params)),
      element("AccountHash", calculate_account_hash(params))
    ]

    amount = if type == :payment, do: [element("Amount", calculate_total_amount(params))], else: []

    element("Totals", base ++ amount)
  end

  defp calculate_branch_hash(params) do
    params
    |> get_all_records()
    |> Enum.map(& &1.branch_code)
    |> Enum.sum()
    |> to_string()
  end

  defp calculate_account_hash(params) do
    params
    |> get_all_records()
    |> Enum.map(& &1.account_number)
    |> Enum.sum()
    |> to_string()
  end

  defp calculate_total_amount(params) do
    params
    |> get_all_records()
    |> Enum.map(& &1.amount)
    |> Enum.sum()
    |> to_string()
  end

  defp get_all_records(params) do
    List.wrap(params[:payments] || [params])
  end

  defp generate_reference do
    "REF#{System.system_time(:second)}"
  end

  defp generate_uuid do
    UUID.uuid4()
  end
end

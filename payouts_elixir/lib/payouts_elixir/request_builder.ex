defmodule PayoutsElixir.RequestBuilder do
  import XmlBuilder

  def build_verification_xml(params) do
    element(:APIVerificationRequest, [
      build_header(params),
      element(:Records, [
        element(:FileContents, [
          element(:AccountNumber, params.account_number),
          element(:BranchCode, params.branch_code),
          element(:IdNumber, params[:id_number]),
          element(:Initials, params[:initials]),
          element(:Name, params[:name]),
          element(:Reference, params[:reference] || generate_reference())
        ])
      ]),
      build_totals(params, :verification)
    ])
    |> XmlBuilder.generate
  end

  def build_realtime_verification_xml(params) do
    element(:APIRealTimeVerificationRequest, [
      build_header(params),
      element(:Records, [
        element(:FileContents, [
          element(:Name, params[:name]),
          element(:IdNumber, params[:id_number]),
          element(:AccountNumber, params.account_number),
          element(:Reference, params[:reference] || generate_reference()),
          element(:BranchCode, params.branch_code)
        ])
      ]),
      build_totals(params, :verification)
    ])
    |> XmlBuilder.generate
  end

  def build_cdv_xml(params) do
    element(:APICDVRequest, [
      build_header(params),
      element(:Records, [
        element(:FileContents, [
          element(:AccountNumber, params.account_number),
          element(:BranchCode, params.branch_code)
        ])
      ]),
      build_totals(params)
    ])
    |> XmlBuilder.generate
  end

  def build_payment_xml(params) do
    element(:APIPaymentsRequest, [
      build_header(params),
      element(:Payments, [
        element(:FileContents, [
          build_payment_details(params)
        ])
      ]),
      build_totals(params, :payment)
    ])
    |> XmlBuilder.generate
  end

  defp build_header(params) do
    base = [
      element(:PsVer, "2.0.1"),
      element(:Client, params.client_code),
      element(:Reference, params[:reference] || generate_reference())
    ]

    optional = [
      callback_url: :CallBackUrl,
      service: :Service,
      service_type: :ServiceType,
      due_date: :DueDate
    ]
    |> Enum.map(fn {key, xml_key} ->
      if params[key], do: element(xml_key, params[key])
    end)
    |> Enum.reject(&is_nil/1)

    element(:Header, base ++ optional ++ [element(:UniqueId, generate_uuid())])
  end

  defp build_account_details(params) do
    [
      element(:AccountNumber, params.account_number),
      element(:BranchCode, params.branch_code),
      element(:IdNumber, params[:id_number]),
      element(:Name, params[:name]),
      element(:Reference, params[:reference] || generate_reference())
    ]
  end

  defp build_payment_details(params) do
    [
      element(:Initial, params[:initial]),
      element(:FirstName, params[:first_name]),
      element(:Surname, params[:surname]),
      element(:BranchCode, params.branch_code),
      element(:AccountNumber, params.account_number),
      element(:FileAmount, params.amount),
      element(:AccountType, params[:account_type] || 0),
      element(:AmountMultiplier, params[:amount_multiplier] || 1),
      element(:Reference, params[:reference] || generate_reference())
    ]
  end

  defp build_totals(params, type \\ nil) do
    base = [
      element(:Records, 1),
      element(:BranchHash, params.branch_code),
      element(:AccountHash, params.account_number)
    ]

    amount = if type == :payment, do: [element(:Amount, params.amount)], else: []

    element(:Totals, base ++ amount)
  end

  defp generate_reference do
    "REF#{System.system_time(:second)}"
  end

  defp generate_uuid do
    UUID.uuid4()
  end
end

defmodule PayoutsElixir do
  alias PayoutsElixir.{RequestBuilder, ResponseParser}

  @api_url "https://test.peachpay.co.za/API"

  def verify_bank(params) do
    with {:ok, request_body} <- RequestBuilder.build_verification_xml(params) do
      make_request("/Verification", request_body, &ResponseParser.parse_verification_response/1)
    end
  end

  def verify_bank_realtime(params) do
    with {:ok, request_body} <- RequestBuilder.build_realtime_verification_xml(params) do
      make_request("/RealtimeVerification", request_body, &ResponseParser.parse_realtime_verification_response/1)
    end
  end

  def verify_cdv(params) do
    with {:ok, request_body} <- RequestBuilder.build_cdv_xml(params) do
      make_request("/CDV", request_body, &ResponseParser.parse_cdv_response/1)
    end
  end

  def make_payout(params) do
    with {:ok, request_body} <- RequestBuilder.build_payment_xml(params) do
      make_request("/Payments", request_body, &ResponseParser.parse_payment_response/1)
    end
  end

  defp make_request(endpoint, body, parser_fn) do
    url = @api_url <> endpoint

    form = [
      {:request, body}
    ]

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    case HTTPoison.post(url, {:form, form}, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        {:ok, parser_fn.(response_body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Request failed with status #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{reason}"}
    end
  end
end

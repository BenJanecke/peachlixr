defmodule PayoutsElixir.RequestBuilderTest do
  use ExUnit.Case
  alias PayoutsElixir.RequestBuilder
  alias PayoutsElixir.Structs.{VerificationRequest, PaymentRequest, PaymentDetails, BaseRequest}

  describe "build_verification_xml/1" do
    test "builds minimal verification request" do
      request = %VerificationRequest{
        account_number: "1234567890",
        branch_code: "250655",
        base_request: %BaseRequest{
          client_code: "TEST01"
        }
      }

      result = RequestBuilder.build_verification_xml(request)

      assert String.contains?(result, "<APIVerificationRequest>")
      assert String.contains?(result, "<Client>TEST01</Client>")
      assert String.contains?(result, "<AccountNumber>1234567890</AccountNumber>")
      assert String.contains?(result, "<BranchCode>250655</BranchCode>")
      assert String.match?(result, ~r/<Reference>REF\d+<\/Reference>/)
      assert String.match?(result, ~r/<UniqueId>[0-9a-f-]+<\/UniqueId>/)
    end

    test "includes all optional verification fields when provided" do
      request = %VerificationRequest{
        account_number: "1234567890",
        branch_code: "250655",
        id_number: "8603015126082",
        initials: "JS",
        name: "John Smith",
        reference: "TEST123",
        service: "BANV",
        service_type: "SDV",
        callback_url: "https://example.com/callback",
        base_request: %BaseRequest{
          client_code: "TEST01"
        }
      }

      result = RequestBuilder.build_verification_xml(request)

      assert String.contains?(result, "<Service>BANV</Service>")
      assert String.contains?(result, "<ServiceType>SDV</ServiceType>")
      assert String.contains?(result, "<CallbackUrl>https://example.com/callback</CallbackUrl>")
      assert String.contains?(result, "<IdNumber>8603015126082</IdNumber>")
      assert String.contains?(result, "<Initials>JS</Initials>")
      assert String.contains?(result, "<Name>John Smith</Name>")
    end

    test "generates reference if not provided" do

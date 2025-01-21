defmodule PayoutsElixir.RequestBuilderTest do
  use ExUnit.Case
  alias PayoutsElixir.RequestBuilder

  describe "build_verification_xml/1" do
    test "builds minimal verification request" do
      params = %{
        client_code: "TEST01",
        account_number: "1234567890",
        branch_code: "250655"
      }

      result = RequestBuilder.build_verification_xml(params)

      assert String.contains?(result, "<APIVerificationRequest>")
      assert String.contains?(result, "<Client>TEST01</Client>")
      assert String.contains?(result, "<AccountNumber>1234567890</AccountNumber>")
      assert String.contains?(result, "<BranchCode>250655</BranchCode>")
      assert String.match?(result, ~r/<Reference>REF\d+<\/Reference>/)
      assert String.match?(result, ~r/<UniqueId>[0-9a-f-]+<\/UniqueId>/)
    end

    test "includes all optional verification fields when provided" do
      params = %{
        client_code: "TEST01",
        account_number: "1234567890",
        branch_code: "250655",
        id_number: "8603015126082",
        initials: "JS",
        name: "John Smith",
        reference: "TEST123",
        service: "BANV",
        service_type: "SDV",
        callback_url: "https://example.com/callback"
      }

      result = RequestBuilder.build_verification_xml(params)

      assert String.contains?(result, "<Service>BANV</Service>")
      assert String.contains?(result, "<ServiceType>SDV</ServiceType>")
      assert String.contains?(result, "<CallbackUrl>https://example.com/callback</CallbackUrl>")
      assert String.contains?(result, "<IdNumber>8603015126082</IdNumber>")
      assert String.contains?(result, "<Initials>JS</Initials>")
      assert String.contains?(result, "<Name>John Smith</Name>")
    end

    test "generates reference if not provided" do
      params = %{
        client_code: "TEST01",
        account_number: "1234567890",
        branch_code: "250655"
      }

      result = RequestBuilder.build_verification_xml(params)
      assert String.match?(result, ~r/<Reference>REF\d+<\/Reference>/)
    end
  end

  describe "build_payment_xml/1" do
    test "builds valid single payment request" do
      params = %{
        client_code: "TEST01",
        payments: [%{
          account_number: "1234567890",
          branch_code: "250655",
          amount: "100.00",
          first_name: "John",
          surname: "Smith",
          reference: "PAY123"
        }]
      }

      result = RequestBuilder.build_payment_xml(params)

      assert String.contains?(result, "<APIPaymentsRequest>")
      assert String.contains?(result, "<FileAmount>100.00</FileAmount>")
      assert String.contains?(result, "<FirstName>John</FirstName>")
    end

    test "builds valid multiple payment request" do
      params = %{
        client_code: "TEST01",
        payments: [
          %{
            account_number: "1234567890",
            branch_code: "250655",
            amount: "100.00",
            reference: "PAY123"
          },
          %{
            account_number: "0987654321",
            branch_code: "250655",
            amount: "200.00",
            reference: "PAY124"
          }
        ]
      }

      result = RequestBuilder.build_payment_xml(params)

      assert String.contains?(result, "<APIPaymentsRequest>")
      assert String.contains?(result, "<Records>2</Records>")
      assert String.contains?(result, "<Amount>300.00</Amount>")
    end
  end

  # Add more test cases for other builders...
end

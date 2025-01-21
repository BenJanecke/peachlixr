defmodule PayoutsElixirTest do
  use ExUnit.Case
  alias PayoutsElixir

  describe "verify_bank/1" do
    test "successfully verifies bank details" do
      params = %{
        client_code: "your_client_code",
        callback_url: "your_callback_url",
        name: "Peach",
        id_number: "2133445555",
        account_number: "1021278653",
        branch_code: "198765"
      }

      assert {:ok, response} = PayoutsElixir.verify_bank(params)
      assert response.status == 200
    end

    test "returns error for invalid parameters" do
      params = %{
        client_code: nil,
        callback_url: nil,
        name: nil,
        id_number: nil,
        account_number: nil,
        branch_code: nil
      }

      assert {:error, _} = PayoutsElixir.verify_bank(params)
    end
  end
end
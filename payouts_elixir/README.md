# PayoutsElixir

PayoutsElixir is an Elixir library designed to interact with the Payouts and Supporting Services API. This library provides a simple interface for performing bank verification and other related operations.

## Installation

To use PayoutsElixir in your project, add it to your `mix.exs` dependencies:

```elixir
defp deps do
  [
    {:payouts_elixir, git: "https://github.com/your_username/payouts_elixir.git"}
  ]
end
```

Then, run the following command to fetch the dependency:

```bash
mix deps.get
```

## Usage

To verify a bank account, you can use the `verify_bank/1` function provided by the `PayoutsElixir` module. Here’s an example of how to use it:

```elixir
# Import the module
import PayoutsElixir

# Call the verify_bank function with the required parameters
response = verify_bank(%{
  client_code: "your_client_code",
  callback_url: "your_callback_url",
  name: "Peach",
  id_number: "2133445555",
  account_number: "1021278653",
  branch_code: "198765"
})

IO.inspect(response)
```

## API Reference

### `verify_bank/1`

- **Parameters**: A map containing the following keys:
  - `:client_code` - Your client code.
  - `:callback_url` - The callback URL for the API response.
  - `:name` - The name associated with the bank account.
  - `:id_number` - The ID number of the account holder.
  - `:account_number` - The bank account number.
  - `:branch_code` - The branch code of the bank.

- **Returns**: The response from the API, which includes the verification status and any relevant data.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
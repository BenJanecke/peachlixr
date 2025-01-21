defmodule PayoutsElixir.Structs do
  defmodule BaseRequest do
    @moduledoc """
    Base request fields common across all request types
    """
    defstruct [
      :client_code,
      :callback_url,
      :service,
      :service_type,
      :due_date,
      :reference
    ]

    @type t :: %__MODULE__{
      client_code: String.t(),
      callback_url: String.t() | nil,
      service: String.t() | nil,
      service_type: String.t() | nil,
      due_date: String.t() | nil,
      reference: String.t() | nil
    }
  end

  defmodule VerificationRequest do
    @moduledoc """
    Request struct for bank account verification
    """
    defstruct [
      :account_number,
      :branch_code,
      :id_number,
      :initials,
      :name,
      :reference,
      :base_request
    ]

    @type t :: %__MODULE__{
      account_number: String.t(),
      branch_code: String.t(),
      id_number: String.t() | nil,
      initials: String.t() | nil,
      name: String.t() | nil,
      reference: String.t() | nil,
      base_request: BaseRequest.t()
    }

    def new(params) do
      %__MODULE__{
        account_number: params.account_number,
        branch_code: params.branch_code,
        id_number: params[:id_number],
        initials: params[:initials],
        name: params[:name],
        reference: params[:reference],
        base_request: struct(BaseRequest, Map.take(params, [:client_code, :callback_url, :service, :service_type, :due_date]))
      }
    end
  end

  defmodule PaymentDetails do
    @moduledoc """
    Details for a single payment transaction
    """
    defstruct [
      :account_number,
      :branch_code,
      :amount,
      :initial,
      :first_name,
      :surname,
      :reference,
      account_type: 0,
      amount_multiplier: 1
    ]

    @type t :: %__MODULE__{
      account_number: String.t(),
      branch_code: String.t(),
      amount: String.t(),
      initial: String.t() | nil,
      first_name: String.t() | nil,
      surname: String.t() | nil,
      reference: String.t() | nil,
      account_type: integer(),
      amount_multiplier: integer()
    }

    def new(params) do
      struct(__MODULE__, params)
    end
  end

  defmodule PaymentRequest do
    @moduledoc """
    Request struct for payment transactions
    """
    defstruct [
      :payments,
      :base_request
    ]

    @type t :: %__MODULE__{
      payments: [PaymentDetails.t()],
      base_request: BaseRequest.t()
    }

    def new(params) do
      %__MODULE__{
        payments: Enum.map(params.payments, &PaymentDetails.new/1),
        base_request: struct(BaseRequest, Map.take(params, [:client_code, :callback_url, :service, :service_type, :due_date]))
      }
    end
  end

  defmodule CDVRequest do
    @moduledoc """
    Request struct for check digit verification
    """
    defstruct [
      :account_number,
      :branch_code,
      :base_request
    ]

    @type t :: %__MODULE__{
      account_number: String.t(),
      branch_code: String.t(),
      base_request: BaseRequest.t()
    }

    def new(params) do
      %__MODULE__{
        account_number: params.account_number,
        branch_code: params.branch_code,
        base_request: struct(BaseRequest, Map.take(params, [:client_code, :callback_url, :service, :service_type, :due_date]))
      }
    end
  end
end

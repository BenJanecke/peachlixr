defmodule PayoutsElixir.ResponseStructs do
  defmodule BaseResponse do
    @moduledoc """
    Common fields across all response types
    """
    defstruct [
      :result,
      :batch_code,
      :fee,
      :unique_id
    ]

    @type t :: %__MODULE__{
      result: String.t(),
      batch_code: String.t(),
      fee: String.t(),
      unique_id: String.t() | nil
    }
  end

  defmodule BanvResult do
    @moduledoc """
    Bank account verification result
    """
    defstruct [
      :account_number,
      :id_number,
      :initials,
      :name,
      :reference,
      :flags,
      :result
    ]

    @type t :: %__MODULE__{
      account_number: String.t(),
      id_number: String.t() | nil,
      initials: String.t() | nil,
      name: String.t() | nil,
      reference: String.t() | nil,
      flags: String.t() | nil,
      result: String.t()
    }
  end

  defmodule BanvRealtimeResult do
    @moduledoc """
    Real-time bank verification result
    """
    defstruct [
      :account_number,
      :account_type,
      :flags,
      :id_number,
      :initials,
      :name,
      :reference,
      :result,
      :result_message
    ]

    @type t :: %__MODULE__{
      account_number: String.t(),
      account_type: String.t() | nil,
      flags: String.t() | nil,
      id_number: String.t() | nil,
      initials: String.t() | nil,
      name: String.t() | nil,
      reference: String.t() | nil,
      result: String.t(),
      result_message: String.t() | nil
    }
  end

  defmodule CDVResult do
    @moduledoc """
    Check digit verification result
    """
    defstruct [
      :account_number,
      :branch_code,
      :customer_code,
      :reference,
      :result,
      :message
    ]

    @type t :: %__MODULE__{
      account_number: String.t(),
      branch_code: String.t(),
      customer_code: String.t() | nil,
      reference: String.t() | nil,
      result: String.t(),
      message: String.t() | nil
    }
  end

  defmodule PaymentResult do
    @moduledoc """
    Payment transaction result
    """
    defstruct [
      :account_number,
      :branch_code,
      :first_name,
      :surname,
      :reference,
      :customer_code,
      :result,
      :result_message
    ]

    @type t :: %__MODULE__{
      account_number: String.t(),
      branch_code: String.t(),
      first_name: String.t() | nil,
      surname: String.t() | nil,
      reference: String.t() | nil,
      customer_code: String.t() | nil,
      result: String.t(),
      result_message: String.t()
    }
  end

  defmodule VerificationResponse do
    @moduledoc """
    Response for bank verification requests
    """
    defstruct [
      :base_response,
      banv_results: [],
      cdv_results: []
    ]

    @type t :: %__MODULE__{
      base_response: BaseResponse.t(),
      banv_results: [BanvResult.t()],
      cdv_results: [CDVResult.t()]
    }
  end

  defmodule RealTimeVerificationResponse do
    @moduledoc """
    Response for real-time verification requests
    """
    defstruct [
      :base_response,
      :banv_realtime_result,
      cdv_results: []
    ]

    @type t :: %__MODULE__{
      base_response: BaseResponse.t(),
      banv_realtime_result: BanvRealtimeResult.t(),
      cdv_results: [CDVResult.t()]
    }
  end

  defmodule CDVResponse do
    @moduledoc """
    Response for CDV requests
    """
    defstruct [
      :base_response,
      cdv_results: []
    ]

    @type t :: %__MODULE__{
      base_response: BaseResponse.t(),
      cdv_results: [CDVResult.t()]
    }
  end

  defmodule PaymentResponse do
    @moduledoc """
    Response for payment requests
    """
    defstruct [
      :base_response,
      :batch_value,
      payment_results: [],
      cdv_results: []
    ]

    @type t :: %__MODULE__{
      base_response: BaseResponse.t(),
      batch_value: String.t(),
      payment_results: [PaymentResult.t()],
      cdv_results: [CDVResult.t()]
    }
  end
end

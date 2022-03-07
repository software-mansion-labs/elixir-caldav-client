defmodule CalDAVClient.Auth.Bearer do
  @moduledoc """
  Stores user credentials for Bearer authentication.

  ## Fields
  * `token` - Bearer authentication token
  """

  @type t :: %__MODULE__{
          token: String.t()
        }

  @enforce_keys [:token]
  defstruct @enforce_keys
end

defmodule CalDAVClient.Auth.Digest do
  @moduledoc """
  Stores user credentials for Digest authentication.

  ## Fields
  * `username` - username
  * `password` - password
  """

  @type t :: %__MODULE__{
          username: String.t(),
          password: String.t()
        }

  @enforce_keys [:username, :password]
  defstruct @enforce_keys
end

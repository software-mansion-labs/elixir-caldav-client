defmodule CalDAVClient.Client do
  @moduledoc """
  Stores the server address, authentication method and user credentials.

  ## Fields
  * `server_url` - address of the calendar server, e.g. `"http://example.com/calendar"`
  * `auth` - HTTP authentication method, either `:basic` or `:digest`
  * `username` - username
  * `password` - password
  """

  alias CalDAVClient.Auth.Basic
  alias CalDAVClient.Auth.Digest
  alias CalDAVClient.Auth.Bearer

  @type t :: %__MODULE__{
          server_url: String.t(),
          auth: Basic.t() | Digest.t() | Bearer.t()
        }

  @enforce_keys [:server_url, :auth]
  defstruct @enforce_keys
end

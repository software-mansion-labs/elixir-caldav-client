defmodule CalDAVClient.Client do
  @moduledoc """
  Stores the server address, authentication method and user credentials.

  ## Fields
  * `server_url` - address of the calendar server, e.g. `"http://example.com/calendar"`
  * `auth` - authentication type and credentials:
    * `t:CalDAVClient.Auth.Basic.t/0` - Basic authentication
    * `t:CalDAVClient.Auth.Digest.t/0` - Digest authentication
    * `t:CalDAVClient.Auth.Bearer.t/0` - Bearer (token) authentication
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

defmodule CalDAVClient.Client do
  @moduledoc """
  Stores the server address, authentication method and user credentials.

  ## Fields
  * `server_url` - address of the calendar server, e.g. `"http://example.com/calendar"`
  * `auth` - HTTP authentication method, either `:basic` or `:digest`
  * `username` - username
  * `password` - password
  """

  @type t :: %__MODULE__{
          server_url: String.t(),
          auth: :basic | :digest,
          username: String.t(),
          password: String.t()
        }

  @enforce_keys [:server_url, :auth, :username, :password]
  defstruct @enforce_keys
end

defmodule CalDAVClient.BearerClient do
  @moduledoc """
  Stores the server addressand token for CalDav servers with Bearer authorization.

  ## Fields
  * `server_url` - address of the calendar server, e.g. `"http://example.com/calendar"`
  * `token` - Bearer authentication token
  """

  @type t :: %__MODULE__{
          server_url: String.t(),
          token: String.t()
        }

  @enforce_keys [:server_url, :token]
  defstruct @enforce_keys
end

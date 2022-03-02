defmodule CalDAVClient.Auth.Basic do
  @moduledoc """
  Stores user credentials for Basic authorization.

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

defmodule CalDAVClient.Auth.Digest do
  @moduledoc """
  Stores user credentials for Digest authorization.

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

defmodule CalDAVClient.Auth.Bearer do
  @moduledoc """
  Stores user credentials for Basic authorization.

  ## Fields
  * `token` - Bearer authentication token
  """

  @type t :: %__MODULE__{
          token: String.t()
        }

  @enforce_keys [:token]
  defstruct @enforce_keys
end

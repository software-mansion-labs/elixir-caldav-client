defmodule CalDAVClient.Tesla do
  @moduledoc """
  Provides utility functions for integration with Tesla library.
  """

  @doc """
  Converts a `t:CalDAVClient.Client.t/0` into a Tesla client which enables communication
  with an external calendar server via HTTP protocol.
  """
  @spec make_tesla_client(CalDAVClient.Client.t() | CalDAVClient.BearerClient.t(), [
          Tesla.Client.middleware()
        ]) ::
          Tesla.Client.t()
  def make_tesla_client(caldav_client, middleware \\ []) do
    auth_middleware = build_auth_middleware(caldav_client)

    Tesla.client([
      {Tesla.Middleware.BaseUrl, caldav_client.server_url},
      auth_middleware
      | middleware
    ])
  end

  def build_auth_middleware(caldav_client = %CalDAVClient.Client{}) do
    credentials = caldav_client |> Map.take([:username, :password])

    auth_middleware =
      case caldav_client.auth do
        :basic -> Tesla.Middleware.BasicAuth
        :digest -> Tesla.Middleware.DigestAuth
      end

    {auth_middleware, credentials}
  end

  def build_auth_middleware(%CalDAVClient.BearerClient{token: token}) do
    {Tesla.Middleware.BearerAuth, token: token}
  end
end

defmodule CalDAVClient.Tesla.ContentTypeXMLMiddleware do
  @moduledoc """
  Puts `Content-Type: application/xml; charset="utf-8"` header in the HTTP request.
  """
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, _options) do
    env
    |> Tesla.put_header("content-type", "application/xml; charset=\"utf-8\"")
    |> Tesla.run(next)
  end
end

defmodule CalDAVClient.Tesla.ContentTypeICalendarMiddleware do
  @moduledoc """
  Puts `Content-Type: text/calendar` header in the HTTP request.
  """
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, _options) do
    env
    |> Tesla.put_header("content-type", "text/calendar")
    |> Tesla.run(next)
  end
end

defmodule CalDAVClient.Tesla.ContentLengthMiddleware do
  @moduledoc """
  Puts `Content-Length` header in the HTTP request.
  """
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, _options) do
    env
    |> Tesla.put_header(
      "content-length",
      (env.body || "") |> String.length() |> Integer.to_string()
    )
    |> Tesla.run(next)
  end
end

defmodule CalDAVClient.Tesla.IfMatchMiddleware do
  @moduledoc """
  Puts `If-Match` header in the HTTP request.
  """
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, opts) do
    case opts[:etag] do
      nil -> env
      etag -> env |> Tesla.put_header("if-match", etag)
    end
    |> Tesla.run(next)
  end
end

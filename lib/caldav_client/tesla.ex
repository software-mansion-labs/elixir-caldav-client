defmodule CalDAVClient.Tesla do
  @moduledoc """
  Provides utility functions for integration with Tesla library.
  """

  @doc """
  Converts a `t:CalDAVClient.Client.t/0` into a Tesla client which enables communication
  with an external calendar server via HTTP protocol.
  """
  @spec make_tesla_client(CalDAVClient.Client.t(), [
          Tesla.Client.middleware()
        ]) ::
          Tesla.Client.t()
  def make_tesla_client(%{server_url: server_url, auth: auth}, middleware \\ []) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, server_url},
      {auth_middleware(auth), credentials(auth)}
      | middleware
    ])
  end

  defp auth_middleware(%CalDAVClient.Auth.Basic{}), do: Tesla.Middleware.BasicAuth
  defp auth_middleware(%CalDAVClient.Auth.Digest{}), do: Tesla.Middleware.DigestAuth
  defp auth_middleware(%CalDAVClient.Auth.Bearer{}), do: Tesla.Middleware.BearerAuth

  defp credentials(auth = %{username: _, password: _}), do: auth
  defp credentials(%{token: token}), do: [token: token]
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

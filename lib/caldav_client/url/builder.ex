defmodule CalDAVClient.URL.Builder do
  @moduledoc """
  Builds URLs according to CalDAV specification.
  """

  @doc """
  Builds calendar URL for given username and calendar ID.
  """
  @spec build_calendar_url(username :: String.t(), calendar_token_id :: String.t()) :: String.t()
  def build_calendar_url(username, calendar_token_id) do
    "/calendars/#{username |> URI.encode()}/#{calendar_token_id |> URI.encode()}"
  end

  @doc """
  Builds event URL for given username and event ID.
  """
  @spec build_event_url(calendar_url :: String.t(), event_token_id :: String.t()) :: String.t()
  def build_event_url(calendar_url, event_token_id) do
    "#{calendar_url}/#{event_token_id |> URI.encode()}"
  end
end

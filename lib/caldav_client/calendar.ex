defmodule CalDAVClient.Calendar do
  @moduledoc """
  Allows for managing calendars on the calendar server.
  """

  import CalDAVClient.HTTP.Error
  import CalDAVClient.Tesla

  @xml_middlewares [
    CalDAVClient.Tesla.ContentTypeXMLMiddleware,
    CalDAVClient.Tesla.ContentLengthMiddleware
  ]

  @doc """
  Fetches the list of calendars (see [RFC 4791, section 4.2](https://tools.ietf.org/html/rfc4791#section-4.2)).
  """

  # @spec create(CalDAVClient.Client.t()) ::
  def list(caldav_client) do
    case caldav_client
         |> make_tesla_client(@xml_middlewares)
         |> Tesla.request(
           method: :propfind,
           url: "",
           body: CalDAVClient.XML.Builder.build_list_calendar_xml()
         )
           |> IO.inspect do
      {:ok, %Tesla.Env{status: code}} ->
        case code do
          201 -> :ok
          207 -> :ok
          405 -> {:error, :already_exists}
          _ -> {:error, reason_atom(code)}
        end

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Creates a calendar (see [RFC 4791, section 5.3.1.2](https://tools.ietf.org/html/rfc4791#section-5.3.1.2)).

  ## Options
  * `name` - calendar name.
  * `description` - calendar description.
  """

  @spec create(CalDAVClient.Client.t(), calendar_url :: String.t(), opts :: keyword()) ::
          :ok | {:error, any()}
  def create(caldav_client, calendar_url, opts \\ []) do
    case caldav_client
         |> make_tesla_client(@xml_middlewares)
         |> Tesla.request(
           method: :mkcalendar,
           url: calendar_url,
           body: CalDAVClient.XML.Builder.build_create_calendar_xml(opts)
         ) do
      {:ok, %Tesla.Env{status: code}} ->
        case code do
          201 -> :ok
          405 -> {:error, :already_exists}
          _ -> {:error, reason_atom(code)}
        end

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Updates a specific calendar.

  ## Options
  * `name` - calendar name.
  * `description` - calendar description.
  """
  @spec update(CalDAVClient.Client.t(), calendar_url :: String.t(), opts :: keyword()) ::
          :ok | {:error, any()}
  def update(caldav_client, calendar_url, opts \\ []) do
    case caldav_client
         |> make_tesla_client(@xml_middlewares)
         |> Tesla.request(
           method: :proppatch,
           url: calendar_url,
           body: CalDAVClient.XML.Builder.build_update_calendar_xml(opts)
         ) do
      {:ok, %Tesla.Env{status: code}} ->
        case code do
          207 -> :ok
          _ -> {:error, reason_atom(code)}
        end

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Deletes a specific calendar.
  """
  @spec delete(CalDAVClient.Client.t(), calendar_url :: String.t()) :: :ok | {:error, any()}
  def delete(caldav_client, calendar_url) do
    case caldav_client
         |> make_tesla_client()
         |> Tesla.delete(calendar_url) do
      {:ok, %Tesla.Env{status: code}} ->
        case code do
          204 -> :ok
          _ -> {:error, reason_atom(code)}
        end

      {:error, _reason} = error ->
        error
    end
  end
end

defmodule CalDAVClient.Event do
  @moduledoc """
  Allows for managing events on the calendar server.
  """

  import CalDAVClient.HTTP.Error
  import CalDAVClient.Tesla

  @type t :: %__MODULE__{
          icalendar: String.t(),
          url: String.t(),
          etag: String.t()
        }

  @enforce_keys [:icalendar, :url, :etag]
  defstruct @enforce_keys

  @doc """
  Creates an event (see [RFC 4791, section 5.3.2](https://tools.ietf.org/html/rfc4791#section-5.3.2)).
  """
  @spec create(CalDAVClient.Client.t(), event_url :: String.t(), event_icalendar :: String.t()) ::
          {:ok, etag :: String.t() | nil} | {:error, any()}
  def create(caldav_client, event_url, event_icalendar) do
    # fail when event already exists
    headers = [{"If-None-Match", "*"}]

    case caldav_client
         |> make_tesla_client([
           CalDAVClient.Tesla.ContentTypeICalendarMiddleware,
           CalDAVClient.Tesla.ContentLengthMiddleware
         ])
         |> Tesla.put(event_url, event_icalendar, headers: headers) do
      {:ok, %Tesla.Env{status: code} = env} when code in [201, 204] ->
        etag = env |> Tesla.get_header("etag")
        {:ok, etag}

      {:ok, %Tesla.Env{status: code}} ->
        case code do
          412 -> {:error, :already_exists}
          _ -> {:error, reason_atom(code)}
        end

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Updates a specific event (see [RFC 4791, section 5.3.2](https://tools.ietf.org/html/rfc4791#section-5.3.2)).

  ## Options
  * `etag` - a specific ETag used to ensure that the client overwrites the latest version of the event.
  """
  @spec update(
          CalDAVClient.Client.t(),
          event_url :: String.t(),
          event_icalendar :: String.t(),
          opts :: keyword()
        ) :: {:ok, etag :: String.t() | nil} | {:error, any()}
  def update(caldav_client, event_url, event_icalendar, opts \\ []) do
    case caldav_client
         |> make_tesla_client([
           CalDAVClient.Tesla.ContentTypeICalendarMiddleware,
           CalDAVClient.Tesla.ContentLengthMiddleware,
           {CalDAVClient.Tesla.IfMatchMiddleware, etag: opts[:etag]}
         ])
         |> Tesla.put(event_url, event_icalendar) do
      {:ok, %Tesla.Env{status: code} = env} when code in [201, 204] ->
        etag = env |> Tesla.get_header("etag")
        {:ok, etag}

      {:ok, %Tesla.Env{status: code}} ->
        case code do
          412 -> {:error, :bad_etag}
          _ -> {:error, reason_atom(code)}
        end

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Deletes a specific event.

  ## Options
  * `etag` - a specific ETag used to ensure that the client overwrites the latest version of the event.
  """
  @spec delete(CalDAVClient.Client.t(), event_url :: String.t(), opts :: keyword()) ::
          :ok | {:error, any()}
  def delete(caldav_client, event_url, opts \\ []) do
    case caldav_client
         |> make_tesla_client([
           CalDAVClient.Tesla.ContentTypeICalendarMiddleware,
           CalDAVClient.Tesla.ContentLengthMiddleware,
           {CalDAVClient.Tesla.IfMatchMiddleware, etag: opts[:etag]}
         ])
         |> Tesla.delete(event_url) do
      {:ok, %Tesla.Env{status: code}} ->
        case code do
          204 -> :ok
          412 -> {:error, :bad_etag}
          _ -> {:error, reason_atom(code)}
        end

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Returns a specific event in the iCalendar format along with its ETag.
  """
  @spec get(CalDAVClient.Client.t(), event_url :: String.t()) ::
          {:ok, icalendar :: String.t(), etag :: String.t()} | {:error, any()}
  def get(caldav_client, event_url) do
    case caldav_client
         |> make_tesla_client()
         |> Tesla.get(event_url) do
      {:ok, %Tesla.Env{status: 200, body: icalendar} = env} ->
        etag = env |> Tesla.get_header("etag")
        {:ok, icalendar, etag}

      {:ok, %Tesla.Env{status: code}} ->
        {:error, reason_atom(code)}

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Returns an event with the specified UID property
  (see [RFC 4791, section 7.8.6](https://tools.ietf.org/html/rfc4791#section-7.8.6)).
  """
  @spec find_by_uid(CalDAVClient.Client.t(), calendar_url :: String.t(), event_uid :: String.t()) ::
          {:ok, t()} | {:error, any()}
  def find_by_uid(caldav_client, calendar_url, event_uid) do
    request_xml = CalDAVClient.XML.Builder.build_retrieval_of_event_by_uid_xml(event_uid)

    case caldav_client |> get_events_by_xml(calendar_url, request_xml) do
      {:ok, [event]} -> {:ok, event}
      {:ok, []} -> {:error, :not_found}
      {:ok, _events} -> {:error, :multiple_found}
      {:error, _reason} = error -> error
    end
  end

  @doc """
  Retrieves all events or its occurrences within a specific time range
  (see [RFC 4791, section 7.8.1](https://tools.ietf.org/html/rfc4791#section-7.8.1)).

  ## Options
  * `expand` - if `true`, recurring events will be expanded to occurrences, defaults to `false`.
  """
  @spec get_events(
          CalDAVClient.Client.t(),
          calendar_url :: String.t(),
          from :: DateTime.t(),
          to :: DateTime.t(),
          opts :: keyword()
        ) :: {:ok, [t()]} | {:error, any()}
  def get_events(caldav_client, calendar_url, from, to, opts \\ []) do
    request_xml = CalDAVClient.XML.Builder.build_retrieval_of_events_xml(from, to, opts)
    caldav_client |> get_events_by_xml(calendar_url, request_xml)
  end

  @doc """
  Retrieves all events or its occurrences having an VALARM within a specific time range
  (see [RFC 4791, section 7.8.5](https://tools.ietf.org/html/rfc4791#section-7.8.5)).

  ## Options
  * `expand` - if `true`, recurring events will be expanded to occurrences, defaults to `false`.
  * `event_from` - start of time range for events or occurrences, defaults to `0000-00-00T00:00:00Z`.
  * `event_to` - end of time range for events or occurrences, defaults to `9999-12-31T23:59:59Z`.
  """
  @spec get_events_by_alarm(
          CalDAVClient.Client.t(),
          calendar_url :: String.t(),
          from :: DateTime.t(),
          to :: DateTime.t(),
          opts :: keyword()
        ) ::
          {:ok, [t()]} | {:error, any()}
  def get_events_by_alarm(caldav_client, calendar_url, from, to, opts \\ []) do
    request_xml =
      CalDAVClient.XML.Builder.build_retrieval_of_events_having_alarm_xml(from, to, opts)

    caldav_client |> get_events_by_xml(calendar_url, request_xml)
  end

  @doc """
  Retrieves all occurrences of events for given XML request body.
  """
  @spec get_events_by_xml(
          CalDAVClient.Client.t(),
          calendar_url :: String.t(),
          request_xml :: String.t()
        ) ::
          {:ok, [t()]} | {:error, any()}
  def get_events_by_xml(caldav_client, calendar_url, request_xml) do
    case caldav_client
         |> make_tesla_client([
           CalDAVClient.Tesla.ContentTypeXMLMiddleware,
           CalDAVClient.Tesla.ContentLengthMiddleware
         ])
         |> Tesla.request(
           method: :report,
           url: calendar_url,
           body: request_xml,
           headers: [{"Depth", "1"}],
           opts: [pre_auth_method: :get]
         ) do
      {:ok, %Tesla.Env{status: 207, body: response_xml}} ->
        events = response_xml |> CalDAVClient.XML.Parser.parse_events()
        {:ok, events}

      {:ok, %Tesla.Env{status: code}} ->
        {:error, reason_atom(code)}

      {:error, _reason} = error ->
        error
    end
  end
end

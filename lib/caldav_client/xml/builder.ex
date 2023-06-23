defmodule CalDAVClient.XML.Builder do
  @moduledoc """
  Builds XML request body for the calendar server.
  """

  import CalDAVClient.ICalendar.Serializer

  @default_event_from DateTime.from_naive!(~N[0000-01-01 00:00:00], "Etc/UTC")
  @default_event_to DateTime.from_naive!(~N[9999-12-31 23:59:59], "Etc/UTC")

  @doc """
  Generates XML request body to fetch the list of calendars
  (see [RFC 4791, section 4.2](https://tools.ietf.org/html/rfc4791#section-4.2)).
  """
  @spec build_list_calendar_xml() :: String.t()
  def build_list_calendar_xml() do
    {"D:propfind",
     [
       "xmlns:D": "DAV:",
       "xmlns:CS": "http://calendarserver.org/ns/",
       "xmlns:C": "urn:ietf:params:xml:ns:caldav"
     ],
     [
       {"D:prop", nil,
        [
          {"D:resourcetype"},
          {"D:displayname"},
          {"C:calendar-timezone"},
          {"C:supported-calendar-component-set"}
        ]}
     ]}
    |> serialize()
  end

  @doc """
  Generates XML request body to create a calendar
  (see [RFC 4791, section 5.3.1.2](https://tools.ietf.org/html/rfc4791#section-5.3.1.2)).

  ## Options
  * `name` - calendar name.
  * `description` - calendar description.
  """
  @spec build_create_calendar_xml(opts :: keyword()) :: String.t()
  def build_create_calendar_xml(opts \\ []) do
    props =
      opts
      |> Enum.map(fn {key, value} ->
        case key do
          :name -> {"D:displayname", nil, value}
          :description -> {"C:calendar-description", ["xml:lang": "en"], value}
        end
      end)

    {"C:mkcalendar", ["xmlns:D": "DAV:", "xmlns:C": "urn:ietf:params:xml:ns:caldav"],
     [
       {"D:set", nil,
        [
          {"D:prop", nil,
           props ++
             [
               {"C:supported-calendar-component-set", nil,
                [
                  {"C:comp", [name: "VEVENT"], nil}
                ]}
             ]}
        ]}
     ]}
    |> serialize()
  end

  @doc """
  Generates XML request body to update calendar properties.

  ## Options
  * `name` - calendar name.
  * `description` - calendar description.
  """
  @spec build_update_calendar_xml(opts :: keyword()) :: String.t()
  def build_update_calendar_xml(opts \\ []) do
    props =
      opts
      |> Enum.map(fn {key, value} ->
        case key do
          :name -> {"A:displayname", nil, value}
          :description -> {"A:calendar-description", ["xml:lang": "en"], value}
        end
      end)

    {"A:propertyupdate", ["xmlns:A": "DAV:"],
     [
       {"A:set", nil,
        [
          {"A:prop", nil, props}
        ]}
     ]}
    |> serialize()
  end

  @doc """
  Generates XML request body to retrieve event with specified UID property
  (see [RFC 4791, section 7.8.6](https://tools.ietf.org/html/rfc4791#section-7.8.6)).
  """
  @spec build_update_calendar_xml() :: String.t()
  def build_retrieval_of_event_by_uid_xml(uid) do
    {"C:calendar-query", ["xmlns:D": "DAV:", "xmlns:C": "urn:ietf:params:xml:ns:caldav"],
     [
       {"D:prop", nil,
        [
          {"D:getetag"},
          {"C:calendar-data"}
        ]},
       {"C:filter", nil,
        [
          {"C:comp-filter", [name: "VCALENDAR"],
           [
             {"C:comp-filter", [name: "VEVENT"],
              [
                {"C:prop-filter", [name: "UID"],
                 [
                   {"C:text-match", [collation: "i;octet"], uid}
                 ]}
              ]}
           ]}
        ]}
     ]}
    |> serialize()
  end

  @doc """
  Generates XML request body to retrieve all events or its occurrences within a specific time range
  (see [RFC 4791, section 7.8.1](https://tools.ietf.org/html/rfc4791#section-7.8.1)).

  ## Options
  * `expand` - if `true`, recurring events will be expanded to occurrences, defaults to `false`.
  """
  @spec build_retrieval_of_events_xml(
          start_icalendar :: DateTime.t(),
          end_icalendar :: DateTime.t(),
          opts :: keyword()
        ) :: String.t()
  def build_retrieval_of_events_xml(start_datetime, end_datetime, opts \\ []) do
    start_icalendar = serialize_datetime!(start_datetime)
    end_icalendar = serialize_datetime!(end_datetime)

    {"C:calendar-query", ["xmlns:D": "DAV:", "xmlns:C": "urn:ietf:params:xml:ns:caldav"],
     [
       {"D:prop", nil,
        [
          {"D:getetag"},
          if opts[:expand] do
            {"C:calendar-data", nil,
             [
               {"C:expand", [start: start_icalendar, end: end_icalendar], nil}
             ]}
          else
            {"C:calendar-data"}
          end
        ]},
       {"C:filter", nil,
        [
          {"C:comp-filter", [name: "VCALENDAR"],
           [
             {"C:comp-filter", [name: "VEVENT"],
              [
                {"C:time-range", [start: start_icalendar, end: end_icalendar], nil}
              ]}
           ]}
        ]}
     ]}
    |> serialize()
  end

  @doc """
  Generates XML request body to retrieve all events or its occurrences
  having an VALARM within a specific time range
  (see [RFC 4791, section 7.8.5](https://tools.ietf.org/html/rfc4791#section-7.8.5)).
  """
  @spec build_retrieval_of_events_having_alarm_xml(
          from :: DateTime.t(),
          to :: DateTime.t(),
          opts :: keyword()
        ) :: String.t()
  def build_retrieval_of_events_having_alarm_xml(from, to, opts \\ []) do
    from = serialize_datetime!(from)
    to = serialize_datetime!(to)

    {"C:calendar-query", ["xmlns:D": "DAV:", "xmlns:C": "urn:ietf:params:xml:ns:caldav"],
     [
       {"D:prop", nil,
        [
          {"D:getetag"},
          if opts[:expand] do
            event_from = serialize_datetime!(opts[:event_from] || @default_event_from)
            event_to = serialize_datetime!(opts[:event_to] || @default_event_to)

            {"C:calendar-data", nil,
             [
               {"C:expand", [start: event_from, end: event_to], nil}
             ]}
          else
            {"C:calendar-data"}
          end
        ]},
       {"C:filter", nil,
        [
          {"C:comp-filter", [name: "VCALENDAR"],
           [
             {"C:comp-filter", [name: "VEVENT"],
              [
                {"C:comp-filter", [name: "VALARM"],
                 [
                   {"C:time-range", [start: from, end: to], nil}
                 ]}
              ]}
           ]}
        ]}
     ]}
    |> serialize()
  end

  defp serialize(tree) do
    tree
    |> XmlBuilder.document()
    |> XmlBuilder.generate(encoding: "utf-8")
  end
end

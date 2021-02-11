defmodule CalDAVClient.XML.Parser do
  @moduledoc """
  Parses XML responses received from the calendar server.
  """

  import SweetXml

  @event_xpath ~x"//*[local-name()='multistatus']/*[local-name()='response']"el
  @url_xpath ~x"./*[local-name()='href']/text()"s
  @icalendar_xpath ~x"./*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='calendar-data']/text()"s
  @etag_xpath ~x"./*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='getetag']/text()"s

  @doc """
  Parses XML response body into a list of events.
  """
  @spec parse_events(response_xml :: String.t()) :: [CalDAVClient.Event.t()]
  def parse_events(response_xml) do
    response_xml
    |> xpath(@event_xpath,
      url: @url_xpath,
      icalendar: @icalendar_xpath,
      etag: @etag_xpath
    )
    |> Enum.map(&struct(CalDAVClient.Event, &1))
  end
end

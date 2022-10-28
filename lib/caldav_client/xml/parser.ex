defmodule CalDAVClient.XML.Parser do
  @moduledoc """
  Parses XML responses received from the calendar server.
  """

  import SweetXml

  @event_xpath ~x"//*[local-name()='multistatus']/*[local-name()='response']"el
  @url_xpath ~x"./*[local-name()='href']/text()"s
  @icalendar_xpath ~x"./*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='calendar-data']/text()"s
  @etag_xpath ~x"./*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='getetag']/text()"s
  @resource_type_xpath ~x"name(./*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='resourcetype']/*)"s

  @cal_name_xpath ~x"./*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='displayname']/text()"s
  @cal_type_xpath ~x"./*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='supported-calendar-component-set']/*[local-name()='comp']/@name"s
  @cal_timezone_xpath ~x"./*[local-name()='propstat']/*[local-name()='prop']/*[local-name()='calendar-timezone']/text()"s

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

  @doc """
  Parses XML response body into a list of calendars.
  """
  @spec parse_calendars(response_xml :: String.t()) :: [CalDAVClient.Calendar.t()]
  def parse_calendars(response_xml) do
    response_xml
    |> xpath(@event_xpath,
      url: @url_xpath,
      name: @cal_name_xpath,
      type: @cal_type_xpath,
      timezone: @cal_timezone_xpath
    )
    |> Enum.map(&struct(CalDAVClient.Calendar, &1))
  end

  @doc """
  Parses XML response body of a principal
  """
  @spec parse_principal(response_xml :: String.t()) :: [CalDAVClient.Principal.t()]
  def parse_principal(response_xml) do
    response_xml
    |> xpath(@event_xpath,
      current_user_principal: @url_xpath,
      resource_type: @resource_type_xpath
    )
    |> Enum.map(&struct(CalDAVClient.Principal, &1))
  end

  @doc """
  Parses XML response body into a list of todos.
  """
  @spec parse_todos(response_xml :: String.t()) :: [CalDAVClient.Todo.t()]
  def parse_todos(response_xml) do
    response_xml
    |> xpath(@todo_xpath,
      url: @url_xpath,
      icalendar: @icalendar_xpath,
      etag: @etag_xpath
    )
    |> Enum.map(&struct(CalDAVClient.Todo, &1))
  end
end

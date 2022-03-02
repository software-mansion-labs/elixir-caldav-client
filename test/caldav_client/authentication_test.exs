defmodule CalDAVClient.AuthenticationTest do
  use ExUnit.Case

  @moduletag :integration

  @server_url Application.get_env(:caldav_client, :test_server)[:server_url]
  @username Application.get_env(:caldav_client, :test_server)[:username]
  @password Application.get_env(:caldav_client, :test_server)[:password]

  @client %CalDAVClient.Client{
    server_url: @server_url,
    auth: %CalDAVClient.Auth.Basic{
      username: @username,
      password: @password
    }
  }
  @invalid_client %CalDAVClient.Client{
    server_url: @server_url,
    auth: %CalDAVClient.Auth.Basic{
      username: "foo",
      password: "bar"
    }
  }

  @calendar_url CalDAVClient.URL.Builder.build_calendar_url(@username, "calendar")
  @event_url CalDAVClient.URL.Builder.build_event_url(@calendar_url, "event")

  @event_icalendar """
  BEGIN:VCALENDAR
  PRODID:-//Elixir//CalDAV//EN
  VERSION:2.0
  BEGIN:VEVENT
  UID:uid1@example.com
  DTSTAMP:20210101T120000Z
  DTSTART:20210101T120000Z
  END:VEVENT
  END:VCALENDAR
  """

  setup do
    :ok = @client |> CalDAVClient.Calendar.create(@calendar_url)
    {:ok, _etag} = @client |> CalDAVClient.Event.create(@event_url, @event_icalendar)
    on_exit(fn -> @client |> CalDAVClient.Calendar.delete(@calendar_url) end)
    :ok
  end

  test "passes on valid credentials" do
    assert {:ok, _icalendar, _etag} = @client |> CalDAVClient.Event.get(@event_url)
  end

  test "fails on invalid credentials" do
    assert {:error, :unauthorized} = @invalid_client |> CalDAVClient.Event.get(@event_url)
  end
end

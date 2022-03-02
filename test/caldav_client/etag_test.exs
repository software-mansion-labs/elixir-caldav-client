defmodule CalDAVClient.ETagTest do
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

  @calendar_id "etag_test"
  @calendar_url CalDAVClient.URL.Builder.build_calendar_url(@username, @calendar_id)

  @event_id "event.ics"
  @event_url CalDAVClient.URL.Builder.build_event_url(@calendar_url, @event_id)

  @event_icalendar """
  BEGIN:VCALENDAR
  PRODID:-//xyz Corp//NONSGML PDA Calendar Version 1.0//EN
  VERSION:2.0
  BEGIN:VEVENT
  DTSTAMP:19960704T120000Z
  UID:uid1@example.com
  DTSTART:19960918T143000Z
  END:VEVENT
  END:VCALENDAR
  """

  @event_icalendar_modified """
  BEGIN:VCALENDAR
  PRODID:-//xyz Corp//NONSGML PDA Calendar Version 1.0//EN
  VERSION:2.0
  BEGIN:VEVENT
  DTSTAMP:19960704T120000Z
  UID:uid1@example.com
  DTSTART:19960918T153000Z
  END:VEVENT
  END:VCALENDAR
  """

  setup do
    :ok =
      @client
      |> CalDAVClient.Calendar.create(@calendar_url, name: "Name", description: "Description")

    on_exit(fn -> @client |> CalDAVClient.Calendar.delete(@calendar_url) end)
    :ok
  end

  test "returns correct etag when event is created" do
    {:ok, etag} = @client |> CalDAVClient.Event.create(@event_url, @event_icalendar)
    assert {:ok, _icalendar, ^etag} = @client |> CalDAVClient.Event.get(@event_url)
  end

  describe "when event is updated" do
    setup do
      {:ok, etag} = @client |> CalDAVClient.Event.create(@event_url, @event_icalendar)

      [etag: etag]
    end

    test "passes without etag" do
      assert {:ok, _etag} =
               @client |> CalDAVClient.Event.update(@event_url, @event_icalendar_modified)
    end

    test "passes with correct etag", context do
      assert {:ok, _etag} =
               @client
               |> CalDAVClient.Event.update(@event_url, @event_icalendar_modified,
                 etag: context[:etag]
               )
    end

    test "fails with incorrect etag" do
      assert {:error, :bad_etag} =
               @client
               |> CalDAVClient.Event.update(@event_url, @event_icalendar_modified, etag: "bad")
    end

    test "returns correct etag when event is updated", context do
      {:ok, etag} =
        @client
        |> CalDAVClient.Event.update(@event_url, @event_icalendar_modified, etag: context[:etag])

      assert {:ok, _icalendar, ^etag} = @client |> CalDAVClient.Event.get(@event_url)
    end
  end

  describe "when event is deleted" do
    setup do
      {:ok, etag} = @client |> CalDAVClient.Event.create(@event_url, @event_icalendar)

      [etag: etag]
    end

    test "passes without etag" do
      assert :ok = @client |> CalDAVClient.Event.delete(@event_url)
    end

    test "passes with correct etag", context do
      assert :ok = @client |> CalDAVClient.Event.delete(@event_url, etag: context[:etag])
    end

    test "fails with incorrect etag" do
      assert {:error, :bad_etag} = @client |> CalDAVClient.Event.delete(@event_url, etag: "bad")
    end
  end
end

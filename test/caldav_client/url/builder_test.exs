defmodule CalDAVClient.URL.BuilderTest do
  use ExUnit.Case, async: true
  doctest CalDAVClient.URL.Builder

  test "builds calendar URL" do
    assert CalDAVClient.URL.Builder.build_calendar_url("alice", "default") ==
             "/calendars/alice/default"
  end

  test "builds event URL" do
    assert CalDAVClient.URL.Builder.build_event_url("/calendars/alice/default", "event.ics") ==
             "/calendars/alice/default/event.ics"
  end
end

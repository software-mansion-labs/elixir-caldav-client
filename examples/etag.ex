client = %CalDAVClient.Client{
  server_url: "http://127.0.0.1:8800/cal.php",
  auth: :basic,
  username: "username",
  password: "password"
}

calendar_url = CalDAVClient.URL.Builder.build_calendar_url("username", "etag_demo")

event_url = CalDAVClient.URL.Builder.build_event_url(calendar_url, "event.ics")

event_before_icalendar = """
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

event_after_icalendar = """
BEGIN:VCALENDAR
PRODID:-//Elixir//CalDAV//EN
VERSION:2.0
BEGIN:VEVENT
UID:uid1@example.com
DTSTAMP:20210101T130000Z
DTSTART:20210101T130000Z
END:VEVENT
END:VCALENDAR
"""

try do
  :ok = client |> CalDAVClient.Calendar.create(calendar_url, name: "ETag example")

  {:ok, etag} = client |> CalDAVClient.Event.create(event_url, event_before_icalendar)

  {:ok, ^event_before_icalendar, ^etag} = client |> CalDAVClient.Event.get(event_url)

  {:error, :already_exists} =
    client |> CalDAVClient.Event.create(event_url, event_before_icalendar)

  {:error, :already_exists} =
    client |> CalDAVClient.Event.create(event_url, event_after_icalendar)

  {:error, :bad_etag} =
    client |> CalDAVClient.Event.update(event_url, event_before_icalendar, etag: "bad")

  {:error, :bad_etag} =
    client |> CalDAVClient.Event.update(event_url, event_after_icalendar, etag: "bad")

  {:ok, etag} = client |> CalDAVClient.Event.update(event_url, event_before_icalendar, etag: etag)

  {:ok, ^event_before_icalendar, ^etag} = client |> CalDAVClient.Event.get(event_url)

  {:ok, etag} = client |> CalDAVClient.Event.update(event_url, event_after_icalendar, etag: etag)

  {:ok, ^event_after_icalendar, ^etag} = client |> CalDAVClient.Event.get(event_url)

  {:error, :bad_etag} = client |> CalDAVClient.Event.delete(event_url, etag: "bad")

  :ok = client |> CalDAVClient.Event.delete(event_url, etag: etag)

  {:error, :not_found} = client |> CalDAVClient.Event.get(event_url)
after
  client |> CalDAVClient.Calendar.delete(calendar_url)
end

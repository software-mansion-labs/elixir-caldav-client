client = %CalDAVClient.Client{
  server_url: "http://127.0.0.1:8800/cal.php",
  auth: :basic,
  username: "username",
  password: "password"
}

calendar_url = CalDAVClient.URL.Builder.build_calendar_url("username", "event_demo")

event_url = CalDAVClient.URL.Builder.build_event_url(calendar_url, "event.ics")

event_uid = "uid1@example.com"

event_icalendar = """
BEGIN:VCALENDAR
PRODID:-//Elixir//CalDAV//EN
VERSION:2.0
BEGIN:VEVENT
UID:#{event_uid}
DTSTAMP:20210101T120000Z
DTSTART:20210101T120000Z
END:VEVENT
END:VCALENDAR
"""

try do
  :ok = client |> CalDAVClient.Calendar.create(calendar_url, name: "Event example")

  {:ok, etag} = client |> CalDAVClient.Event.create(event_url, event_icalendar)

  {:ok, ^event_icalendar, ^etag} = client |> CalDAVClient.Event.get(event_url)

  {:ok, %CalDAVClient.Event{icalendar: ^event_icalendar, etag: ^etag}} =
    client |> CalDAVClient.Event.find_by_uid(calendar_url, event_uid)

  {:ok, etag} = client |> CalDAVClient.Event.update(event_url, event_icalendar, etag: etag)

  :ok = client |> CalDAVClient.Event.delete(event_url, etag: etag)

  {:error, :not_found} = client |> CalDAVClient.Event.get(event_url)

  {:error, :not_found} = client |> CalDAVClient.Event.find_by_uid(calendar_url, event_uid)
after
  :ok = client |> CalDAVClient.Calendar.delete(calendar_url)
end

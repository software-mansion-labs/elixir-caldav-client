client = %CalDAVClient.Client{
  server_url: "http://127.0.0.1:8800/cal.php",
  auth: :basic,
  username: "username",
  password: "password"
}

calendar_url = CalDAVClient.URL.Builder.build_calendar_url("username", "default")

from = DateTime.from_naive!(~N[2021-02-01 00:00:00], "Europe/Warsaw")
to = DateTime.from_naive!(~N[2021-02-28 23:59:59], "Europe/Warsaw")

{:ok, events} = client |> CalDAVClient.Event.get_events(calendar_url, from, to, expand: false)
events |> IO.inspect(label: "get_events, expand: false")

{:ok, events} = client |> CalDAVClient.Event.get_events(calendar_url, from, to, expand: true)
events |> IO.inspect(label: "get_events, expand: true")

{:ok, events} =
  client |> CalDAVClient.Event.get_events_by_alarm(calendar_url, from, to, expand: false)

events |> IO.inspect(label: "get_events_by_alarm, expand: false")

{:ok, events} =
  client |> CalDAVClient.Event.get_events_by_alarm(calendar_url, from, to, expand: true)

events |> IO.inspect(label: "get_events_by_alarm, expand: true")

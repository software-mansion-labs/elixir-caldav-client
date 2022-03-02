# CalDAV Client

[![Hex.pm](https://img.shields.io/hexpm/v/caldav_client.svg)](https://hex.pm/packages/caldav_client)
[![API Docs](https://img.shields.io/badge/api-docs-brightgreen.svg)](https://hexdocs.pm/caldav_client/readme.html)


This library allows for managing calendars and events on a remote calendar server according to CalDAV specification ([RFC 4791](https://tools.ietf.org/html/rfc4791)). Supports time zones, recurrence expansion and ETags. Internally uses [Tesla](https://github.com/teamon/tesla) HTTP client.

Please note that conversion between native Elixir structures and iCalendar format ([RFC 5545](https://tools.ietf.org/html/rfc5545)) is beyond the scope of this library. The following packages are recommended:

* [ICalendar](https://github.com/lpil/icalendar)
* [Calibex](https://github.com/kbrw/calibex)

## Installation

CalDAV Client is published on [Hex](https://hex.pm/packages/caldav_client). Add it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:caldav_client, "~> 1.0"},

    # recommended time zone database
    {:tzdata, "~> 1.1"},

    # recommended Tesla adapter
    {:hackney, "~> 1.17"},
  ]
end
```

Then run `mix deps.get` to install the package and its dependencies.

It is also required to configure the time zone database and the default Tesla adapter in the `config/config.exs` of your project:

```elixir
# config/config.exs

import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :tesla, adapter: Tesla.Adapter.Hackney
```

> The default Tesla adapter is Erlang's built-in `httpc`, but currently it does not support custom HTTP methods such as `MKCALENDAR` or `REPORT`.

## Documentation

Available at [HexDocs](https://hexdocs.pm/caldav_client).

## Examples

### Client

The `%CalDAVClient.Client{}` struct aggregates the connection details such as the server address and user credentials.

```elixir
client = %CalDAVClient.Client{
  server_url: "http://127.0.0.1:8800/cal.php",
  auth: :basic,
  username: "username",
  password: "password"
}
```

Both HTTP Basic (`:basic`) and Digest (`:digest`) authentication methods are supported.

If your server needs Bearer authorization you can use `%CalDAVClient.BearerClient{}`:

```elixir
client = %CalDAVClient.BearerClient{
  server_url: "http://127.0.0.1:8800/cal.php",
  token: "token"
}
```

### Calendar

Each calendar user (or principal, according to CalDAV terminology) can have multiple calendars, which are identified by URLs.

```elixir
calendar_url = CalDAVClient.URL.Builder.build_calendar_url("username", "example")
# "/calendars/username/example"

:ok =
  client
  |> CalDAVClient.Calendar.create(calendar_url,
    name: "Example calendar",
    description: "This is an example calendar."
  )

:ok = client |> CalDAVClient.Calendar.update(calendar_url, name: "Lorem ipsum")

:ok = client |> CalDAVClient.Calendar.delete(calendar_url)
```

In case of any failure, `{:error, reason}` tuple will be returned.

### Event

```elixir
event_url = CalDAVClient.URL.Builder.build_event_url(calendar_url, "event.ics")
# "/calendars/username/example/event.ics"

event_icalendar = """
BEGIN:VCALENDAR
PRODID:-//Elixir//CalDAV//EN
VERSION:2.0
BEGIN:VEVENT
UID:totally-random-uid
DTSTAMP:20210101T120000Z
DTSTART:20210101T140000Z
END:VEVENT
END:VCALENDAR
"""

{:ok, etag} = client |> CalDAVClient.Event.create(event_url, event_icalendar)
```

`CalDAVClient.Event.create/3` returns
`{:error, :unsupported_media_type}` on malformed payload or `{:error, :already_exists}` when the specified URL is already taken (see [If-None-Match](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None-Match)).

You may get a single event by its URL address:

```elixir
{:ok, icalendar, etag} = client |> CalDAVClient.Event.get(event_url)
```

It is also possible to find the event with a specific `UID` property within the calendar:

```elixir
{:ok, %CalDAVClient.Event{url: url, icalendar: icalendar, etag: etag}} =
  client |> CalDAVClient.Event.find_by_uid(calendar_url, event_uid)
```

Both `CalDAVClient.Event.get/2` and `CalDAVClient.Event.find_by_uid/3` return
`{:error, :not_found}` when the event does not exist.

When modifying an event, you may optionally include the `etag` option in order to prevent simultaneous updates and ensure that the appropriate version of the event will be overwritten (see [ETag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag)).

```elixir
{:ok, etag} = client |> CalDAVClient.Event.update(event_url, event_icalendar, etag: etag)
```

```elixir
:ok = client |> CalDAVClient.Event.delete(event_url, etag: etag)
```

When `ETag` does not match, both `CalDAVClient.Event.update/4` and `CalDAVClient.Event.delete/3` return `{:error, :bad_etag}`.

### Events

CalDAV specification defines a way to retrieve all events that meet certain criteria, which can be used to list all events within a specified time range.

```elixir
from = DateTime.from_naive!(~N[2021-01-01 00:00:00], "Europe/Warsaw")
to = DateTime.from_naive!(~N[2021-02-01 00:00:00], "Europe/Warsaw")

{:ok, events} = client |> CalDAVClient.Event.get_events(calendar_url, from, to)
```

You may also pass `expand: true` option to enable recurrence expansion, which will force the calendar server to convert all events having the `RRULE` property into a series of occurrences within the specified time range with the `RECURRENCE-ID` property set.

```elixir
{:ok, events} = client |> CalDAVClient.Event.get_events(calendar_url, from, to, expand: true)
```

It is also possible to retrieve only the events with an alarm (`VALARM`) within a specified time range:

```elixir
{:ok, events} = client |> CalDAVClient.Event.get_events_by_alarm(calendar_url, from, to)
```

For custom event reports, pass the XML request body to `CalDAVClient.Event.get_events_by_xml/3` function:
```elixir
{:ok, events} = client |> CalDAVClient.Event.get_events_by_xml(calendar_url, request_xml)
```

In all cases above, `events` is a list of `%CalDAVClient.Event{}` structs with `url`, `icalendar` and `etag` fields.

## Testing

By default, `mix test` will execute only the unit tests which check XML building and parsing as well as URL generation and iCalendar date-time serialization.

The full test suite requires a connection to a calendar server, e.g. [Baïkal](https://github.com/sabre-io/Baikal) (Docker image available [here](https://hub.docker.com/r/ckulka/baikal)).
When installed and configured, create a test user account and provide credentials along with the server details in `config/test.exs` in this library.

> Please note that the test suite operates directly on the calendar server and will automatically create and delete the test calendar during execution.

```elixir
# config/test.exs

config :caldav_client, :test_server,
  server_url: "http://127.0.0.1:8800/cal.php",
  auth: :basic,
  username: "username",
  password: "password"
```

When configured, the test suite including integration tests can be executed by running:

```sh
mix test --include integration
```

## Copyright and License

Copyright 2021, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=elixir-caldav-client)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=elixir-caldav-client-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=elixir-caldav-client)

The code located in this repository is licensed under the [Apache License, Version 2.0](LICENSE).

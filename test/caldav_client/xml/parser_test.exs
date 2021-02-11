defmodule CalDAVClient.XML.ParserTest do
  use ExUnit.Case, async: true
  doctest CalDAVClient.XML.Parser

  test "parses events from XML response" do
    # https://tools.ietf.org/html/rfc4791#section-7.8.1

    xml = """
    <?xml version="1.0" encoding="utf-8" ?>
    <D:multistatus xmlns:D="DAV:"
                xmlns:C="urn:ietf:params:xml:ns:caldav">
      <D:response>
        <D:href>http://cal.example.com/bernard/work/abcd2.ics</D:href>
        <D:propstat>
          <D:prop>
            <D:getetag>"fffff-abcd2"</D:getetag>
            <C:calendar-data>BEGIN:VCALENDAR
    VERSION:2.0
    BEGIN:VTIMEZONE
    LAST-MODIFIED:20040110T032845Z
    TZID:US/Eastern
    BEGIN:DAYLIGHT
    DTSTART:20000404T020000
    RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=4
    TZNAME:EDT
    TZOFFSETFROM:-0500
    TZOFFSETTO:-0400
    END:DAYLIGHT
    BEGIN:STANDARD
    DTSTART:20001026T020000
    RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
    TZNAME:EST
    TZOFFSETFROM:-0400
    TZOFFSETTO:-0500
    END:STANDARD
    END:VTIMEZONE
    BEGIN:VEVENT
    DTSTART;TZID=US/Eastern:20060102T120000
    DURATION:PT1H
    RRULE:FREQ=DAILY;COUNT=5
    SUMMARY:Event #2
    UID:00959BC664CA650E933C892C@example.com
    END:VEVENT
    BEGIN:VEVENT
    DTSTART;TZID=US/Eastern:20060104T140000
    DURATION:PT1H
    RECURRENCE-ID;TZID=US/Eastern:20060104T120000
    SUMMARY:Event #2 bis
    UID:00959BC664CA650E933C892C@example.com
    END:VEVENT
    BEGIN:VEVENT
    DTSTART;TZID=US/Eastern:20060106T140000
    DURATION:PT1H
    RECURRENCE-ID;TZID=US/Eastern:20060106T120000
    SUMMARY:Event #2 bis bis
    UID:00959BC664CA650E933C892C@example.com
    END:VEVENT
    END:VCALENDAR
    </C:calendar-data>
          </D:prop>
          <D:status>HTTP/1.1 200 OK</D:status>
        </D:propstat>
      </D:response>
      <D:response>
        <D:href>http://cal.example.com/bernard/work/abcd3.ics</D:href>
        <D:propstat>
          <D:prop>
            <D:getetag>"fffff-abcd3"</D:getetag>
            <C:calendar-data>BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//Example Corp.//CalDAV Client//EN
    BEGIN:VTIMEZONE
    LAST-MODIFIED:20040110T032845Z
    TZID:US/Eastern
    BEGIN:DAYLIGHT
    DTSTART:20000404T020000
    RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=4
    TZNAME:EDT
    TZOFFSETFROM:-0500
    TZOFFSETTO:-0400
    END:DAYLIGHT
    BEGIN:STANDARD
    DTSTART:20001026T020000
    RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
    TZNAME:EST
    TZOFFSETFROM:-0400
    TZOFFSETTO:-0500
    END:STANDARD
    END:VTIMEZONE
    BEGIN:VEVENT
    DTSTART;TZID=US/Eastern:20060104T100000
    DURATION:PT1H
    SUMMARY:Event #3
    UID:DC6C50A017428C5216A2F1CD@example.com
    END:VEVENT
    END:VCALENDAR
    </C:calendar-data>
            </D:prop>
          <D:status>HTTP/1.1 200 OK</D:status>
        </D:propstat>
      </D:response>
    </D:multistatus>
    """

    actual = xml |> CalDAVClient.XML.Parser.parse_events()

    expected = [
      %CalDAVClient.Event{
        url: "http://cal.example.com/bernard/work/abcd2.ics",
        etag: "\"fffff-abcd2\"",
        icalendar: """
        BEGIN:VCALENDAR
        VERSION:2.0
        BEGIN:VTIMEZONE
        LAST-MODIFIED:20040110T032845Z
        TZID:US/Eastern
        BEGIN:DAYLIGHT
        DTSTART:20000404T020000
        RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=4
        TZNAME:EDT
        TZOFFSETFROM:-0500
        TZOFFSETTO:-0400
        END:DAYLIGHT
        BEGIN:STANDARD
        DTSTART:20001026T020000
        RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
        TZNAME:EST
        TZOFFSETFROM:-0400
        TZOFFSETTO:-0500
        END:STANDARD
        END:VTIMEZONE
        BEGIN:VEVENT
        DTSTART;TZID=US/Eastern:20060102T120000
        DURATION:PT1H
        RRULE:FREQ=DAILY;COUNT=5
        SUMMARY:Event #2
        UID:00959BC664CA650E933C892C@example.com
        END:VEVENT
        BEGIN:VEVENT
        DTSTART;TZID=US/Eastern:20060104T140000
        DURATION:PT1H
        RECURRENCE-ID;TZID=US/Eastern:20060104T120000
        SUMMARY:Event #2 bis
        UID:00959BC664CA650E933C892C@example.com
        END:VEVENT
        BEGIN:VEVENT
        DTSTART;TZID=US/Eastern:20060106T140000
        DURATION:PT1H
        RECURRENCE-ID;TZID=US/Eastern:20060106T120000
        SUMMARY:Event #2 bis bis
        UID:00959BC664CA650E933C892C@example.com
        END:VEVENT
        END:VCALENDAR
        """
      },
      %CalDAVClient.Event{
        url: "http://cal.example.com/bernard/work/abcd3.ics",
        etag: "\"fffff-abcd3\"",
        icalendar: """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//Example Corp.//CalDAV Client//EN
        BEGIN:VTIMEZONE
        LAST-MODIFIED:20040110T032845Z
        TZID:US/Eastern
        BEGIN:DAYLIGHT
        DTSTART:20000404T020000
        RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=4
        TZNAME:EDT
        TZOFFSETFROM:-0500
        TZOFFSETTO:-0400
        END:DAYLIGHT
        BEGIN:STANDARD
        DTSTART:20001026T020000
        RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
        TZNAME:EST
        TZOFFSETFROM:-0400
        TZOFFSETTO:-0500
        END:STANDARD
        END:VTIMEZONE
        BEGIN:VEVENT
        DTSTART;TZID=US/Eastern:20060104T100000
        DURATION:PT1H
        SUMMARY:Event #3
        UID:DC6C50A017428C5216A2F1CD@example.com
        END:VEVENT
        END:VCALENDAR
        """
      }
    ]

    assert actual == expected
  end
end

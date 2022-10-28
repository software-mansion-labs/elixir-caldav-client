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

  test "parses calendars from XML response" do
    xml = """
    <?xml version="1.0" encoding="utf-8"?>
        <d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:cal="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/" xmlns:card="urn:ietf:params:xml:ns:carddav">
      <d:response>
            <d:href>/calendars/blublub/</d:href>
        <d:propstat>
          <d:prop>
            <d:resourcetype>
              <d:collection/>
            </d:resourcetype>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
            <cal:supported-calendar-component-set/>
            <d:displayname/>
            <cal:calendar-timezone/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/journals/</d:href>
        <d:propstat>
          <d:prop>
            <cal:supported-calendar-component-set>
              <cal:comp name="VJOURNAL"/>
            </cal:supported-calendar-component-set>
            <d:resourcetype>
              <d:collection/>
              <cal:calendar/>
              <cs:shared-owner/>
            </d:resourcetype>
            <d:displayname>Journals</d:displayname>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
            <cal:calendar-timezone/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/home/</d:href>
        <d:propstat>
          <d:prop>
            <cal:supported-calendar-component-set>
              <cal:comp name="VEVENT"/>
            </cal:supported-calendar-component-set>
            <d:resourcetype>
              <d:collection/>
              <cal:calendar/>
              <cs:shared-owner/>
            </d:resourcetype>
            <d:displayname>Home</d:displayname>
            <cal:calendar-timezone>BEGIN:VCALENDAR&#xD;
    VERSION:2.0&#xD;
    PRODID:-//Apple Inc.//macOS 12.4//EN&#xD;
    CALSCALE:GREGORIAN&#xD;
    BEGIN:VTIMEZONE&#xD;
    TZID:Europe/Zurich&#xD;
    BEGIN:DAYLIGHT&#xD;
    TZOFFSETFROM:+0100&#xD;
    RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU&#xD;
    DTSTART:19810329T020000&#xD;
    TZNAME:CEST&#xD;
    TZOFFSETTO:+0200&#xD;
    END:DAYLIGHT&#xD;
    BEGIN:STANDARD&#xD;
    TZOFFSETFROM:+0200&#xD;
    RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU&#xD;
    DTSTART:19961027T030000&#xD;
    TZNAME:CET&#xD;
    TZOFFSETTO:+0100&#xD;
    END:STANDARD&#xD;
    END:VTIMEZONE&#xD;
    END:VCALENDAR&#xD;
    </cal:calendar-timezone>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/tasks/</d:href>
        <d:propstat>
          <d:prop>
            <cal:supported-calendar-component-set>
              <cal:comp name="VTODO"/>
            </cal:supported-calendar-component-set>
            <d:resourcetype>
              <d:collection/>
              <cal:calendar/>
              <cs:shared-owner/>
            </d:resourcetype>
            <d:displayname>Tasks</d:displayname>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
            <cal:calendar-timezone/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/work/</d:href>
        <d:propstat>
          <d:prop>
            <cal:supported-calendar-component-set>
              <cal:comp name="VEVENT"/>
            </cal:supported-calendar-component-set>
            <d:resourcetype>
              <d:collection/>
              <cal:calendar/>
              <cs:shared-owner/>
            </d:resourcetype>
            <d:displayname>Work</d:displayname>
            <cal:calendar-timezone>BEGIN:VCALENDAR&#xD;
    VERSION:2.0&#xD;
    PRODID:-//Apple Inc.//macOS 12.4//EN&#xD;
    CALSCALE:GREGORIAN&#xD;
    BEGIN:VTIMEZONE&#xD;
    TZID:Europe/Zurich&#xD;
    BEGIN:DAYLIGHT&#xD;
    TZOFFSETFROM:+0100&#xD;
    RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU&#xD;
    DTSTART:19810329T020000&#xD;
    TZNAME:CEST&#xD;
    TZOFFSETTO:+0200&#xD;
    END:DAYLIGHT&#xD;
    BEGIN:STANDARD&#xD;
    TZOFFSETFROM:+0200&#xD;
    RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU&#xD;
    DTSTART:19961027T030000&#xD;
    TZNAME:CET&#xD;
    TZOFFSETTO:+0100&#xD;
    END:STANDARD&#xD;
    END:VTIMEZONE&#xD;
    END:VCALENDAR&#xD;
    </cal:calendar-timezone>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/inbox/</d:href>
        <d:propstat>
          <d:prop>
            <d:resourcetype>
              <d:collection/>
              <cal:schedule-inbox/>
            </d:resourcetype>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
            <cal:supported-calendar-component-set/>
            <d:displayname/>
            <cal:calendar-timezone/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/outbox/</d:href>
        <d:propstat>
          <d:prop>
            <d:resourcetype>
              <d:collection/>
              <cal:schedule-outbox/>
            </d:resourcetype>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
    <d:propstat>
      <d:prop>
        <cal:calendar-description/>
        <cal:supported-calendar-component-set/>
        <d:displayname/>
        <cal:calendar-timezone/>
      </d:prop>
      <d:status>HTTP/1.1 404 Not Found</d:status>
    </d:propstat>
    </d:response>
    </d:multistatus>
    """

    actual = xml |> CalDAVClient.XML.Parser.parse_calendars()

    expected = [
      %CalDAVClient.Calendar{name: "", timezone: "", type: "", url: "/calendars/blublub/"},
      %CalDAVClient.Calendar{
        name: "Journals",
        timezone: "",
        type: "VJOURNAL",
        url: "/calendars/blublub/journals/"
      },
      %CalDAVClient.Calendar{
        name: "Home",
        timezone:
          "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Apple Inc.//macOS 12.4//EN\nCALSCALE:GREGORIAN\nBEGIN:VTIMEZONE\nTZID:Europe/Zurich\nBEGIN:DAYLIGHT\nTZOFFSETFROM:+0100\nRRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU\nDTSTART:19810329T020000\nTZNAME:CEST\nTZOFFSETTO:+0200\nEND:DAYLIGHT\nBEGIN:STANDARD\nTZOFFSETFROM:+0200\nRRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU\nDTSTART:19961027T030000\nTZNAME:CET\nTZOFFSETTO:+0100\nEND:STANDARD\nEND:VTIMEZONE\nEND:VCALENDAR\n",
        type: "VEVENT",
        url: "/calendars/blublub/home/"
      },
      %CalDAVClient.Calendar{
        name: "Tasks",
        timezone: "",
        type: "VTODO",
        url: "/calendars/blublub/tasks/"
      },
      %CalDAVClient.Calendar{
        name: "Work",
        timezone:
          "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Apple Inc.//macOS 12.4//EN\nCALSCALE:GREGORIAN\nBEGIN:VTIMEZONE\nTZID:Europe/Zurich\nBEGIN:DAYLIGHT\nTZOFFSETFROM:+0100\nRRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU\nDTSTART:19810329T020000\nTZNAME:CEST\nTZOFFSETTO:+0200\nEND:DAYLIGHT\nBEGIN:STANDARD\nTZOFFSETFROM:+0200\nRRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU\nDTSTART:19961027T030000\nTZNAME:CET\nTZOFFSETTO:+0100\nEND:STANDARD\nEND:VTIMEZONE\nEND:VCALENDAR\n",
        type: "VEVENT",
        url: "/calendars/blublub/work/"
      },
      %CalDAVClient.Calendar{
        name: "",
        timezone: "",
        type: "",
        url: "/calendars/blublub/inbox/"
      },
      %CalDAVClient.Calendar{
        name: "",
        timezone: "",
        type: "",
        url: "/calendars/blublub/outbox/"
      }
    ]

    assert actual == expected
  end

  test "parses principals from XML response" do
    # https://tools.ietf.org/html/rfc4791#section-6.2

    xml = """
<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:cal="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/" xmlns:card="urn:ietf:params:xml:ns:carddav">
  <d:response>
    <d:href>/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype>
          <d:collection/>
        </d:resourcetype>
        <d:current-user-principal>
          <d:href>/principals/mjb@migadu.ch/</d:href>
        </d:current-user-principal>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/principals/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype>
          <d:collection/>
        </d:resourcetype>
        <d:current-user-principal>
          <d:href>/principals/mjb@migadu.ch/</d:href>
        </d:current-user-principal>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/calendars/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype>
          <d:collection/>
        </d:resourcetype>
        <d:current-user-principal>
          <d:href>/principals/mjb@migadu.ch/</d:href>
        </d:current-user-principal>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/addressbooks/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype>
          <d:collection/>
        </d:resourcetype>
        <d:current-user-principal>
          <d:href>/principals/mjb@migadu.ch/</d:href>
        </d:current-user-principal>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
</d:multistatus>
    """

    actual = xml |> CalDAVClient.XML.Parser.parse_principal()
    expected = [
    ]

    assert actual == expected
    end
end

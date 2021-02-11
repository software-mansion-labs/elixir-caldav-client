defmodule CalDAVClient.XML.BuilderTest do
  import SweetXml
  use ExUnit.Case, async: true
  doctest CalDAVClient.XML.Builder

  test "generates create calendar XML request body" do
    # https://tools.ietf.org/html/rfc4791#section-5.3.1.2

    actual =
      CalDAVClient.XML.Builder.build_create_calendar_xml(
        name: "Lorem ipsum",
        description: "Zażółć gęślą jaźń"
      )

    expected = """
    <?xml version="1.0" encoding="utf-8" ?>
    <C:mkcalendar xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
      <D:set>
        <D:prop>
          <D:displayname>Lorem ipsum</D:displayname>
          <C:calendar-description xml:lang="en">Zażółć gęślą jaźń</C:calendar-description>
          <C:supported-calendar-component-set>
            <C:comp name="VEVENT"/>
          </C:supported-calendar-component-set>
        </D:prop>
      </D:set>
    </C:mkcalendar>
    """

    assert_xml_identical(actual, expected)
  end

  test "generates update calendar XML request body" do
    actual =
      CalDAVClient.XML.Builder.build_update_calendar_xml(
        name: "Lorem ipsum",
        description: "Zażółć gęślą jaźń"
      )

    expected = """
    <?xml version="1.0" encoding="UTF-8"?>
    <A:propertyupdate xmlns:A="DAV:">
      <A:set>
        <A:prop>
          <A:displayname>Lorem ipsum</A:displayname>
          <A:calendar-description xml:lang="en">Zażółć gęślą jaźń</A:calendar-description>
        </A:prop>
      </A:set>
    </A:propertyupdate>
    """

    assert_xml_identical(actual, expected)
  end

  test "generates retrieval of event by UID XML request body" do
    # https://tools.ietf.org/html/rfc4791#section-7.8.6

    uid = "DC6C50A017428C5216A2F1CD@example.com"
    actual = CalDAVClient.XML.Builder.build_retrieval_of_event_by_uid_xml(uid)

    expected = """
    <?xml version="1.0" encoding="utf-8" ?>
    <C:calendar-query xmlns:D="DAV:"
                      xmlns:C="urn:ietf:params:xml:ns:caldav">
      <D:prop>
        <D:getetag/>
        <C:calendar-data/>
      </D:prop>
      <C:filter>
        <C:comp-filter name="VCALENDAR">
          <C:comp-filter name="VEVENT">
            <C:prop-filter name="UID">
              <C:text-match collation="i;octet"
              >DC6C50A017428C5216A2F1CD@example.com</C:text-match>
            </C:prop-filter>
          </C:comp-filter>
        </C:comp-filter>
      </C:filter>
    </C:calendar-query>
    """

    assert_xml_identical(actual, expected)
  end

  test "generates retrieval of events in given time range XML request body" do
    # https://tools.ietf.org/html/rfc4791#section-7.8.1

    from = DateTime.from_naive!(~N[2006-01-03 00:00:00], "Etc/UTC")
    to = DateTime.from_naive!(~N[2006-01-05 00:00:00], "Etc/UTC")
    actual = CalDAVClient.XML.Builder.build_retrieval_of_events_xml(from, to, expand: false)

    expected = """
    <?xml version="1.0" encoding="utf-8" ?>
    <C:calendar-query xmlns:D="DAV:"
                      xmlns:C="urn:ietf:params:xml:ns:caldav">
      <D:prop>
        <D:getetag/>
        <C:calendar-data/>
      </D:prop>
      <C:filter>
        <C:comp-filter name="VCALENDAR">
          <C:comp-filter name="VEVENT">
            <C:time-range start="20060103T000000Z"
                          end="20060105T000000Z"/>
          </C:comp-filter>
        </C:comp-filter>
      </C:filter>
    </C:calendar-query>
    """

    assert_xml_identical(actual, expected)
  end

  test "generates expanded retrieval of recurring events in given time range XML request body" do
    # https://tools.ietf.org/html/rfc4791#section-7.8.3

    from = DateTime.from_naive!(~N[2006-01-03 00:00:00], "Etc/UTC")
    to = DateTime.from_naive!(~N[2006-01-05 00:00:00], "Etc/UTC")

    actual = CalDAVClient.XML.Builder.build_retrieval_of_events_xml(from, to, expand: true)

    expected = """
    <?xml version="1.0" encoding="utf-8" ?>
    <C:calendar-query xmlns:D="DAV:"
                      xmlns:C="urn:ietf:params:xml:ns:caldav">
      <D:prop>
        <D:getetag/>
        <C:calendar-data>
          <C:expand start="20060103T000000Z"
                    end="20060105T000000Z"/>
        </C:calendar-data>
      </D:prop>
      <C:filter>
        <C:comp-filter name="VCALENDAR">
          <C:comp-filter name="VEVENT">
            <C:time-range start="20060103T000000Z"
                          end="20060105T000000Z"/>
          </C:comp-filter>
        </C:comp-filter>
      </C:filter>
    </C:calendar-query>
    """

    assert_xml_identical(actual, expected)
  end

  test "generates retrieval of events having alarms in given time range XML request body" do
    # https://tools.ietf.org/html/rfc4791#section-7.8.5

    from = DateTime.from_naive!(~N[2006-01-03 00:00:00], "Etc/UTC")
    to = DateTime.from_naive!(~N[2006-01-05 00:00:00], "Etc/UTC")
    event_from = DateTime.from_naive!(~N[0000-01-01 00:00:00], "Etc/UTC")
    event_to = DateTime.from_naive!(~N[9999-12-31 23:59:59], "Etc/UTC")

    actual =
      CalDAVClient.XML.Builder.build_retrieval_of_events_having_alarm_xml(
        from,
        to,
        event_from: event_from,
        event_to: event_to,
        expand: false
      )

    expected = """
    <?xml version="1.0" encoding="UTF-8"?>
    <C:calendar-query xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
      <D:prop>
        <D:getetag/>
        <C:calendar-data/>
      </D:prop>
      <C:filter>
        <C:comp-filter name="VCALENDAR">
          <C:comp-filter name="VEVENT">
            <C:comp-filter name="VALARM">
              <C:time-range start="20060103T000000Z" end="20060105T000000Z"/>
            </C:comp-filter>
          </C:comp-filter>
        </C:comp-filter>
      </C:filter>
    </C:calendar-query>
    """

    assert_xml_identical(actual, expected)
  end

  test "generates expanded retrieval of recurring events having alarms in given time range XML request body" do
    from = DateTime.from_naive!(~N[2006-01-03 00:00:00], "Etc/UTC")
    to = DateTime.from_naive!(~N[2006-01-05 00:00:00], "Etc/UTC")
    event_from = DateTime.from_naive!(~N[0000-01-01 00:00:00], "Etc/UTC")
    event_to = DateTime.from_naive!(~N[9999-12-31 23:59:59], "Etc/UTC")

    actual =
      CalDAVClient.XML.Builder.build_retrieval_of_events_having_alarm_xml(
        from,
        to,
        event_from: event_from,
        event_to: event_to,
        expand: true
      )

    expected = """
    <?xml version="1.0" encoding="UTF-8"?>
    <C:calendar-query xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
      <D:prop>
        <D:getetag/>
        <C:calendar-data>
          <C:expand start="00000101T000000Z" end="99991231T235959Z"/>
        </C:calendar-data>
      </D:prop>
      <C:filter>
        <C:comp-filter name="VCALENDAR">
          <C:comp-filter name="VEVENT">
            <C:comp-filter name="VALARM">
              <C:time-range start="20060103T000000Z" end="20060105T000000Z"/>
            </C:comp-filter>
          </C:comp-filter>
        </C:comp-filter>
      </C:filter>
    </C:calendar-query>
    """

    assert_xml_identical(actual, expected)
  end

  defp assert_xml_identical(left, right) do
    assert parse(left) == parse(right)
  end
end

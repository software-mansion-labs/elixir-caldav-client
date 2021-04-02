defmodule CalDAVClient.ICalendar.SerializerTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  import CalDAVClient.ICalendar.Serializer

  test_with_params "serializes DateTime", fn datetime, expected ->
    assert serialize_datetime(datetime) == expected
  end do
    [
      {DateTime.from_naive!(~N[2001-01-01 00:00:00], "Etc/UTC"), {:ok, "20210101T000000Z"}},
      {DateTime.from_naive!(~N[2021-02-03 04:05:06.789], "Etc/UTC"), {:ok, "20010203T040506Z"}},
      {DateTime.from_naive!(~N[2021-01-01 13:00:00], "Europe/Warsaw"), {:ok, "20210101T120000Z"}},
      {DateTime.from_naive!(~N[2021-07-01 14:00:00], "Europe/Warsaw"), {:ok, "20210701T120000Z"}},
      {DateTime.from_naive!(~N[2021-01-01 07:00:00], "America/New_York"),
       {:ok, "20210101T120000Z"}},
      {DateTime.from_naive!(~N[2020-02-29 20:00:00], "America/New_York"),
       {:ok, "20200301T010000Z"}}
    ]
  end

  test_with_params "serializes NaiveDateTime", fn naive_datetime, expected ->
    assert serialize_naive_datetime(naive_datetime) == expected
  end do
    [
      {~N[2001-01-01 00:00:00], "20010101T000000"},
      {~N[2021-02-03 04:05:06.789], "20210203T040506"},
      {~N[2020-02-29 20:00:00], "20200229T200000"}
    ]
  end
end

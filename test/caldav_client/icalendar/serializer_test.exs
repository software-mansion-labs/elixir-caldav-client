defmodule CalDAVClient.ICalendar.SerializerTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  test_with_params "serializes datetime", fn datetime, expected ->
    assert CalDAVClient.ICalendar.Serializer.serialize_datetime(datetime) == expected
  end do
    [
      {DateTime.from_naive!(~N[2001-02-03 04:05:06], "Etc/UTC"), {:ok, "20010203T040506Z"}},
      {DateTime.from_naive!(~N[2021-01-01 12:00:00], "Etc/UTC"), {:ok, "20210101T120000Z"}},
      {DateTime.from_naive!(~N[2021-01-01 13:00:00], "Europe/Warsaw"), {:ok, "20210101T120000Z"}},
      {DateTime.from_naive!(~N[2021-07-01 14:00:00], "Europe/Warsaw"), {:ok, "20210701T120000Z"}},
      {DateTime.from_naive!(~N[2021-01-01 07:00:00], "America/New_York"),
       {:ok, "20210101T120000Z"}},
      {DateTime.from_naive!(~N[2020-02-29 20:00:00], "America/New_York"),
       {:ok, "20200301T010000Z"}}
    ]
  end
end

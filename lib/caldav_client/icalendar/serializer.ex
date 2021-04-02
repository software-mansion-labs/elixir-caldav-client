defmodule CalDAVClient.ICalendar.Serializer do
  @moduledoc """
  Serializes datetimes according to CalDAV specification.
  """

  @doc """
  Serializes `t:DateTime.t/0` shifted to UTC timezone to ISO 8601 basic string, e.g. `"20210401T123000Z"`
  (see [RFC 5545, section 3.3.5](https://tools.ietf.org/html/rfc5545#section-3.3.5)).
  """
  @spec serialize_datetime(DateTime.t()) :: {:ok, String.t()} | {:error, any()}
  def serialize_datetime(datetime) do
    with {:ok, datetime_utc} <- datetime |> DateTime.shift_zone("Etc/UTC") do
      {:ok, datetime_utc |> DateTime.truncate(:second) |> DateTime.to_iso8601(:basic)}
    end
  end

  @doc """
  Serializes `t:DateTime.t/0` or raises on errors.
  See `serialize_datetime/1` for more information.
  """
  @spec serialize_datetime!(DateTime.t()) :: String.t()
  def serialize_datetime!(datetime) do
    {:ok, datetime_icalendar} = serialize_datetime(datetime)
    datetime_icalendar
  end

  @doc """
  Serializes `t:NaiveDateTime.t/0` to ISO 8601 basic string, e.g. `"20210401T123000"`
  (see [RFC 5545, section 3.3.5](https://tools.ietf.org/html/rfc5545#section-3.3.5)).
  """
  @spec serialize_naive_datetime(NaiveDateTime.t()) :: String.t()
  def serialize_naive_datetime(naive_datetime) do
    naive_datetime |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_iso8601(:basic)
  end
end

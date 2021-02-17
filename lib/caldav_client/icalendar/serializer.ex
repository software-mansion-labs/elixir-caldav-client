defmodule CalDAVClient.ICalendar.Serializer do
  @moduledoc """
  Serializes datetimes according to CalDAV specification
  (see [RFC 5545, section 3.3.5](https://tools.ietf.org/html/rfc5545#section-3.3.5)).
  """

  @doc false
  @spec serialize_datetime(DateTime.t()) :: {:ok, String.t()} | {:error, any()}
  def serialize_datetime(datetime) do
    with {:ok, datetime_utc} <- datetime |> DateTime.shift_zone("Etc/UTC") do
      {:ok, datetime_utc |> DateTime.truncate(:second) |> DateTime.to_iso8601(:basic)}
    end
  end

  @doc false
  @spec serialize_datetime!(DateTime.t()) :: String.t()
  def serialize_datetime!(datetime) do
    {:ok, datetime_icalendar} = serialize_datetime(datetime)
    datetime_icalendar
  end
end

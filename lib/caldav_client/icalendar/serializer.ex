defmodule CalDAVClient.ICalendar.Serializer do
  @moduledoc """
  Serializes datetimes according to CalDAV specification
  (see [RFC 5545, section 3.3.5](https://tools.ietf.org/html/rfc5545#section-3.3.5)).
  """

  @doc false
  @spec serialize_datetime(DateTime.t()) :: {:ok, String.t()} | {:error, any()}
  def serialize_datetime(datetime) do
    with {:ok, datetime_utc} <- datetime |> DateTime.shift_zone("Etc/UTC"),
         {:ok, datetime_icalendar} <- datetime_utc |> Timex.format("{0YYYY}{0M}{0D}T{h24}{m}{s}Z") do
      {:ok, datetime_icalendar}
    end
  end

  @doc false
  @spec serialize_datetime!(DateTime.t()) :: String.t()
  def serialize_datetime!(datetime) do
    {:ok, datetime_icalendar} = serialize_datetime(datetime)
    datetime_icalendar
  end
end

defmodule CalDAVClient.Principal do
  @moduledoc """
  Allows for managing calendars on the calendar server.
  """

  import CalDAVClient.HTTP.Error
  import CalDAVClient.Tesla

  @type t :: %__MODULE__{
          current_user_principal: String.t(),
          resource_type: String.t()
        }
  @enforce_keys [:current_user_principal, :resource_type]
  defstruct @enforce_keys

  @xml_middlewares [
    CalDAVClient.Tesla.ContentTypeXMLMiddleware,
    CalDAVClient.Tesla.ContentLengthMiddleware
  ]

  @doc """
  Check credentials
  """
  @spec check(CalDAVClient.Client.t()) ::
          :ok | {:error, any()}
  def check(caldav_client) do
    case caldav_client
         |> make_tesla_client(@xml_middlewares)
         |> Tesla.request(
           method: :options,
           url: ""
         ) do
      {:ok, %Tesla.Env{status: 200, body: response_xml, headers: headers}} ->
        {:ok, headers}

      {:ok, %Tesla.Env{status: 401, body: response_xml}} ->
        {:error, :unauthorized}

      {:error, reason, body: response_xml} = error ->
        :error

      {:error, reason} = error ->
        :error
    end
  end

  @doc """
  Fetches principal information (see [RFC 4791, section 6.2](https://tools.ietf.org/html/rfc4791#section-6.2)).
  """
  @spec fetch(CalDAVClient.Client.t()) ::
          :ok | {:error, any()}
  def fetch(caldav_client) do
    case caldav_client
         |> make_tesla_client(@xml_middlewares)
         |> Tesla.request(
           method: :propfind,
           url: "",
           body: CalDAVClient.XML.Builder.build_fetch_principal_xml()
         ) do
      {:ok, %Tesla.Env{status: 207, body: response_xml}} ->
        calendars = response_xml |> CalDAVClient.XML.Parser.parse_principal()
        {:ok, calendars}

      {:ok, %Tesla.Env{status: code, body: response_xml}} ->
        {:error, reason_atom(code)}

      {:error, _reason, body: response_xml} = error ->
        :error
    end
  end
end

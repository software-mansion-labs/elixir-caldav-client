defmodule CalDAVClient.CalendarTest do
  use ExUnit.Case

  @moduletag :integration

  @server_url Application.get_env(:caldav_client, :test_server)[:server_url]
  @auth Application.get_env(:caldav_client, :test_server)[:auth]
  @username Application.get_env(:caldav_client, :test_server)[:username]
  @password Application.get_env(:caldav_client, :test_server)[:password]

  @client %CalDAVClient.Client{
    server_url: @server_url,
    auth: @auth,
    username: @username,
    password: @password
  }

  @calendar_id "calendar_test"
  @calendar_url CalDAVClient.URL.Builder.build_calendar_url(@username, @calendar_id)

  setup do
    on_exit(fn -> @client |> CalDAVClient.Calendar.delete(@calendar_url) end)
    :ok
  end

  describe "when calendar does not exist" do
    test "returns ok on calendar create" do
      assert :ok =
               @client
               |> CalDAVClient.Calendar.create(@calendar_url,
                 name: "Name",
                 description: "Description"
               )
    end

    test "returns error not found on calendar update" do
      assert {:error, :not_found} = @client |> CalDAVClient.Calendar.update(@calendar_url)
    end

    test "returns error not found on calendar delete" do
      assert {:error, :not_found} = @client |> CalDAVClient.Calendar.delete(@calendar_url)
    end
  end

  describe "when calendar exists" do
    setup do
      :ok =
        @client
        |> CalDAVClient.Calendar.create(@calendar_url, name: "Name", description: "Description")

      :ok
    end

    test "returns error already exists on calendar create" do
      assert {:error, :already_exists} =
               @client
               |> CalDAVClient.Calendar.create(@calendar_url,
                 name: "Name",
                 description: "Description"
               )
    end

    test "returns ok on calendar update" do
      assert :ok =
               @client
               |> CalDAVClient.Calendar.update(@calendar_url,
                 name: "Name2",
                 description: "Description2"
               )
    end

    test "returns ok on calendar delete" do
      assert :ok = @client |> CalDAVClient.Calendar.delete(@calendar_url)
    end
  end
end

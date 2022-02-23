defmodule CalDAVClient.TeslaTest do
  use ExUnit.Case, async: true

  describe "make_tesla_client/2" do
    test "supports bearer auth" do
      client = %CalDAVClient.Client{
        server_url: "http://127.0.0.1:8800/cal.php",
        auth: :bearer,
        username: "",
        password: "",
        token: "token"
      }

      tesla = CalDAVClient.Tesla.make_tesla_client(client, [])

      assert [_, {Tesla.Middleware.BearerAuth, :call, [[token: "token"]]}] = tesla.pre
    end

    test "raises an error if token is missing" do
      client = %CalDAVClient.Client{
        server_url: "http://127.0.0.1:8800/cal.php",
        auth: :bearer,
        username: "",
        password: ""
      }

      assert_raise(RuntimeError, "Bearer token is missing", fn ->
        CalDAVClient.Tesla.make_tesla_client(client, [])
      end)
    end
  end
end

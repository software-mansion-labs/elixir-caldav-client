defmodule CalDAVClient.TeslaTest do
  use ExUnit.Case, async: true

  describe "make_tesla_client/2" do
    test "supports bearer client" do
      client = %CalDAVClient.BearerClient{
        server_url: "https://example.com",
        token: "token"
      }

      tesla = CalDAVClient.Tesla.make_tesla_client(client, [])

      assert [_, {Tesla.Middleware.BearerAuth, :call, [[token: "token"]]}] = tesla.pre
    end
  end
end

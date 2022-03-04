defmodule CalDAVClient.TeslaTest do
  use ExUnit.Case, async: true

  describe "make_tesla_client/2" do
    test "supports bearer client" do
      client = %CalDAVClient.Client{
        server_url: "https://example.com",
        auth: %CalDAVClient.Auth.Bearer{
          token: "token"
        }
      }

      tesla = CalDAVClient.Tesla.make_tesla_client(client, [])

      assert [_, {Tesla.Middleware.BearerAuth, :call, [[token: "token"]]}] = tesla.pre
    end
  end
end

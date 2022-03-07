defmodule CalDAVClient.TeslaTest do
  use ExUnit.Case, async: true

  describe "make_tesla_client/2" do
    test "supports Bearer authentication" do
      client = %CalDAVClient.Client{
        server_url: "https://example.com",
        auth: %CalDAVClient.Auth.Bearer{
          token: "token"
        }
      }

      tesla = CalDAVClient.Tesla.make_tesla_client(client, [])

      assert [_, {Tesla.Middleware.BearerAuth, :call, [[token: "token"]]}] = tesla.pre
    end

    test "supports Basic authentication" do
      client = %CalDAVClient.Client{
        server_url: "https://example.com",
        auth: %CalDAVClient.Auth.Basic{
          username: "username",
          password: "password"
        }
      }

      tesla = CalDAVClient.Tesla.make_tesla_client(client, [])

      assert [
               _,
               {Tesla.Middleware.BasicAuth, :call,
                [%{username: "username", password: "password"}]}
             ] = tesla.pre
    end

    test "supports Digest authentication" do
      client = %CalDAVClient.Client{
        server_url: "https://example.com",
        auth: %CalDAVClient.Auth.Digest{
          username: "username",
          password: "password"
        }
      }

      tesla = CalDAVClient.Tesla.make_tesla_client(client, [])

      assert [
               _,
               {Tesla.Middleware.DigestAuth, :call,
                [%{username: "username", password: "password"}]}
             ] = tesla.pre
    end
  end
end

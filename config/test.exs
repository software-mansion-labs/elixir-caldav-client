import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :tesla, adapter: Tesla.Adapter.Hackney

config :caldav_client, :test_server,
  server_url: "http://127.0.0.1:8800/cal.php",
  username: "username",
  password: "password"

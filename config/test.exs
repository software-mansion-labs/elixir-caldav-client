import Config

config :caldav_client, :test_server,
  server_url: "http://127.0.0.1:8800/cal.php",
  auth: :basic,
  username: "username",
  password: "password"

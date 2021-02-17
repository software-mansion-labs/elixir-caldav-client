import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :tesla, adapter: Tesla.Adapter.Hackney

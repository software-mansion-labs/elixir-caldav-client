import Config

# required for timezone support
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# required, otherwise custom HTTP verb MKCALENDAR will not work
config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{config_env()}.exs"

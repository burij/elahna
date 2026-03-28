# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.

import Config

config :elahna, ElahnaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ElahnaWeb.ErrorHTML, json: ElahnaWeb.ErrorJSON],
    layout: false
  ]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"

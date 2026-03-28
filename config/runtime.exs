import Config

if System.get_env("PHX_SERVER") do
  config :elahna, ElahnaWeb.Endpoint, server: true
end

config :elahna, ElahnaWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

if config_env() == :prod do
  config :elahna, :content_storage, System.get_env("CONTENT_PATH") || "/var/www/content"

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"

  config :elahna, ElahnaWeb.Endpoint,
    url: [
      host: host,
      port: String.to_integer(System.get_env("PHX_URL_PORT", "443")),
      scheme: System.get_env("PHX_URL_SCHEME", "https")
    ],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT", "4000"))
    ],
    secret_key_base: secret_key_base
end

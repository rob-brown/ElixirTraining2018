use Mix.Config

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.
config :shoehorn,
  init: [:nerves_runtime, :nerves_network],
  app: Mix.Project.config()[:app]

config :nerves_network,
  regulatory_domain: "US"

key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "NONE"

config :nerves_network, :default,
  wlan0: [
    ssid: System.get_env("NERVES_NETWORK_SSID") || "Tracy",
    psk: System.get_env("NERVES_NETWORK_PSK") || "",
    key_mgmt: String.to_atom(key_mgmt)
  ],
  eth0: [
    ipv4_address_method: :dhcp
  ]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.Project.config[:target]}.exs"

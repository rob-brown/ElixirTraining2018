use Mix.Config

config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget, :nerves_network],
  app: Mix.Project.config()[:app]

config :nerves_init_gadget,
  ifname: "usb0",
  address_method: :linklocal,
  mdns_domain: "nerves.local",
  node_name: nil,
  node_host: :mdns_domain

config :logger, backends: [RingLogger]

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!, ".ssh/id_rsa.pub"))
  ]

config :nerves_leds, names: [ green: "led0" ]

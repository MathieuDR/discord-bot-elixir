import(Config)

config :logger, level: :notice

config :logger, :default_formatter,
  format: {Bot.Shared.ConsoleLogger, :format},
  metadata: :all

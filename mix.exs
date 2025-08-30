defmodule Bot.MixProject do
  use Mix.Project

  def project do
    env = Mix.env()

    [
      app: :bot,
      version: "0.1.0",
      elixir: "~> 1.19-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps(env)
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer, :wx, :runtime_tools],
      mod: {Bot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps(env) do
    Enum.concat([
      deps_for(:dev_experience, env),
      deps_for(:linting, env),
      deps_for(:testing, env),
      deps_for(:telemetry_and_metrics, env)
    ])
  end

  defp deps_for(:dev_experience, _env) do
    [
      {:typedstruct, "~> 0.5"}
    ]
  end

  defp deps_for(:linting, _env) do
    [
      # linting
      {:credo, ">= 1.7.0", only: [:test, :dev], runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:test, :dev], runtime: false},
      {:styler, "~> 1.6", only: [:test, :dev], runtime: false}
    ]
  end

  defp deps_for(:testing, _env) do
    [
      {:mimic, "~> 2.0", only: :test}
    ]
  end

  defp deps_for(:telemetry_and_metrics, _env) do
    [
      {:logger_json, "~> 7.0"}
    ]
  end
end

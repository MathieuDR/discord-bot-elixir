defmodule Bot.Discord.Connection do
  @moduledoc """
  A gen statem to manage my socket!

  States
  - Disconnected
  - Requesting URL
  - Opening WSS
  - Connected
  - Reconnecting
  """

  @behaviour :gen_statem
  @name :human_sattem

  def child_spec(opts) do
    IO.inspect(opts, label: "child_spec")

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(args) do
    IO.inspect(args, label: "start link")
    :gen_statem.start_link({:local, @name}, __MODULE__, args, [])
  end

  @impl true
  def init(args) do
    IO.inspect(args, label: "init")
    {:ok, :disconnected, args}
  end

  ## API
  def hello do
    :gen_statem.call(@name, :hello)
  end

  def bye do
    :gen_statem.call(@name, :bye)
  end

  @impl true
  def callback_mode, do: :state_functions

  def disconnected({:call, from}, :hello, data) do
    IO.inspect(data, label: "disconnected")
    {:next_state, :connected, data, [{:reply, from, :bla}]}
  end

  def connected({:call, from}, :bye, data) do
    IO.inspect(data, label: "connected")
    {:next_state, :disconnected, data, [{:reply, from, :bla}]}
  end
end

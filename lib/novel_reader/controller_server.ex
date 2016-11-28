defmodule NovelReader.ControllerServer do
  use GenServer
  require Logger

  @name {:global, __MODULE__}

  @initial_state %{socket: nil}
  @port 2000

  def start_link do
    case GenServer.start_link(__MODULE__, @initial_state, name: @name) do
      {:ok, pid} ->
        Logger.info "Started #{__MODULE__}"
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        Logger.info "#{__MODULE__} already started"
        {:ok, pid}
    end
  end

  def init(state) do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.listen(@port, opts)
    {:ok, %{state | socket: socket}}
  end

  # TODO
  # Add a loop that listens on the socket and delegates commands to functions.
  # Add a 'worker pool' to the state.
end

defmodule NovelReader.Controller do
  @moduledoc """
  Acts as the medium for the Electron GUI to communicate with the Elixir application
  through sockets.

  Listens on a loop for 'requests'.

  Returns the requested data for the GUI to display.

  """

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

    case :gen_tcp.listen(@port, opts) do
      {:ok, socket} -> {:ok, %{state | socket: socket}}
      {:error, :eaddrinuse} -> {:stop, "Port in use."}
    end
  end

  # TODO
  # Add a loop that listens on the socket and delegates commands to functions.
  # Add a 'worker pool' to the state.
end

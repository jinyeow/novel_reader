defmodule NovelReader.CacheServer do
  use GenServer
  require Logger

  @moduledoc """
  Contains a 'cache' of recently retrieved chapters.
  """

  @name {:global, __MODULE__}

  ## Client

  @doc """
  Add a retrieved chapter to the cache.
  """
  def add(id, chapter_content) do
    GenServer.call(@name, {:add, id, chapter_content})
  end

  @doc """
  List the contents of the cache.
  """
  def list do
    GenServer.call(@name, :list)
  end

  ## Callbacks

  def start_link do
    case GenServer.start_link(__MODULE__, %{}, name: @name) do
      {:ok, pid} ->
        Logger.info "Started #{__MODULE__}"
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        Logger.info "#{__MODULE__} already started"
        {:ok, pid}
    end
  end

  def handle_call({:add, id, chapter_content}, _from, cache) do
    cache = Map.put(cache, id, chapter_content)
    {:reply, cache, cache}
  end

  def handle_call(:list, _from, cache) do
    {:reply, cache, cache}
  end

  # TODO save state before shutdown
  def terminate(_reason, state) do
    state
  end
end

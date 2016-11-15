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

  @doc """
  Return a chapter from the cache.
  """
  def get(id) do
    GenServer.call(@name, {:get, id})
  end

  def in_cache?(id) do
    GenServer.call(@name, {:in_cache, id})
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
    cache = case Map.has_key?(cache, id) do
      false -> Map.put(cache, id, chapter_content)
      _ -> cache
    end

    {:reply, cache, cache}
  end

  def handle_call(:list, _from, cache) do
    {:reply, cache, cache}
  end

  def handle_call({:get, id}, _from, cache) do
    case Map.get(cache, id) do
      nil -> {:reply, {:error, :not_in_cache}, cache}
      content -> {:reply, {:ok, content}, cache}
    end
  end

  def handle_call({:in_cache, id}, _from, cache) do
    {:reply, Map.has_key?(cache, id), cache}
  end

  # TODO save state before shutdown
  def terminate(_reason, state) do
    state
  end
end

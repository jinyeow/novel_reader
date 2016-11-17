defmodule NovelReader.CacheServer do
  use GenServer
  require Logger

  @moduledoc """
  Contains a 'cache' of recently retrieved chapters. In the form of:
    cache = %{
              "title" =>
                %{
                  "url" => "https://url.to.novel",
                  "chapter" => "https://url.to.chapter"
                }
            }

  Save novel metadata in the format:
    {
      'title': {title},
      'chapter': {number of saved chapters},
      'url': {url to novel},
      'last_updated': {date of last update}
    }

  Save/Load novels and chapter to:
    $HOME/.novel_reader/novels/{title}.novel/{chapter}.chapter

  Cache path:
    $HOME/.novel_reader/cache/{cache_entry}.json

  """

  # TODO update cache format and functions
  # TODO Implement GenServer.init to populate the cache on startup with saved
  #      chapters from the cache directory: load_cache/0
  # TODO Implement GenServer.terminate to save the downloaded chapters on
  #      shutdown: save_cache/0
  # TODO Implement load/save_{chapter,novel}/1 to load/save a specific chapter

  @name {:global, __MODULE__}

  @type id :: String.t

  # TODO test this works
  @home System.get_env("HOME")
  @novels_dir @home <> "/.novel_reader/novels/"
  @cache_dir @home <> "/.novel_reader/cache/"

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
  def get(title, id) do
    GenServer.call(@name, {:get, title, chapter})
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
    # try 'cache = Map.put_new(cache, id, content)' instead
    cache = case Map.has_key?(cache, id) do
      false -> Map.put(cache, id, chapter_content)
      _ -> cache
    end

    {:reply, cache, cache}
  end

  def handle_call(:list, _from, cache) do
    {:reply, cache, cache}
  end

  # TODO test this works
  def handle_call({:get, title, chapter}, _from, cache) do
    case chapter_cached?(cache, title, chapter) do
      {:error, reason}       -> {:reply, {:error, reason}, cache}
      {:ok, :cache, content} -> {:reply, {:ok, content}, cache}
      {:ok, :file, content}  ->
        cache = refresh_cache(cache, title, chapter, content)
        {:reply, {:ok, content}, cache}
    end
  end

  def handle_call({:in_cache, id}, _from, cache) do
    {:reply, Map.has_key?(cache, id), cache}
  end

  ## PRIVATE

  # defp load_chapter_from_file(title, chapter) do
  # end

  # defp save_chapter_to_file(chapter) do
  # end

  defp refresh_cache(cache, title, chapter, content) do
    cache
    |> Map.put_new(title, %{})
    |> Map.update!(title, fn chapters ->
      Map.put_new(chapters, chapter, content)
    end)
  end

  defp chapter_cached?(cache, title, chapter) do
    case cache[title][chapter] do
      nil -> chapter_saved?(title, chapter)
      content -> {:ok, :cache, content}
    end
  end

  defp chapter_saved?(title, chapter) do
    file = @novels_dir <> title <> ".novel/" <> chapter <> ".html"
    case File.exists?(file) do
      false -> {:error, :not_cached_or_saved}
      true ->
        {:ok, content} = File.read(file)
        {:ok, :file, content}
    end
  end
end

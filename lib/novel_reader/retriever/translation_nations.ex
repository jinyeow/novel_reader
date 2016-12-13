defmodule NovelReader.Retriever.TranslationNations do
  @moduledoc false

  @behaviour NovelReader.Retriever

  import NovelReader.Helper

  alias NovelReader.Chapter

  def get(url) do
    case page_type(url) do
      :post ->
        with {:ok, page} <- get_page(url),
             url <- parse_post_page(page),
             {:ok, page} <- get_page(url) do
          parse_chapter_page(page)
        else
          {:error, reason} -> {:error, reason}
        end
      :chapter ->
        with {:ok, page} <- get_page(url) do
          parse_chapter_page(page)
        else
          {:error, reason} -> {:error, reason}
        end
      :novel -> {:error, "To be implemented."}
      {:error, reason} -> {:error, reason}
    end
  end

  def page_type(url) do
    {:ok, head} = HTTPoison.head(url)

    url =
      case head.headers |> Map.new do
        %{"Location" => url} -> url
        _ -> url
      end

    cond do
      ! (url =~ ~r/\/translations\//) -> :post
      url =~ ~r/\/translations\/.+-chapter-/ -> :chapter
      ! (url =~ ~r/chapter/) -> :novel
      :else -> {:error, "Unidentified page type."}
    end
  end

  def parse_post_page(page) do
    %HTTPoison.Response{body: body} = page

    link =
      body
      |> Floki.find(".entry-content a")
      |> Enum.filter(fn elem ->
        elem
        |> Floki.attribute("href")
        |> hd =~ ~r/-chapter-[0-9]+/
      end)
      |> hd

    link
    |> Floki.attribute("href")
    |> hd
  end

  def parse_chapter_page(page) do
    %HTTPoison.Response{body: body} = page
    %Chapter{
      content: get_content(body),
      next: get_next(body),
      prev: get_prev(body),
      novel: get_novel(body),
      title: get_title(body),
      chapter: get_chapter(body)
    }
  end

  def get_content(body) do
    {_tag, _attr, content} =
      body
      |> Floki.find("div[class='entry-content clear']")
      |> hd

    Floki.DeepText.get(content, "\n")
  end

  def get_next(body) do
    case body
    |> Floki.find("div.entry-content p a")
    |> Enum.filter(fn sel -> Floki.text(sel) =~ ~r/Next Chapter/ end)
    |> Enum.uniq do
      [] -> nil
      list ->
        list
        |> hd
        |> Floki.attribute("href")
        |> hd
    end
  end

  def get_prev(body) do
    case body
    |> Floki.find("div.entry-content p a")
    |> Enum.filter(fn sel -> Floki.text(sel) =~ ~r/Previous Chapter/ end)
    |> Enum.uniq do
      [] -> nil
      list ->
        list
        |> hd
        |> Floki.attribute("href")
        |> hd
    end
  end

  def get_novel(body) do
    novel_text=
      body
      |> Floki.find("h1.entry-title")
      |> hd
      |> Floki.text

    Regex.named_captures(
       ~r/(?<novel>\w+(\s[A-Za-z]+)+)( Volume [0-9]+)* Chapter [0-9]+/i,
       novel_text
    )["novel"]
  end

  def get_title(body) do
    results =
      case Floki.find(body, "div.entry-content p b") do
        [] -> Floki.find(body, "div.entry-content p strong")
        results -> results
      end

    results
    |> hd
    |> Floki.text
    |> String.split(~r/[:\-–]/, trim: true)
    |> List.last
    |> String.trim
  end

  def get_chapter(body) do
    results =
      case Floki.find(body, "div.entry-content p b") do
        [] -> Floki.find(body, "div.entry-content p strong")
        results -> results
      end

    results
    |> hd
    |> Floki.text
    |> String.split(~r/[:\-–]/, trim: true)
    |> List.first
    |> String.trim

    # for some reason :chapter comes out as a binary
    # To view it in string form, do:
    #   Enum.join(for <<c::utf8 <- ss[:chapter]>>, do <<c::utf8>>)
  end
end

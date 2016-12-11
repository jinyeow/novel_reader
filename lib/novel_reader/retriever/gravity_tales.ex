defmodule NovelReader.Retriever.GravityTales do
  @moduledoc false

  @behaviour NovelReader.Retriever

  import NovelReader.Helper

  alias NovelReader.Chapter

  @base_url "http://gravitytales.com/"

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
      url =~ ~r/\/post\// -> :post
      url =~ ~r/\/novel\/.+-chapter-/ -> :chapter
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
    |> String.replace("../../", @base_url)
  end

  def parse_chapter_page(page) do
    %HTTPoison.Response{body: body} = page
    %Chapter{
      content: get_content(body)
      # TODO get_{next,prev,novel,title,chapter}
    }
  end

  def get_content(body) do
    {_div, _attr, content} =
      body
      |> Floki.find("div.innerContent")
      |> hd

    Floki.DeepText.get(content, "\n")
  end
end

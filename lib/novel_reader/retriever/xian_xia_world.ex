defmodule NovelReader.Retriever.XianXiaWorld do
  @moduledoc false

  @behaviour NovelReader.Retriever

  import NovelReader.Helper

  alias NovelReader.Chapter

  def get(url) do
    with {:ok, page} <- get_page(url) do
      parse_chapter_page(page)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def parse_chapter_page(page) do
    %HTTPoison.Response{body: body} = page
    %Chapter{
      content: get_content(body)
    }
  end

  def get_content(body) do
    {_tag, _attr, child} =
      body
      |> Floki.find("#content")
      |> hd

    child
    |> Enum.filter(&is_binary/1)
    |> Enum.join("\n")
  end
end

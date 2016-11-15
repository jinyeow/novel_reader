defmodule NovelReader.Retriever.WuxiaWorld do
  @behaviour NovelReader.Retriever

  def get(url) do
    case url |> HTTPoison.get([], [follow_redirect: true]) do
      {:ok, page} -> find_content(page)
      {:error, reason} -> {:error, reason}
    end
  end

  defp find_content(page) do
    %HTTPoison.Response{body: body} = page

    link = Floki.find(body, ".entry-content a")
           |> Enum.filter(fn elem ->
             Floki.attribute(elem, "href")
             |> hd =~ ~r/-chapter-[0-9]+/
           end)
           |> hd

    url = Floki.attribute(link, "href")
          |> hd

    {:ok, page} = HTTPoison.get(url, [], [follow_redirect: true])
    %HTTPoison.Response{body: body} = page

    {_tag, _attr, content} = Floki.find(body, "div[itemprop='articleBody']")
                             |> hd

    content |> Floki.DeepText.get("\n")
  end
end

defmodule NovelReader.Retriever.WuxiaWorld do
  @behaviour NovelReader.Retriever

  def get(url) do
    {:ok, page} = url
                  |> HTTPoison.get([], [follow_redirect: true])

    %HTTPoison.Response{body: body} = page
    {_tag, attr, _child} = Floki.find(body, ".entry-content a")
                             |> Enum.filter(fn {_tag, _attr, child} ->
                               Floki.text(child) =~ ~r/^Chapter [0-9]+$/
                             end)
                             |> hd

    {_attr, url} = attr |> hd

    {:ok, page} = HTTPoison.get(url, [], [follow_redirect: true])
    %HTTPoison.Response{body: body} = page

    # NOTE currently this returns a big blob of text
    # TODO I want to get the HTML and transform it into text while keeping the
    # newlines and spacing, etc.
    Floki.find(body, ".entry-content p") |> Floki.text
  end
end

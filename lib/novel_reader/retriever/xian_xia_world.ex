defmodule NovelReader.Retriever.XianXiaWorld do
  @behaviour NovelReader.Retriever

  def get(url) do
    case url |> HTTPoison.get([], [follow_redirect: true]) do
      {:ok, page} -> find_content(page)
      {:error, reason} -> {:error, reason}
    end
  end

  # TODO: check that this works, taken from example.txt
  defp find_content(page) do
    %HTTPoison.Response{body: body} = page
    {_tag, _attr, child} = Floki.find(body, "#content") |> hd

    chapter |> Enum.filter(&is_binary/1)
  end
end

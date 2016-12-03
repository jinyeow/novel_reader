defmodule NovelReader.RetrieverTest do
  use ExUnit.Case, async: true
  doctest NovelReader.Retriever

  alias NovelReader.Retriever

  test "get_from_url/1 returns an error if url is invalid." do
    invalid_url = "not.a.valid.url"
    ret         = Retriever.get_from_url(invalid_url)

    assert ret == {:error, :invalid_url}
  end

  test "retriever/1 returns an error if given an unknown or invalid translator string" do
    translator = "Some Unknown Tranlsator"
    ret        = Retriever.retriever(translator)

    assert ret == {:error, :translator_unknown}
  end

  @tag :pending
  test "a successful retrieval returns a Chapter.t struct" do
    assert false
  end
end

defmodule NovelReader.Model.Chapter do
  @behaviour Access

  alias NovelReader.Model.Chapter

  defstruct [
    :title,
    :content,
    :next,
    :prev
  ]

  # next/prev either a url/file path
  # content most likely will be in HTML and will be converted later?
  @type t :: %Chapter{
    title:   String.t,
    content: String.t,
    next:    String.t,
    prev:    String.t
  }

  def format(chapter, :html), do: chapter[:content]
  def format(chapter, :text), do: chapter[:content] |> Floki.DeepText.get("\n")

  # TODO def save/load chapter

  ## Access Callbacks

  def fetch(chapter, key) do
    Map.fetch(chapter, key)
  end

  def get(t, key, _default), do: __MODULE__.fetch(t, key)
  def get_and_update(_t, _key, _fun) do; end
  def pop(_t, _key) do; end
end

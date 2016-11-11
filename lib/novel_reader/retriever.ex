defmodule NovelReader.Retriever do
  @moduledoc """
  This handles getting actual chapter content/text from the respective
  translation websites (e.g. WuxiaWorld, XianXiaWorld, Gravity Tales).

  It should store the chapter in [memory|text|ets] ?

               |--TaskSupervisor := async tasks ?
               |--NovelUpdates := communicate with NU and get chapter updates
  NovelReader--|--GUI := display information using Electron
               |--Retriever := pull chapter text
  """

end

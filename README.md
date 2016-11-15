# NovelReader

Read CN/JP/KR translated novels in a desktop app.
GUI using Electron UI.
Pull updates from novelupdates.com rss feeds
Grab chapters from links and display in app.

               |--TaskSupervisor := async tasks
               |--NovelUpdates   := communicate with NU and get chapter updates
  NovelReader--|--GUI            := display information using Electron
               |--Retriever      := pull chapter text


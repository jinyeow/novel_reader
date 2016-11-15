# NovelReader

Read CN/JP/KR translated novels in a desktop app.
GUI using Electron UI.
Pull updates from novelupdates.com rss feeds
Grab chapters from links and display in app.

## Supervision Tree

NovelReader:
  - TaskSupervisor := async tasks
  - NovelUpdates   := communicate with NU and get chapter updates
  - Retriever      := pull chapter text (and cache them?)
  - RequestHandler := handles connection with Electron GUI via sockets/RabbitMQ
  - GUI            := display information using Electron


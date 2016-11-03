# Example

## TODO

### Test/Example/Actual Feed URL
use http://www.novelupdates.com/rss.php?uid=12590&unq=571077742187a&type=read
as feed/test feed.

### Example of chapter update Map:
%{description: "(XianXiaWorld) Series Information: http://www.novelupdates.com/series/
  realms-in-the-firmament/",
  image: nil,
  pubdate: #<DateTime(4016-11-03T00:00:00Z)>,
  tags: [],
  title: "Realms In The Firmament c204",
  url: "http://www.novelupdates.com/extnu/327112/"}

### Possible initial process to grab chapters:
* Grab feed:
  feed = Scrape.feed FEED
  Create a Map of the feed (%Feed ??) to easily grab chapters by title/chapter

* For a %Feed item (aka a particular chapter/update)
  Grab the url e.g. www.novelupdates..com/extnu/327112/
  Do:
    {:ok, page} = url
    |> HTTPoison.get([], [follow_redirect: true])

  %HTTPoison.Response{body: body} = page gives the HTML of the page as
  variable 'body'

* Depending on the site grab the content using Floki and a particular CSS
  identifier

  e.g. for Realms In The Firmament, the CSS identifier is "#content"
  So, using Floki:
    content = Floki(body, "#content")
  gives the content of the chapter.

* Then we can format the content by removing "br"s or anything else we don't
  need.
  OR, we can build HTML/some other format and display that in Electron GUI.
  Depending on what format Electron can parse easiest.

  [{tag, identifier, chapter}] = content
  In this case, tag is "div", the HTML tag,
                identifier is [{"id", "content"}], the CSS identifier we
                  used to find the part of the HTML we want.
                chapter is the actual body of text that we've been looking
                  for.

* And the final result: 'chapter' should contain the chapter text that we've
  been looking for. We can output this to terminal/Electron GUI/whatever and
  read from there.



# BUGS

* 15/11/16
  Everyone Else Is a Returnee chapters 54, 55, 56 are in the format:
    - ch54-2
    - ch55-3
    - ch56-4
  Presumably because they are parts 2,3,4 of an arc? respectively.
  This messes with my chapter regex and so the program thinks that this represents
  chapters 56..4; instead of ch56 part 4 of the arc.
  I've decided to just ignore it for now.
  This is recorded here for reference later.

* 16/11/16
  True Martial World chapters 712, 713 skip the announcement post and goes
  straight to the actual chapters.
  This messes with my Retrievers.
  Possible fix may be to skip scraping the announcement post for the chapter link.
  Instead, pass in the ChapterUpdate struct, and build a URL based off the Retriever
  and the relevant information, e.g. title, chapter number, etc.

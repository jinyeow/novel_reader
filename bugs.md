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

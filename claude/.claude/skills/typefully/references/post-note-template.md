# Post note format

One note per post in `~/notes/2-projects/social/posts/`, named `<target date> <slug>.md`.
`tf.py post create|update|status|log <note>` reads and writes it.

```markdown
---
title: Short internal title       # Typefully draft title, never posted
status: drafting                  # drafting → ready → scheduled → published (status/log update it)
theme: Slop                       # optional, from seed-themes
draft:                            # written back by `post create`
media:                            # written back after the image uploads
---

## LinkedIn

Body. No link. One post only.

## X

Body for X. Leave empty to reuse the LinkedIn text verbatim.
Usually the same words with the numbers on their own lines.

## Comment

One line with the link. Becomes the LinkedIn first comment and the X reply.

## Image

![[filename.png]]
Alt: description used as alt text on both platforms

## Notes

Grading rounds, what changed and why, things to check before it goes out.
```

Rules the loader applies:

- The image embed is resolved next to the note, then in `attachments/` beside
  the note or one level up. Upload happens once; `media:` caches the id.
- An empty `## X` means the LinkedIn text is used on X as is.
- `## Comment` empty means no first comment and no reply post.
- `post update` re-sends both platform bodies and the first comment, so the
  note is the source of truth. Edits made in the Typefully editor are
  overwritten by the next `post update`; copy them into the note first.

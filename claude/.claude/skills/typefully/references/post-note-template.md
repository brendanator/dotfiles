# Post note format

One note per post in `~/notes/2-projects/social/posts/`, named `<target date> <slug>.md`.
`tf.py post create|update|status|log <note>` reads and writes it.
Obsidian template: `~/notes/4-resources/obsidian/templates/social-post.md` (adds a `## Structure`
section with the writing rules; the loader ignores sections it does not know).

```markdown
---
title: Short internal title       # Typefully draft title, never posted
status: drafting                  # drafting → ready → scheduled → published (status/log update it)
theme: Harness and verification loops   # optional, from seed-themes
typefully-draft:                  # written back by `post create`
typefully-media:                  # file=id per image, written back after upload
published-at:                     # ISO timestamp, written by `post status` after publishing
linkedin-url:                     # written by `post status`
x-url:                            # written by `post status`
---

## LinkedIn

Body. No link. One post only.

## X

Body for X. Leave empty to reuse the LinkedIn text verbatim.
Usually the same words with the numbers on their own lines.

## Comment

One line with the link. Becomes the LinkedIn first comment and the X reply.

## Image

![[first.png]]
Alt: description used as alt text on both platforms
![[second.png]]
Alt: one Alt line per embed; images attach in this order (X allows 4, LinkedIn 10)

## Notes

Grading rounds, what changed and why, things to check before it goes out.
```

Rules the loader applies:

- Image embeds can be Obsidian's `![[file.png]]` or a markdown link
  `![alt](attachments/file.png)` (what a vault set to markdown links pastes;
  `%20` is decoded). Each is resolved next to the note, then in `attachments/`
  beside the note or one level up. A markdown link's own alt text is used when
  there is no `Alt:` line. Uploads happen once per file; `typefully-media`
  caches `file=id` pairs, so only a new or renamed image re-uploads.
- An empty `## X` means the LinkedIn text is used on X as is.
- `## Comment` empty means no first comment and no reply post.
- `post update` re-sends both platform bodies and the first comment, so the
  note is the source of truth. Edits made in the Typefully editor are
  overwritten by the next `post update`; copy them into the note first.

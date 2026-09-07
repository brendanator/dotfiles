---
name: typefully
description: >
  Draft, review, and schedule Brendan's LinkedIn and X posts through Typefully.
  Use for any request to draft, schedule, list, or check social posts, for a
  Typefully draft URL (https://typefully.com/?d=<draft_id>&a=<social_set_id>),
  and for setting the LinkedIn first comment. Replaces the typefully-skills
  plugin, which cannot set a first comment.
---

# Typefully

One account: social set `320878` (@brendanator, LinkedIn + X). Everything goes
through `scripts/tf.py` (Python 3, no dependencies, JSON out). Run it as
`<skill dir>/scripts/tf.py`.

Two APIs behind it:

- **Public v2** (`api.typefully.com/v2`, API key in `~/.config/typefully/config.json`).
  Spec: `references/openapi.json`, summary: `references/api.md`. Refresh both
  with `tf.py spec`.
- **Internal** (`api.typefully.com/threads/<id>/`), the desktop app's own API.
  Only used for the LinkedIn first comment, which the public API refuses.
  Auth is the desktop app's session token, read from disk. Details in
  `references/internal-api.md`. Needs Typefully.app signed in on this Mac.

## Rules

1. **Never publish** unless the user says "publish now" in this conversation.
   `drafts publish` needs `--yes`; creating and scheduling drafts is fine.
2. **LinkedIn is one post plus a first comment.** The link never goes in the
   body. `--first-comment` sets it; the public API would reject a second post.
3. **One draft per post.** Same content on X and LinkedIn is one draft with
   `--platform x,linkedin`. Different copy per platform is still one draft:
   create with one platform, then `drafts update <id> --platform x --file ...`.
4. **Grade before you show.** A post is not ready until it passes the
   checklist in `references/post-template.md`. Low stakes ideas still end up
   high quality; the point is the writing muscle.
5. **The slot is 8am ET** (12:00Z, 1pm UK). The queue already has one slot a
   day there. Schedule with `--time next-free-slot` unless told otherwise.
6. After scheduling, note the publish time in the scratchpad: the one-hour
   comment:reaction check needs it (`references/cadence.md`).

## Commands

```bash
tf.py drafts list [--status draft|scheduled|published] [--limit N]
tf.py drafts get <id>                       # public draft + linkedin_first_comment
tf.py drafts create --platform linkedin --file post.txt --title "..." \
      --first-comment "Source: https://..." [--scratchpad "..."] [--tags a,b]
tf.py drafts update <id> [--platform x --file x.txt] [--title] [--scratchpad] [--first-comment]
tf.py first-comment <id> [--text "..."|--file f|--clear]   # no flag = show
tf.py drafts schedule <id> --time next-free-slot|2026-09-08T12:00:00Z
tf.py drafts plan <id> --time ...           # on the calendar, does not publish
tf.py drafts unschedule <id>
tf.py drafts delete <id> --yes
tf.py drafts publish <id> --yes             # irreversible
tf.py post create|update|status <note>       # Obsidian post note, see below
tf.py post log <note> [--one-hour R/C] [--linkedin R/C]
tf.py media upload <file> [--alt "..."]      # returns media_id when ready; then --media <id> on create/update
tf.py queue [--start YYYY-MM-DD] [--end YYYY-MM-DD]
tf.py tags | me | social-sets
tf.py internal <id>                         # raw internal thread object
tf.py spec                                  # refresh references from the live OpenAPI spec
```

Thread posts for X are split by a line containing only `---` in the file.
Draft URLs: `https://typefully.com/?d=<id>&a=320878`.

## The repeatable process

Posts live in the Obsidian vault at `~/notes/2-projects/social/`:

```
social-ideas.md            the backlog of unwritten ideas
Log.md                     one row per published post
attachments/               images (Obsidian pastes here)
posts/<date> <slug>.md     one note per post, see references/post-note-template.md
```

Stages, and who does them:

1. **Pick.** Brendan moves an idea from `social-ideas.md` into a new post note.
2. **Write and grade.** Brendan drafts in the note. Read it from disk, never from
   a paste. Grade against `references/post-template.md` and put the round in
   the note's `## Notes` section. Diagnose, don't draft: say which line fails
   and why, not what to write instead. Every word in the post should be his.
3. **Package.** The note holds the LinkedIn body, the X body (line breaks may
   differ, words should not), the comment, and the image embed with alt text.
4. **Load.** `tf.py post create <note>` creates the draft on both platforms,
   uploads the image, sets the LinkedIn first comment and the X reply, and
   writes `draft:` and `media:` back into the note. `tf.py post update <note>`
   re-syncs after edits. Brendan opens Typefully once for the fold preview and
   the schedule button. Say which 12:00Z slot it landed in.
5. **After publishing.** The hour after the post is reply time. At one hour
   note reactions and comments. `tf.py post status <note>` writes the
   published URLs and status back to the note; `tf.py post log <note>
   --one-hour "R/C" --linkedin "R/C"` appends the row to `Log.md` with the
   X numbers pulled from the analytics API (LinkedIn analytics is not in the
   API; those are typed in).

The X copy is a cut of the LinkedIn copy, not a rewrite: numbers on their
own lines, hook split, the link as a reply. Leave "Sync with X" off in the
editor so the two versions stay independent.

## References

- `references/post-note-template.md`: the note format `tf.py post` reads.
- `references/post-template.md`: the five-block template, constraints, the
  ship checklist, and formatting that survives LinkedIn's mobile truncation.
- `references/cadence.md`: six posts a week batched in a half day, 8am ET,
  commenting as part of the cadence, the comment:reaction bar.
- `references/api.md` and `references/openapi.json`: public API surface.
- `references/internal-api.md`: the first-comment endpoint and token recovery.
- Research behind all of this lives in the Sourcery repo under
  `docs/marketing/` (influencers, seed themes, Christian benchmark).

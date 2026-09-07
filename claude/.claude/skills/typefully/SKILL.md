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
tf.py queue [--start YYYY-MM-DD] [--end YYYY-MM-DD]
tf.py tags | me | social-sets
tf.py internal <id>                         # raw internal thread object
tf.py spec                                  # refresh references from the live OpenAPI spec
```

Thread posts for X are split by a line containing only `---` in the file.
Draft URLs: `https://typefully.com/?d=<id>&a=320878`.

## Workflow for a new post

1. User brings a draft or an idea. Coach it against `references/post-template.md`.
2. Write the approved body to a file, create the draft with `--title` and
   `--first-comment` (the link and one line of context).
3. Paste the draft URL back. Confirm it is unscheduled unless asked.
4. Schedule only when told. Then record the slot time in the scratchpad.

## References

- `references/post-template.md`: the five-block template, constraints, the
  ship checklist, and formatting that survives LinkedIn's mobile truncation.
- `references/cadence.md`: six posts a week batched in a half day, 8am ET,
  commenting as part of the cadence, the comment:reaction bar.
- `references/api.md` and `references/openapi.json`: public API surface.
- `references/internal-api.md`: the first-comment endpoint and token recovery.
- Research behind all of this lives in the Sourcery repo under
  `docs/marketing/` (influencers, seed themes, Christian benchmark).

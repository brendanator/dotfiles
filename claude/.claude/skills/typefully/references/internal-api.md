# Internal API (desktop app)

The public v2 API caps LinkedIn at one post per draft and has no first-comment
field. The web and desktop apps use a separate API that does.

- Base `https://api.typefully.com` (no `/v2`). `api2.typefully.com` mirrors it.
- Header `Authorization: <jwt>`, raw, no `Bearer`.
- A draft is a "thread": `GET/PATCH /threads/<draft_id>/?account=<social_set_id>`.
- `GET /me/` validates a token. `GET /accounts/` lists social sets.

Fields on the thread object that matter:

| field | type | meaning |
|---|---|---|
| `linkedin_v2_first_comment` | string | comment Typefully posts right after the LinkedIn post |
| `linkedin_v2_first_comment_enabled` | bool | must be true for the comment to post |
| `linkedin_v2_rich_text` | ProseMirror atoms | the LinkedIn body; edit via the public API instead |
| `status` | int | 0 = draft |

Set a first comment:

```
PATCH /threads/<id>/?account=320878
{"linkedin_v2_first_comment": "Source: https://...", "linkedin_v2_first_comment_enabled": true}
```

## Token recovery

The app keeps its session in localStorage key `writhread:auth` as JSON
`{user, token, selectedAccountId}`. On disk that is an unencrypted LevelDB at
`~/Library/Application Support/Typefully/Local Storage/leveldb/`.

`tf.py` reads it in this order and validates each candidate against `/me/`:

1. Cached copy at `~/.config/typefully/app-token` (mode 600).
2. `*.log` records: key, varint length, one byte encoding (`0x01` latin1,
   `0x00` UTF-16LE), then the JSON.
3. `*.ldb` tables: the JWT survives as a literal even though the table is
   snappy-compressed, so a regex for `eyJ….….…` finds it.

If all fail, open Typefully.app and sign in, then retry. Never print the token.
The public API key and the app token are different credentials.

Verified 2026-09-07 on draft 10661249.

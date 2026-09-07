# Typefully public API v2

Generated from `https://api.typefully.com/v2/openapi.json` on 2026-09-07 by `tf.py spec`. Base URL `https://api.typefully.com/v2`, header `Authorization: Bearer <api key>`.

## Endpoints

- `GET /v2/me` - Get current user
- `GET /v2/social-sets/{social_set_id}/analytics/{platform}/posts` - List analytics posts
- `GET /v2/social-sets/{social_set_id}/analytics/{platform}/followers` - Get followers analytics
- `GET /v2/social-sets` - List social sets
- `GET /v2/social-sets/{social_set_id}/` - Get social set details
- `GET /v2/social-sets/{social_set_id}/drafts` - List drafts
- `POST /v2/social-sets/{social_set_id}/drafts` - Create draft
- `GET /v2/social-sets/{social_set_id}/drafts/{draft_id}` - Get draft
- `PATCH /v2/social-sets/{social_set_id}/drafts/{draft_id}` - Update draft
- `DELETE /v2/social-sets/{social_set_id}/drafts/{draft_id}` - Delete draft
- `POST /v2/social-sets/{social_set_id}/media/upload` - Create media upload
- `GET /v2/social-sets/{social_set_id}/media/{media_id}` - Get media status
- `PATCH /v2/social-sets/{social_set_id}/media/{media_id}` - Update media
- `GET /v2/social-sets/{social_set_id}/tags` - List tags
- `POST /v2/social-sets/{social_set_id}/tags` - Create tag
- `GET /v2/social-sets/{social_set_id}/queue/schedule` - Get queue schedule
- `PUT /v2/social-sets/{social_set_id}/queue/schedule` - Replace queue schedule
- `GET /v2/social-sets/{social_set_id}/queue` - Get queue
- `GET /v2/social-sets/{social_set_id}/linkedin/organizations/resolve` - Resolve LinkedIn organization from URL
- `GET /v2/social-sets/{social_set_id}/drafts/{draft_id}/comment-threads` - List comment threads on a draft
- `POST /v2/social-sets/{social_set_id}/drafts/{draft_id}/comment-threads` - Create a comment thread
- `POST /v2/social-sets/{social_set_id}/drafts/{draft_id}/comment-threads/{comment_thread_id}/comments` - Add a comment to an existing comment thread
- `POST /v2/social-sets/{social_set_id}/drafts/{draft_id}/comment-threads/{comment_thread_id}/resolve` - Resolve a comment thread
- `PATCH /v2/social-sets/{social_set_id}/drafts/{draft_id}/comment-threads/{comment_thread_id}/comments/{comment_id}` - Update a comment's text
- `DELETE /v2/social-sets/{social_set_id}/drafts/{draft_id}/comment-threads/{comment_thread_id}/comments/{comment_id}` - Delete a comment
- `DELETE /v2/social-sets/{social_set_id}/drafts/{draft_id}/comment-threads/{comment_thread_id}` - Delete a comment thread

## Request schemas

### DraftCreateRequest

- `platforms`: Platform configurations for each social media platform
- `draft_title`: Draft title, for internal organization only; not posted to social media.
- `scratchpad_text`: Plain text scratchpad notes for the draft. Formatting is stripped.
- `tags`: Tag slugs (not names). Tags must already exist in the social set - list them via /tags.
- `share`: Whether to generate a public share URL for this draft. When true, anyone with the URL can view the draft content.
- `publish_at`: When to publish: "now" (immediate), "next-free-slot" (next available posting slot), or a future ISO 8601 datetime with timezone. Omit to save as a draft. Mutually exclusive with `plan_at`. "now" is asynchronous: the response returns `publish_state`="in_progress" while `status` stays "draft" and published URLs are null - success, not failure; poll GET /drafts/{id} until `publish_state`="finished", then read `status` and the published URLs.
- `plan_at`: When to plan the draft. A planned draft is dated but inert: it shows on the queue and calendar at its date but never auto-publishes until confirmed by later setting `publish_at`. Accepts "next-free-slot" or a future ISO 8601 datetime with timezone ("now" is not valid). Mutually exclusive with `publish_at`. Omit to save as a plain draft.

### DraftUpdateRequest

- `platforms`: Platform configurations. Only provided platforms will be updated; omitted platforms remain unchanged.
- `draft_title`: Draft title, for internal organization only; not posted to social media. Omit to keep unchanged.
- `scratchpad_text`: Plain text scratchpad notes for the draft. Formatting is stripped. Omit to keep unchanged.
- `tags`: Tag slugs (not names). Tags must already exist in the social set - list them via /tags. Omit to keep unchanged.
- `share`: Whether to generate a public share URL. Omit to keep unchanged.
- `publish_at`: When to publish: "now" (immediate), "next-free-slot", or a future ISO 8601 datetime with timezone. On a planned draft, a datetime or "next-free-slot" confirms the plan into a real schedule (echo `scheduled_date` from a GET to confirm at the planned date); "now" publishes it immediately. Explicit null returns a scheduled or planned draft to plain draft status. Mutually exclusive with `plan_at`. Omit to keep unchanged. "now" is asynchronous: the response returns `publish_state`="in_progress" (success, not failure); poll GET /drafts/{id} until "finished".
- `plan_at`: When to plan. A planned draft is dated but inert: on the queue and calendar but never auto-publishing until confirmed via `publish_at`. A future datetime with timezone or "next-free-slot" plans a plain draft, replans a planned one, or unschedules a scheduled one into a plan (requires publish access; "now" invalid). Explicit null returns a planned or scheduled draft to plain draft status. Mutually exclusive with `publish_at`. Omit to keep unchanged.
- `force_overwrite_comments`: Comment-thread anchor preservation toggle. When false (the default), submitting `posts[*].text` or X Article `content_markdown` whose `<typ:comment-thread>` markers don't match the draft's stored comment threads is rejected with `409 COMMENTS_MARKER_MISMATCH`; re-include the missing markers and retry. When true, missing markers are accepted: their comment threads are resolved server-side and their anchors stripped; submitted markers still validate normally. Only JSON `true`/`false` (not `"true"` strings).

### LinkedInPlatform

- `enabled`: Required. Set true and include `posts` to publish to this platform; false (no `posts`) leaves it off.
- `posts`: Posts for this platform. Required when `enabled` is true; omit when false.
- `settings`: LinkedIn-specific settings

### LinkedInPost

- `text`: The text content of the post. You can tag companies with mention syntax: @[Company Name](urn:li:organization:123456).
- `media_ids`: Media IDs to attach to the post; obtain them via the media upload endpoint.
- `hide_link_preview`: Hide the link-preview card (the URL stays as plain text). When false, a preview is attached for the last URL. Omit (or send null) to keep the current value on update (false on create).
- `linkedin_reshare_target`: Canonical URN or full LinkedIn post URL to reshare (repost). URLs are normalized to the canonical URN in storage and responses. Use values like urn:li:share:<id>, urn:li:ugcPost:<id>, or urn:li:groupPost:<id>.

### XPlatform

- `enabled`: Required. Set true and include `posts` to publish to this platform; false (no `posts`) leaves it off.
- `posts`: Posts for this platform. Required when `enabled` is true; omit when false.
- `settings`: X-specific settings

### XPost

- `text`: The text content of the post.
- `media_ids`: Media IDs to attach to the post; obtain them via the media upload endpoint.
- `hide_link_preview`: Hide the link-preview card (the URL stays as plain text). When false, a preview is attached for the last URL. Omit (or send null) to keep the current value on update (false on create).
- `quote_post_url`: URL of the X post to quote in this post (equivalent to Typefully's 'convert to quote' action).
- `subscribers_only`: Whether this individual post should be visible only to paying Subscribers. This only works for X accounts approved for creator Subscriptions.
- `paid_partnership`: Whether this post should be labeled as a paid partnership.
- `made_with_ai`: Whether this post should be labeled as made with AI.

#!/usr/bin/env python3
"""Typefully CLI: public v2 API plus the desktop app's internal API for the LinkedIn first comment."""
import argparse
import datetime as dt
import glob
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

PUBLIC = "https://api.typefully.com/v2"
INTERNAL = "https://api.typefully.com"
CONFIG = os.path.expanduser("~/.config/typefully/config.json")
TOKEN_CACHE = os.path.expanduser("~/.config/typefully/app-token")
LEVELDB = os.path.expanduser("~/Library/Application Support/Typefully/Local Storage/leveldb")
REF = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "references")
PLATFORMS = ["x", "linkedin", "threads", "bluesky", "mastodon", "substack"]


def main():
    p = argparse.ArgumentParser(prog="tf.py", description=__doc__)
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("me", help="authenticated user (public API)")
    sub.add_parser("social-sets", help="list social sets")
    sub.add_parser("tags", help="list tags")
    q = sub.add_parser("queue", help="free slots and scheduled drafts")
    q.add_argument("--start")
    q.add_argument("--end")
    d = sub.add_parser("drafts", help="draft commands").add_subparsers(dest="sub", required=True)
    dl = d.add_parser("list")
    dl.add_argument("--status", choices=["draft", "scheduled", "published", "planned", "publishing", "error"])
    dl.add_argument("--limit", type=int, default=20)
    dl.add_argument("--full", action="store_true")
    dg = d.add_parser("get")
    dg.add_argument("id")
    dc = d.add_parser("create")
    _content_args(dc)
    du = d.add_parser("update")
    du.add_argument("id")
    _content_args(du)
    ds = d.add_parser("schedule")
    ds.add_argument("id")
    ds.add_argument("--time", required=True, help='ISO datetime with timezone, or "next-free-slot"')
    dp = d.add_parser("plan", help="date it on the calendar without arming publish")
    dp.add_argument("id")
    dp.add_argument("--time", required=True)
    dn = d.add_parser("unschedule")
    dn.add_argument("id")
    dd = d.add_parser("delete")
    dd.add_argument("id")
    dd.add_argument("--yes", action="store_true")
    dpub = d.add_parser("publish", help="publish now (irreversible)")
    dpub.add_argument("id")
    dpub.add_argument("--yes", action="store_true")
    fc = sub.add_parser("first-comment", help="LinkedIn first comment (internal API)")
    fc.add_argument("id")
    fc.add_argument("--text")
    fc.add_argument("--file")
    fc.add_argument("--clear", action="store_true")
    po = sub.add_parser("post", help="load an Obsidian post note (see SKILL.md) into Typefully").add_subparsers(dest="sub", required=True)
    for name in ("create", "update", "status", "log"):
        sp = po.add_parser(name)
        sp.add_argument("note", help="path to the post note")
        if name == "log":
            sp.add_argument("--linkedin", help="'reactions/comments' at one week, typed by hand")
            sp.add_argument("--one-hour", help="'reactions/comments' at one hour, typed by hand")
    mu = sub.add_parser("media", help="media commands").add_subparsers(dest="sub", required=True)
    mup = mu.add_parser("upload", help="upload an image, video, gif, or pdf and wait until ready")
    mup.add_argument("file")
    mup.add_argument("--alt", help="alt text, set before attaching")
    mst = mu.add_parser("status")
    mst.add_argument("id")
    ig = sub.add_parser("internal", help="raw internal thread object")
    ig.add_argument("id")
    sub.add_parser("spec", help="refresh references/openapi.json and references/api.md")
    a = p.parse_args()
    out = COMMANDS[a.cmd](a)
    print(json.dumps(out, indent=2, ensure_ascii=False))


def cmd_me(a):
    return public("GET", "/me")


def cmd_social_sets(a):
    return public("GET", "/social-sets")


def cmd_tags(a):
    return public("GET", f"/social-sets/{social_set()}/tags")


def cmd_queue(a):
    start = a.start or dt.date.today().isoformat()
    end = a.end or (dt.date.today() + dt.timedelta(days=14)).isoformat()
    return public("GET", f"/social-sets/{social_set()}/queue?start_date={start}&end_date={end}")


def cmd_drafts(a):
    return DRAFT_COMMANDS[a.sub](a)


def drafts_list(a):
    qs = {"limit": a.limit, "order_by": "-updated_at"}
    if a.status:
        qs["status"] = a.status
    r = public("GET", f"/social-sets/{social_set()}/drafts?{urllib.parse.urlencode(qs)}")
    if a.full:
        return r
    keys = ["id", "status", "scheduled_date", "published_at", "draft_title", "preview", "linkedin_post_enabled", "x_post_enabled"]
    return [{k: row.get(k) for k in keys} for row in r.get("results", [])]


def drafts_get(a):
    r = public("GET", f"/social-sets/{social_set()}/drafts/{a.id}")
    r["url"] = draft_url(a.id)
    try:
        t = internal("GET", f"/threads/{a.id}/")
        r["linkedin_first_comment"] = t.get("linkedin_v2_first_comment") if t.get("linkedin_v2_first_comment_enabled") else None
    except SystemExit:
        r["linkedin_first_comment"] = "unknown (app token unavailable)"
    return r


def drafts_create(a):
    body = draft_body(a, create=True)
    if not body.get("platforms"):
        die("--platform and --text/--file are required to create a draft")
    r = public("POST", f"/social-sets/{social_set()}/drafts", body)
    r["url"] = draft_url(r["id"])
    fc = first_comment_text(a)
    if fc is not None:
        r["linkedin_first_comment"] = set_first_comment(r["id"], fc)
    return r


def drafts_update(a):
    body = draft_body(a, create=False)
    r = public("PATCH", f"/social-sets/{social_set()}/drafts/{a.id}", body) if body else {"id": int(a.id)}
    r["url"] = draft_url(a.id)
    fc = first_comment_text(a)
    if fc is not None:
        r["linkedin_first_comment"] = set_first_comment(a.id, fc)
    return r


def drafts_schedule(a):
    return public("PATCH", f"/social-sets/{social_set()}/drafts/{a.id}", {"publish_at": a.time})


def drafts_plan(a):
    return public("PATCH", f"/social-sets/{social_set()}/drafts/{a.id}", {"plan_at": a.time})


def drafts_unschedule(a):
    return public("PATCH", f"/social-sets/{social_set()}/drafts/{a.id}", {"publish_at": None, "plan_at": None})


def drafts_delete(a):
    if not a.yes:
        die("refusing to delete without --yes")
    public("DELETE", f"/social-sets/{social_set()}/drafts/{a.id}")
    return {"deleted": int(a.id)}


def drafts_publish(a):
    if not a.yes:
        die("publishing is irreversible; pass --yes only when the user said to publish now")
    return public("PATCH", f"/social-sets/{social_set()}/drafts/{a.id}", {"publish_at": "now"})


def cmd_first_comment(a):
    if a.clear:
        return set_first_comment(a.id, "")
    text = a.text if a.text is not None else (read_file(a.file) if a.file else None)
    if text is None:
        t = internal("GET", f"/threads/{a.id}/")
        return {"id": t["id"], "enabled": t["linkedin_v2_first_comment_enabled"], "text": t["linkedin_v2_first_comment"]}
    return set_first_comment(a.id, text)


def cmd_post(a):
    return POST_COMMANDS[a.sub](a)


def post_create(a):
    note = read_note(a.note)
    if note["draft"]:
        die(f"note already has typefully-draft {note['draft']}; use `post update`")
    media = ensure_media(note)
    body = note_body(note, media)
    r = public("POST", f"/social-sets/{social_set()}/drafts", body)
    note["fm"]["typefully-draft"] = str(r["id"])
    if note["comment"]:
        set_first_comment(r["id"], note["comment"])
    write_note(note)
    return post_status_summary(r["id"], note)


def post_update(a):
    note = read_note(a.note)
    if not note["draft"]:
        die("note has no draft id; use `post create`")
    media = ensure_media(note)
    body = note_body(note, media)
    public("PATCH", f"/social-sets/{social_set()}/drafts/{note['draft']}", body)
    set_first_comment(note["draft"], note["comment"] or "")
    write_note(note)
    return post_status_summary(note["draft"], note)


def post_status(a):
    note = read_note(a.note)
    if not note["draft"]:
        die("note has no draft id")
    out = post_status_summary(note["draft"], note)
    note["fm"]["status"] = {"draft": "ready", "scheduled": "scheduled", "published": "published"}.get(out["status"], out["status"])
    for k in ("linkedin-url", "x-url"):
        if out.get(k.replace("-", "_")):
            note["fm"][k] = out[k.replace("-", "_")]
    write_note(note)
    return out


def post_log(a):
    note = read_note(a.note)
    out = post_status_summary(note["draft"], note) if note["draft"] else {}
    log = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(a.note))), "Log.md")
    x = out.get("x_analytics") or {}
    xcell = f"{x.get('likes', '')} / {x.get('comments', '')} / {x.get('impressions', '')}" if x else ""
    name = os.path.splitext(os.path.basename(a.note))[0]
    row = f"| {(out.get('published_at') or dt.date.today().isoformat())[:10]} | [[{name}]] | {out.get('linkedin_url') or ''} | {out.get('x_url') or ''} | {a.one_hour or ''} | {a.linkedin or ''} | {xcell} |  |\n"
    with open(log, "a") as f:
        f.write(row)
    return {"log": log, "row": row.strip()}


def post_status_summary(draft_id, note):
    d = public("GET", f"/social-sets/{social_set()}/drafts/{draft_id}")
    out = {
        "draft": int(draft_id),
        "url": draft_url(draft_id),
        "status": d.get("status"),
        "scheduled_date": d.get("scheduled_date"),
        "published_at": d.get("published_at"),
        "linkedin_url": d.get("linkedin_published_url"),
        "x_url": d.get("x_published_url"),
        "platforms": {k: len(v.get("posts", [])) for k, v in (d.get("platforms") or {}).items() if v and v.get("enabled")},
        "media": [p.get("media_ids") for v in (d.get("platforms") or {}).values() if v and v.get("enabled") for p in v.get("posts", [])[:1]],
    }
    try:
        t = internal("GET", f"/threads/{draft_id}/")
        out["first_comment"] = t.get("linkedin_v2_first_comment") if t.get("linkedin_v2_first_comment_enabled") else None
    except SystemExit:
        out["first_comment"] = "unknown (app token unavailable)"
    if out["x_url"] and out["published_at"]:
        day = out["published_at"][:10]
        end = (dt.date.fromisoformat(day) + dt.timedelta(days=14)).isoformat()
        try:
            an = public("GET", f"/social-sets/{social_set()}/analytics/x/posts?start_date={day}&end_date={end}&limit=100")
            for row in an.get("results", []):
                if str(row.get("draft_id")) == str(draft_id):
                    m = row.get("metrics", {})
                    out["x_analytics"] = {"impressions": m.get("impressions"), **(m.get("engagement") or {})}
        except SystemExit:
            pass
    return out


def read_note(path):
    text = read_file(path)
    fm, rest = {}, text
    if text.startswith("---\n"):
        end = text.index("\n---", 4)
        for line in text[4:end].splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                fm[k.strip()] = v.split("#")[0].strip() if v.strip() else ""
        rest = text[end + 4:]
    sections, current = {}, None
    for line in rest.splitlines():
        if line.startswith("## "):
            current = line[3:].strip().lower()
            sections[current] = []
        elif current:
            sections[current].append(line)
    sec = {k: "\n".join(v).strip() for k, v in sections.items()}
    images = []
    for line in (sec.get("image") or sec.get("images") or "").splitlines():
        m = re.search(r"!\[\[([^\]|]+)", line)
        if m:
            images.append({"file": m.group(1).strip(), "alt": None})
        elif line.lower().startswith("alt:") and images:
            images[-1]["alt"] = line[4:].strip()
    return {"path": path, "text": text, "fm": fm, "title": fm.get("title") or os.path.basename(path), "draft": fm.get("typefully-draft") or None,
            "linkedin": sec.get("linkedin", ""), "x": sec.get("x", ""), "comment": sec.get("comment", ""), "images": images}


def write_note(note):
    text = note["text"]
    keys = ["typefully-draft", "typefully-media", "status", "linkedin-url", "x-url"]
    if not text.startswith("---\n"):
        text = "---\n---\n" + text
    end = text.index("\n---", 4)
    lines = text[4:end].splitlines()
    for k in keys:
        v = note["fm"].get(k)
        if v is None or v == "":
            continue
        for i, line in enumerate(lines):
            if line.split(":", 1)[0].strip() == k:
                lines[i] = f"{k}: {v}"
                break
        else:
            lines.append(f"{k}: {v}")
    text = "---\n" + "\n".join(lines) + text[end:]
    with open(note["path"], "w") as f:
        f.write(text)
    note["text"] = text


def ensure_media(note):
    if not note["images"]:
        return []
    cache = {}
    for item in (note["fm"].get("typefully-media") or "").split(","):
        if "=" in item:
            k, v = item.split("=", 1)
            cache[k.strip()] = v.strip()
    folder = os.path.dirname(os.path.abspath(note["path"]))
    ids = []
    for img in note["images"]:
        if img["file"] in cache:
            ids.append(cache[img["file"]])
            continue
        candidates = [os.path.join(folder, img["file"]), os.path.join(folder, "attachments", img["file"]), os.path.join(os.path.dirname(folder), "attachments", img["file"])]
        path = next((c for c in candidates if os.path.exists(c)), None)
        if not path:
            die(f"image {img['file']!r} not found next to the note or in attachments/")
        st = media_upload(argparse.Namespace(file=path, alt=img["alt"]))
        if st.get("status") != "ready":
            die(f"media not ready: {st}")
        cache[img["file"]] = st["media_id"]
        ids.append(st["media_id"])
    note["fm"]["typefully-media"] = ", ".join(f"{img['file']}={cache[img['file']]}" for img in note["images"])
    return ids


def note_body(note, media):
    if not note["linkedin"]:
        die("note has no ## LinkedIn section")
    li = {"text": note["linkedin"]}
    if media:
        li["media_ids"] = media
    x_text = note["x"] or note["linkedin"]
    x_posts = [{"text": x_text}]
    if media:
        x_posts[0]["media_ids"] = media
    if note["comment"]:
        x_posts.append({"text": note["comment"]})
    return {"draft_title": note["title"], "platforms": {"linkedin": {"enabled": True, "posts": [li]}, "x": {"enabled": True, "posts": x_posts}}}


def cmd_media(a):
    return MEDIA_COMMANDS[a.sub](a)


def media_upload(a):
    name = re.sub(r"[^a-zA-Z0-9_.()\-]", "-", os.path.basename(a.file))
    body = {"file_name": name}
    if a.alt:
        body["alt_text"] = a.alt
    r = public("POST", f"/social-sets/{social_set()}/media/upload", body)
    code = subprocess.run(["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", "-T", a.file, r["upload_url"]], capture_output=True, text=True).stdout
    if code not in ("200", "204"):
        die(f"upload PUT returned HTTP {code}; the presigned URL rejects any extra headers")
    deadline = time.time() + 90
    while True:
        st = public("GET", f"/social-sets/{social_set()}/media/{r['media_id']}")
        if st.get("status") != "processing" or time.time() > deadline:
            return st
        time.sleep(2)


def media_status(a):
    return public("GET", f"/social-sets/{social_set()}/media/{a.id}")


def cmd_internal(a):
    return internal("GET", f"/threads/{a.id}/")


def cmd_spec(a):
    raw = urllib.request.urlopen(PUBLIC + "/openapi.json", timeout=30).read()
    spec = json.loads(raw)
    with open(os.path.join(REF, "openapi.json"), "w") as f:
        json.dump(spec, f, indent=1)
    lines = ["# Typefully public API v2", "", f"Generated from `{PUBLIC}/openapi.json` on {dt.date.today()} by `tf.py spec`. Base URL `{PUBLIC}`, header `Authorization: Bearer <api key>`.", "", "## Endpoints", ""]
    for path, ops in spec["paths"].items():
        for method, op in ops.items():
            lines.append(f"- `{method.upper()} {path}` - {op.get('summary', '')}")
    lines += ["", "## Request schemas", ""]
    for name in ["DraftCreateRequest", "DraftUpdateRequest", "LinkedInPlatform", "LinkedInPost", "XPlatform", "XPost"]:
        s = spec["components"]["schemas"].get(name)
        if not s:
            continue
        lines.append(f"### {name}")
        lines.append("")
        for prop, meta in s.get("properties", {}).items():
            desc = (meta.get("description") or "").split("\n")[0]
            lines.append(f"- `{prop}`: {desc}")
        lines.append("")
    with open(os.path.join(REF, "api.md"), "w") as f:
        f.write("\n".join(lines))
    return {"paths": len(spec["paths"]), "written": [os.path.join(REF, "openapi.json"), os.path.join(REF, "api.md")]}


COMMANDS = {
    "me": cmd_me,
    "social-sets": cmd_social_sets,
    "tags": cmd_tags,
    "queue": cmd_queue,
    "drafts": cmd_drafts,
    "first-comment": cmd_first_comment,
    "post": cmd_post,
    "media": cmd_media,
    "internal": cmd_internal,
    "spec": cmd_spec,
}
POST_COMMANDS = {"create": post_create, "update": post_update, "status": post_status, "log": post_log}
MEDIA_COMMANDS = {"upload": media_upload, "status": media_status}
DRAFT_COMMANDS = {
    "list": drafts_list,
    "get": drafts_get,
    "create": drafts_create,
    "update": drafts_update,
    "schedule": drafts_schedule,
    "plan": drafts_plan,
    "unschedule": drafts_unschedule,
    "delete": drafts_delete,
    "publish": drafts_publish,
}


def _content_args(sp):
    sp.add_argument("--platform", help="comma-separated: " + ",".join(PLATFORMS))
    sp.add_argument("--text")
    sp.add_argument("--file", help="read post text from a file; split X threads with a line containing only ---")
    sp.add_argument("--title", help="internal draft title, never posted")
    sp.add_argument("--scratchpad", help="internal notes, never posted")
    sp.add_argument("--tags", help="comma-separated tag slugs")
    sp.add_argument("--schedule", help='publish_at: ISO datetime with tz, or "next-free-slot"')
    sp.add_argument("--plan", help="plan_at: date it on the calendar without arming publish")
    sp.add_argument("--media", help="comma-separated media ids from `media upload`, attached to the first post")
    sp.add_argument("--first-comment", help="LinkedIn first comment text (internal API)")
    sp.add_argument("--first-comment-file")


def draft_body(a, create):
    body = {}
    text = a.text if a.text is not None else (read_file(a.file) if a.file else None)
    media = [m.strip() for m in a.media.split(",") if m.strip()] if a.media else []
    if media and text is None and not create:
        existing = public("GET", f"/social-sets/{social_set()}/drafts/{a.id}")
        platforms = {}
        for name, cfg in existing.get("platforms", {}).items():
            if cfg and cfg.get("enabled") and (not a.platform or name in a.platform.split(",")):
                posts = [{"text": p["text"], "media_ids": p.get("media_ids", [])} for p in cfg["posts"]]
                posts[0]["media_ids"] = media
                platforms[name] = {"enabled": True, "posts": posts}
        body["platforms"] = platforms
    if text is not None:
        if not a.platform:
            die("--platform is required with --text/--file")
        posts = [t.strip() for t in re.split(r"\n---\n", text.strip()) if t.strip()]
        platforms = {}
        for name in a.platform.split(","):
            name = name.strip()
            if name not in PLATFORMS:
                die(f"unknown platform {name!r}")
            if name == "linkedin" and len(posts) > 1:
                die("LinkedIn takes one post; put the link in --first-comment instead of a second post")
            platforms[name] = {"enabled": True, "posts": [{"text": t} for t in posts]}
            if media:
                platforms[name]["posts"][0]["media_ids"] = media
        body["platforms"] = platforms
    elif a.platform and create:
        die("--platform needs --text or --file")
    if a.title is not None:
        body["draft_title"] = a.title
    if a.scratchpad is not None:
        body["scratchpad_text"] = a.scratchpad
    if a.tags is not None:
        body["tags"] = [t.strip() for t in a.tags.split(",") if t.strip()]
    if a.schedule:
        if a.schedule == "now":
            die('use "drafts publish <id> --yes" to publish now')
        body["publish_at"] = a.schedule
    if a.plan:
        body["plan_at"] = a.plan
    return body


def first_comment_text(a):
    if a.first_comment is not None:
        return a.first_comment
    if a.first_comment_file:
        return read_file(a.first_comment_file)
    return None


def set_first_comment(draft_id, text):
    payload = {"linkedin_v2_first_comment": text, "linkedin_v2_first_comment_enabled": bool(text)}
    t = internal("PATCH", f"/threads/{draft_id}/", payload)
    return {"enabled": t["linkedin_v2_first_comment_enabled"], "text": t["linkedin_v2_first_comment"]}


def draft_url(draft_id):
    return f"https://typefully.com/?d={draft_id}&a={social_set()}"


def read_file(path):
    with open(path) as f:
        return f.read()


def config():
    cfg = {}
    if os.path.exists(CONFIG):
        with open(CONFIG) as f:
            cfg = json.load(f)
    key = os.environ.get("TYPEFULLY_API_KEY") or cfg.get("apiKey")
    sset = os.environ.get("TYPEFULLY_SOCIAL_SET") or cfg.get("defaultSocialSetId")
    if not key or not sset:
        die(f"need apiKey and defaultSocialSetId in {CONFIG} (key from https://typefully.com/?settings=api)")
    return key, sset


def social_set():
    return config()[1]


def public(method, path, body=None):
    return request(method, PUBLIC + path, body, {"Authorization": f"Bearer {config()[0]}"})


def internal(method, path, body=None):
    sep = "&" if "?" in path else "?"
    url = f"{INTERNAL}{path}{sep}account={social_set()}"
    try:
        return request(method, url, body, {"Authorization": app_token()}, quiet=True)
    except urllib.error.HTTPError as e:
        if e.code in (401, 403) and os.path.exists(TOKEN_CACHE):
            os.remove(TOKEN_CACHE)
            return request(method, url, body, {"Authorization": app_token()})
        raise SystemExit(f"internal API {e.code}: {e.read()[:300]}")


def request(method, url, body, headers, quiet=False):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method, headers={**headers, "Content-Type": "application/json", "Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            raw = r.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        if quiet:
            raise
        raw = e.read().decode(errors="replace")
        try:
            raw = json.dumps(json.loads(raw), indent=2)
        except ValueError:
            pass
        die(f"{method} {url} -> HTTP {e.code}\n{raw[:1500]}")


def app_token():
    for token in _token_candidates():
        try:
            request("GET", f"{INTERNAL}/me/", None, {"Authorization": token}, quiet=True)
        except urllib.error.HTTPError:
            continue
        with open(TOKEN_CACHE, "w") as f:
            f.write(token)
        os.chmod(TOKEN_CACHE, 0o600)
        return token
    die("no valid Typefully desktop app session found; open Typefully.app, sign in, then retry")


def _token_candidates():
    seen = set()
    if os.path.exists(TOKEN_CACHE):
        cached = read_file(TOKEN_CACHE).strip()
        if cached:
            seen.add(cached)
            yield cached
    files = sorted(glob.glob(os.path.join(LEVELDB, "*.log")) + glob.glob(os.path.join(LEVELDB, "*.ldb")), key=os.path.getmtime, reverse=True)
    for path in files:
        with open(path, "rb") as f:
            b = f.read()
        for token in _log_record_tokens(b) + _jwt_literals(b):
            if token not in seen:
                seen.add(token)
                yield token


def _log_record_tokens(b):
    found = []
    for m in reversed(list(re.finditer(rb"writhread:auth", b))):
        i, n, shift = m.end(), 0, 0
        while i < len(b):
            c = b[i]
            i += 1
            n |= (c & 0x7F) << shift
            shift += 7
            if not c & 0x80:
                break
        raw = b[i + 1:i + n]
        try:
            s = raw.decode("latin1") if b[i:i + 1] == b"\x01" else raw.decode("utf-16-le")
            j = json.loads(s)
        except (UnicodeDecodeError, ValueError, IndexError):
            continue
        if isinstance(j, dict) and j.get("token"):
            found.append(j["token"])
    return found


def _jwt_literals(b):
    hits = re.findall(rb"eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}", b)
    return [h.decode() for h in reversed(hits)]


def die(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()

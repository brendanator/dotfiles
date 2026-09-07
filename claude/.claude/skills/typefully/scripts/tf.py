#!/usr/bin/env python3
"""Typefully CLI: public v2 API plus the desktop app's internal API for the LinkedIn first comment."""
import argparse
import datetime as dt
import glob
import json
import os
import re
import sys
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
    "internal": cmd_internal,
    "spec": cmd_spec,
}
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
    sp.add_argument("--first-comment", help="LinkedIn first comment text (internal API)")
    sp.add_argument("--first-comment-file")


def draft_body(a, create):
    body = {}
    text = a.text if a.text is not None else (read_file(a.file) if a.file else None)
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

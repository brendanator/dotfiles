#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["markdownify"]
# ///
"""Fetch the current Wikipedia rubric as markdown, for diffing against SKILL.md.

This is a maintenance tool, not part of a review. SKILL.md inlines the rules so reviews
run offline and deterministically. Run this occasionally to see what upstream has added
since the snapshot date recorded in SKILL.md's References section, then fold in by hand
whatever is worth folding in.

    ./refresh_rubric.py             # writes to ~/.cache/review-ai-writing/rubric.md
    ./refresh_rubric.py --stdout    # writes to stdout instead

Output goes to a cache directory, never next to this script. This file is stowed from a public
git repo, and the fetched page is CC BY-SA — dropping it in the package would commit someone
else's licensed text into an unlicensed repo. SKILL.md restates the rules rather than copying
them precisely to avoid that; the cache keeps it true.

Fetches the Parsoid REST endpoint rather than scraping the rendered page: it returns clean
semantic HTML with no navigation chrome or duplicated tables of contents. Nothing here caps
or truncates the output. If a fetch fails, it raises — a rubric that silently shrinks is
worse than one that visibly breaks.
"""

import argparse
import pathlib
import re
import sys
import urllib.parse
import urllib.request

from markdownify import markdownify

PAGE = "Wikipedia:Signs_of_AI_writing"
URL = f"https://en.wikipedia.org/api/rest_v1/page/html/{urllib.parse.quote(PAGE, safe='')}"
UA = "review-ai-writing/2.0 (https://github.com/brendanator/dotfiles)"

# Wikipedia-process sections. The rules there govern wikitext, citations, and talk pages,
# none of which apply to reviewing ordinary prose.
DROP_SECTIONS = {
    "Markup",
    "Citations",
    "Comment-specific indicators",
    "Miscellaneous",
    "Historical indicators",
}
# Back matter: references and navigation, not rubric.
BACK_MATTER = ("See also", "Notes", "References", "Further reading", "External links")


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=30) as resp:
        if resp.status != 200:
            raise RuntimeError(f"{url} returned HTTP {resp.status}")
        return resp.read().decode("utf-8")


def to_markdown(html: str) -> str:
    md = markdownify(html, heading_style="ATX", strip=["img", "a"])
    md = re.sub(r"\[\d+\]", "", md)  # footnote markers
    return re.sub(r"\n{3,}", "\n\n", md).strip()


def trim(md: str) -> tuple[str, list[str]]:
    cut = re.search(rf"(?m)^## ({'|'.join(BACK_MATTER)})\s*$", md)
    if cut:
        md = md[: cut.start()].strip()

    kept, dropped = [], []
    parts = re.split(r"(?m)^## (.+)$", md)
    preamble = parts[0].strip()
    for name, body in zip(parts[1::2], parts[2::2]):
        name = name.strip()
        if name in DROP_SECTIONS:
            dropped.append(name)
        else:
            kept.append(f"## {name}\n{body.rstrip()}")
    return "\n\n".join(([preamble] if preamble else []) + kept), dropped


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--stdout", action="store_true", help="print instead of writing rubric.md")
    args = ap.parse_args()

    md, dropped = trim(to_markdown(fetch(URL)))

    if args.stdout:
        print(md)
    else:
        out = pathlib.Path.home() / ".cache" / "review-ai-writing" / "rubric.md"
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(md)
        print(f"wrote {out} — {len(md):,} chars (~{len(md) // 4:,} tokens)", file=sys.stderr)

    # Say what was dropped. Silent trimming is the bug this script exists to avoid.
    for name in dropped:
        print(f"dropped section (wikipedia-specific): {name}", file=sys.stderr)
    print(f"dropped back matter: {', '.join(BACK_MATTER)}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

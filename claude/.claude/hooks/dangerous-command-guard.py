#!/usr/bin/env python3
"""Steer Claude Code away from destructive commands without blocking on a human.

Guards deny with a reason, which Claude reads and works around, rather than
asking for confirmation, which stalls unattended sessions.

Current guards:
  - `git commit --amend` when HEAD is already on a remote (amending it would
    need a force-push). Amending an unpushed commit is allowed.

Commands are tokenised so a guard only fires when the thing is actually being
run, not when its text appears in a grep pattern, a commit message or an echo.
"""
import json
import os
import re
import shlex
import subprocess
import sys

AMEND_REASON = (
    "HEAD is already pushed to a remote ({refs}), so amending it would rewrite "
    "published history and need a force-push. Do not amend: create a new commit "
    "on top instead."
)

SEPARATORS = set("();|&\n")
WRAPPERS = {"sudo", "command", "env", "time", "nohup", "exec", "builtin"}
SHELLS = {"sh", "bash", "zsh", "dash"}
# git global options that take a separate value, e.g. `git -c k=v commit`.
GIT_VALUE_OPTS = {"-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"}
SUBSHELL = re.compile(r"\$\(([^()]*)\)|`([^`]*)`")
AMEND_FALLBACK = re.compile(r"\bgit\s+commit\b.*--amend\b")


def segments(command):
    """Split a shell command line into simple commands, each a token list."""
    lexer = shlex.shlex(command, posix=True, punctuation_chars="();<>|&\n")
    lexer.whitespace = " \t\r"
    lexer.commenters = ""
    segment = []
    for token in lexer:
        if token and set(token) <= SEPARATORS:
            yield segment
            segment = []
        else:
            segment.append(token)
    yield segment


def git_invocations(command, cwd, depth=0):
    """Yield (subcommand, args, directory) for every git command the line would run."""
    if depth > 3:
        return
    for tokens in segments(command):
        for token in tokens:
            for match in SUBSHELL.finditer(token):
                yield from git_invocations(match.group(1) or match.group(2) or "", cwd, depth + 1)

        tokens = [t.lstrip("`$") for t in tokens]
        while tokens and (
            tokens[0] in WRAPPERS or re.match(r"^\w+=", tokens[0]) or not tokens[0]
        ):
            tokens.pop(0)
        if not tokens:
            continue

        name = os.path.basename(tokens[0])
        if name == "cd" and len(tokens) > 1:
            cwd = os.path.join(cwd, os.path.expanduser(tokens[1]))
        elif name in SHELLS and "-c" in tokens:
            script = tokens[tokens.index("-c") + 1 : tokens.index("-c") + 2]
            if script:
                yield from git_invocations(script[0], cwd, depth + 1)
        elif name == "eval":
            yield from git_invocations(" ".join(tokens[1:]), cwd, depth + 1)
        elif name == "git":
            rest, directory = tokens[1:], cwd
            while rest and rest[0].startswith("-"):
                if rest[0] == "-C" and len(rest) > 1:
                    directory = os.path.join(directory, os.path.expanduser(rest[1]))
                    rest = rest[2:]
                else:
                    rest = rest[2:] if rest[0] in GIT_VALUE_OPTS else rest[1:]
            if rest:
                args = rest[1:]
                if "--" in args:
                    args = args[: args.index("--")]
                yield rest[0], args, directory


def remote_refs_containing_head(directory):
    """Remote branches that already contain HEAD; empty if unpushed or unknown."""
    try:
        result = subprocess.run(
            ["git", "-C", directory, "branch", "-r", "--contains", "HEAD"],
            capture_output=True,
            text=True,
            timeout=5,
        )
    except (OSError, subprocess.SubprocessError):
        return []
    if result.returncode != 0:
        return []
    return [line.strip() for line in result.stdout.splitlines() if "->" not in line and line.strip()]


def check(command, cwd):
    """Return a denial reason, or None to let the command through."""
    try:
        amend_dirs = [
            directory
            for subcommand, args, directory in git_invocations(command, cwd)
            if subcommand == "commit" and "--amend" in args
        ]
    except ValueError:
        # Couldn't tokenise (unbalanced quotes etc.): fall back to a text match.
        amend_dirs = [cwd] if AMEND_FALLBACK.search(command) else []

    for directory in amend_dirs:
        refs = remote_refs_containing_head(directory)
        if refs:
            return AMEND_REASON.format(refs=", ".join(refs[:3]))
    return None


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    command = input_data.get("tool_input", {}).get("command", "")
    reason = check(command, input_data.get("cwd") or os.getcwd())
    if reason:
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            }
        }
        print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    main()

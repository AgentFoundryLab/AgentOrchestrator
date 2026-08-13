#!/usr/bin/env python3
"""Summarize agent session JSONL files and parent/sub-agent relationships.

Works across both Codex (~/.codex/sessions/**/*.jsonl, flat dir, explicit
`session_meta.payload.source.subagent.thread_spawn.parent_thread_id` linkage)
and Claude Code (~/.claude/projects/<encoded-cwd>/**/*.jsonl, parent-child
linkage encoded by directory nesting: `<sessionId>/subagents/agent-<id>.jsonl`)
session-log layouts. Format is auto-detected per file; pass --runtime to force
one, or --sessions-dir to point at an arbitrary root (mixed layouts under one
root are fine — each file is sniffed independently).
"""
from __future__ import annotations

import argparse
import json
import os
import re
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

UUID_RE = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", re.IGNORECASE)
SECRET_RE = re.compile(r"(?i)(api[_-]?key|token|secret|password|authorization|cookie)(\s*[=:]\s*)([^\s,'\"]+)")

FAILURE_KEYWORDS = ["failed", "error", "blocker", "not validated", "spawn failed", "request_changes", "blocked"]
TOOL_KEYWORDS = [
    "git commit", "git add", "spawn_agent", "wait_agent", "apply_patch",  # codex
    '"type":"tool_use"', '"type":"tool_result"', 'tooluseresult',        # claude
]


def redact(text: str, limit: int = 240) -> str:
    text = SECRET_RE.sub(r"\1\2<redacted>", text.replace("\n", " "))
    return text[:limit] + ("…" if len(text) > limit else "")


@dataclass
class Session:
    id: str
    path: Path
    runtime: str = "unknown"
    ts: str = ""
    cwd: str = ""
    branch: str = ""
    parent: str | None = None
    nickname: str = ""
    role: str = ""
    thread_source: str = ""
    counts: Counter = field(default_factory=Counter)
    notable: list[str] = field(default_factory=list)
    refs: set[str] = field(default_factory=set)


def iter_jsonl(path: Path):
    try:
        with path.open("r", encoding="utf-8") as fh:
            for line_no, line in enumerate(fh, 1):
                line = line.strip()
                if not line:
                    continue
                try:
                    yield line_no, json.loads(line)
                except json.JSONDecodeError:
                    yield line_no, {"type": "_decode_error", "raw": line[:200]}
    except OSError:
        return


def sniff_runtime(path: Path) -> str:
    """Peek at the first well-formed line to tell codex vs. claude layout apart."""
    for _, event in iter_jsonl(path):
        if event.get("type") == "_decode_error":
            continue
        if "sessionId" in event or "uuid" in event or "parentUuid" in event:
            return "claude"
        if event.get("type") == "session_meta" or "payload" in event:
            return "codex"
        return "unknown"
    return "unknown"


def parse_session_codex(path: Path) -> Session | None:
    sid = path.stem.split("-")[-1]
    sess = Session(id=sid, path=path, runtime="codex")
    for line_no, event in iter_jsonl(path):
        etype = event.get("type", "unknown")
        sess.counts[etype] += 1
        payload = event.get("payload", {})
        if etype == "session_meta":
            meta = payload if isinstance(payload, dict) else {}
            sess.id = meta.get("id") or sess.id
            sess.ts = meta.get("timestamp", "")
            sess.cwd = meta.get("cwd", "")
            sess.thread_source = meta.get("thread_source", "")
            sess.nickname = meta.get("agent_nickname", "") or ""
            git = meta.get("git") if isinstance(meta.get("git"), dict) else {}
            sess.branch = git.get("branch", "") or ""
            source = meta.get("source") if isinstance(meta.get("source"), dict) else {}
            subagent = source.get("subagent") if isinstance(source.get("subagent"), dict) else {}
            sub = subagent.get("thread_spawn") if isinstance(subagent.get("thread_spawn"), dict) else {}
            sess.parent = sub.get("parent_thread_id") or meta.get("forked_from_id") or None
            sess.role = sub.get("agent_role") or meta.get("agent_role") or ""
        blob = json.dumps(event, ensure_ascii=False, sort_keys=True)
        for ref in UUID_RE.findall(blob):
            sess.refs.add(ref)
        low = blob.lower()
        if any(k in low for k in FAILURE_KEYWORDS):
            sess.notable.append(f"L{line_no} {etype}: {redact(blob)}")
        elif any(k in low for k in TOOL_KEYWORDS):
            sess.notable.append(f"L{line_no} {etype}: {redact(blob)}")
    return sess if sess.id else None


def parse_session_claude(path: Path) -> Session | None:
    # Claude Code root sessions live at <projects-dir>/<sessionId>.jsonl; sub-agent
    # transcripts live at <projects-dir>/<parentSessionId>/subagents/agent-<agentId>.jsonl
    # (their own `sessionId` field is inherited from the parent, not a new id — the
    # directory nesting is the actual parent link).
    is_subagent = path.parent.name == "subagents"
    own_id = path.stem
    if is_subagent and own_id.startswith("agent-"):
        own_id = own_id[len("agent-"):]
    sess = Session(id=own_id, path=path, runtime="claude")
    if is_subagent:
        sess.parent = path.parent.parent.name
        sess.thread_source = "subagent"
    first_ts = ""
    for line_no, event in iter_jsonl(path):
        etype = event.get("type", "unknown")
        sess.counts[etype] += 1
        if not sess.cwd and event.get("cwd"):
            sess.cwd = event["cwd"]
        if not sess.branch and event.get("gitBranch"):
            sess.branch = event["gitBranch"]
        if not first_ts and event.get("timestamp"):
            first_ts = event["timestamp"]
        if not sess.nickname and event.get("slug"):
            sess.nickname = event["slug"]
        if not sess.role and event.get("attributionAgent"):
            sess.role = event["attributionAgent"]
        if not is_subagent and not sess.parent and event.get("isSidechain") is True:
            # A root-session file that is itself flagged sidechain (rare) — leave
            # parent unset; directory nesting couldn't tell us more than this.
            pass
        blob = json.dumps(event, ensure_ascii=False, sort_keys=True)
        for ref in UUID_RE.findall(blob):
            sess.refs.add(ref)
        low = blob.lower()
        if any(k in low for k in FAILURE_KEYWORDS):
            sess.notable.append(f"L{line_no} {etype}: {redact(blob)}")
        elif any(k in low for k in TOOL_KEYWORDS):
            sess.notable.append(f"L{line_no} {etype}: {redact(blob)}")
    sess.ts = first_ts
    return sess if sess.id else None


def parse_session(path: Path, runtime_hint: str = "auto") -> Session | None:
    runtime = runtime_hint if runtime_hint != "auto" else sniff_runtime(path)
    if runtime == "codex":
        return parse_session_codex(path)
    if runtime == "claude":
        return parse_session_claude(path)
    return None


def default_roots(runtime: str, project_cwd: str) -> list[Path]:
    home = Path.home()
    encoded_cwd = project_cwd.replace(os.sep, "-")
    roots = []
    if runtime in ("auto", "codex"):
        roots.append(home / ".codex" / "sessions")
    if runtime in ("auto", "claude"):
        roots.append(home / ".claude" / "projects" / encoded_cwd)
    return [r for r in roots if r.exists()]


def load_sessions(roots: list[Path], runtime_hint: str) -> dict[str, Session]:
    sessions: dict[str, Session] = {}
    for root in roots:
        for path in root.rglob("*.jsonl"):
            sess = parse_session(path, runtime_hint)
            if sess:
                sessions[sess.id] = sess
    return sessions


def load_workflow_runs(roots: list[Path]) -> list[dict]:
    """Claude Code Workflow-tool run journals: <sessionId>/workflows/wf_*.json."""
    runs: list[dict] = []
    for root in roots:
        for path in root.rglob("workflows/wf_*.json"):
            try:
                data = json.loads(path.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError):
                continue
            data["_path"] = str(path)
            data["_session"] = path.parent.parent.name
            runs.append(data)
    return runs


def choose_root(
    sessions: dict[str, Session],
    target: str | None,
    latest_main: bool,
    cwd_contains: str | None,
    runtime_hint: str,
) -> str:
    if target:
        p = Path(target)
        if p.exists():
            s = parse_session(p, runtime_hint)
            if s:
                sessions[s.id] = s
                return s.id
        if target in sessions:
            return target
        matches = [sid for sid in sessions if sid.startswith(target)]
        if matches:
            return sorted(matches)[-1]
        raise SystemExit(f"No session matched {target!r}")
    candidates = list(sessions.values())
    if cwd_contains:
        candidates = [s for s in candidates if cwd_contains in s.cwd]
        if not candidates:
            raise SystemExit(f"No sessions found with cwd containing {cwd_contains!r}")
    if latest_main:
        candidates = [s for s in candidates if not s.parent]
    if not candidates:
        raise SystemExit("No sessions found")
    return sorted(candidates, key=lambda s: (s.path.stat().st_mtime, s.id))[-1].id


def descendants(root_id: str, sessions: dict[str, Session]) -> list[str]:
    children: dict[str, list[str]] = defaultdict(list)
    for sid, sess in sessions.items():
        if sess.parent:
            children[sess.parent].append(sid)
    out: list[str] = []
    stack = [root_id]
    seen = set()
    while stack:
        sid = stack.pop()
        if sid in seen:
            continue
        seen.add(sid)
        out.append(sid)
        stack.extend(sorted(children.get(sid, []), reverse=True))
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", choices=["auto", "codex", "claude"], default="auto",
                         help="Force a session-log layout instead of auto-detecting per file.")
    parser.add_argument("--sessions-dir", action="append",
                         help="Explicit root(s) to scan (repeatable). Defaults to the runtime's "
                              "standard root(s): ~/.codex/sessions and/or ~/.claude/projects/<encoded-cwd>.")
    parser.add_argument("--project-cwd", default=os.getcwd(),
                         help="cwd used to compute the default Claude Code projects dir (ignored if --sessions-dir given).")
    parser.add_argument("--session", help="Root session id/prefix or JSONL path. Defaults to latest main session.")
    parser.add_argument("--latest-any", action="store_true", help="Default to newest session even if it is a sub-agent.")
    parser.add_argument(
        "--cwd-contains",
        help="When --session is omitted, choose the newest candidate whose session cwd contains this substring.",
    )
    parser.add_argument("--max-notable", type=int, default=8)
    parser.add_argument("--no-workflow-runs", action="store_true",
                         help="Skip listing Claude Code Workflow-tool run journals found under the scanned roots.")
    args = parser.parse_args()

    roots = [Path(p).expanduser() for p in args.sessions_dir] if args.sessions_dir else default_roots(args.runtime, args.project_cwd)
    if not roots:
        raise SystemExit("No session roots found/exist; pass --sessions-dir explicitly.")

    sessions = load_sessions(roots, args.runtime)
    root_id = choose_root(
        sessions,
        args.session,
        latest_main=not args.latest_any,
        cwd_contains=args.cwd_contains,
        runtime_hint=args.runtime,
    )
    graph = descendants(root_id, sessions)

    print(f"# Session graph\n")
    if not args.session:
        selector = "latest main session" if not args.latest_any else "latest session including sub-agents"
        if args.cwd_contains:
            selector += f" with cwd containing `{args.cwd_contains}`"
        print(f"Selection warning: root was selected heuristically as {selector}; pass --session for deterministic analysis.")
    print(f"Root: {root_id}")
    roots_str = ", ".join(f"`{r}`" for r in roots)
    print(f"Sessions inspected: {len(graph)} of {len(sessions)} loaded from {roots_str}\n")
    for sid in graph:
        s = sessions[sid]
        kind = "sub-agent" if s.parent else "root"
        print(f"## {kind}: {sid} ({s.runtime})")
        print(f"- file: `{s.path}`")
        print(f"- timestamp: {s.ts or 'unknown'}")
        print(f"- cwd: `{s.cwd}`" if s.cwd else "- cwd: unknown")
        if s.branch:
            print(f"- branch: `{s.branch}`")
        if s.parent:
            print(f"- parent: `{s.parent}`")
        if s.nickname or s.role:
            print(f"- agent: {s.nickname or 'unknown'} {f'({s.role})' if s.role else ''}")
        print(f"- event counts: {dict(s.counts)}")
        if s.notable:
            print("- notable evidence:")
            for item in s.notable[: args.max_notable]:
                print(f"  - {item}")
        print()

    if not args.no_workflow_runs:
        runs = load_workflow_runs(roots)
        if runs:
            print("## Workflow-tool runs found under scanned roots\n")
            for run in runs:
                print(f"- `{run.get('_path')}` — session `{run.get('_session')}`, "
                      f"workflow `{run.get('workflowName', 'unknown')}`, status `{run.get('status', 'unknown')}`, "
                      f"agents {run.get('agentCount', '?')}, tokens {run.get('totalTokens', '?')}, "
                      f"duration {run.get('durationMs', '?')}ms")


if __name__ == "__main__":
    main()

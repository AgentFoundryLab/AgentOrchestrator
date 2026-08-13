#!/usr/bin/env python3
"""Analyze source documents for lossless distillation.

Accepts file paths, folder paths, or globs. Emits JSON with files, rough token
estimates, grouping, routing, and split prediction. This script is read-only.
"""
from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sys
from pathlib import Path

INCLUDE_EXTENSIONS = {".md", ".txt", ".yaml", ".yml", ".json"}
SKIP_DIRS = {
    "node_modules",
    ".git",
    "__pycache__",
    ".venv",
    "venv",
    ".claude",
    "_bmad-output",
    ".cursor",
    ".vscode",
}
CHARS_PER_TOKEN = 4
SINGLE_MAX_FILES = 3
SINGLE_COMPRESSOR_MAX_TOKENS = 15_000
SINGLE_DISTILLATE_MAX_TOKENS = 5_000

DOC_TYPE_PATTERNS = [
    (r"discovery[_-]notes", "discovery-notes"),
    (r"product[_-]brief", "product-brief"),
    (r"research[_-]report", "research-report"),
    (r"architecture", "architecture-doc"),
    (r"requirements", "requirements"),
    (r"work[_-]?order|wo-\d+", "work-order"),
    (r"prd", "prd"),
    (r"spec", "specification"),
    (r"design[_-]doc", "design-doc"),
    (r"meeting[_-]notes", "meeting-notes"),
    (r"readme", "readme"),
    (r"changelog", "changelog"),
    (r"distillate", "distillate"),
]

GROUP_PATTERNS = [
    (r"^(.+?)(?:-discovery-notes|-discovery_notes)\.(\w+)$", r"\1.\2"),
    (r"^(.+?)(?:-appendix|-addendum)(?:-\w+)?\.(\w+)$", r"\1.\2"),
    (r"^(.+?)(?:-review|-feedback)\.(\w+)$", r"\1.\2"),
    (r"^(WO-\d+)(?:-.+)?\.(md)$", r"\1.md"),
]


def resolve_inputs(inputs: list[str]) -> list[Path]:
    files: list[Path] = []
    for raw in inputs:
        path = Path(raw)
        if path.is_file() and path.suffix.lower() in INCLUDE_EXTENSIONS:
            files.append(path.resolve())
        elif path.is_dir():
            for root, dirs, names in os.walk(path):
                dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
                for name in sorted(names):
                    file_path = Path(root) / name
                    if file_path.suffix.lower() in INCLUDE_EXTENSIONS:
                        files.append(file_path.resolve())
        else:
            for match in sorted(glob.glob(raw, recursive=True)):
                file_path = Path(match)
                if file_path.is_file() and file_path.suffix.lower() in INCLUDE_EXTENSIONS:
                    files.append(file_path.resolve())

    seen: set[Path] = set()
    deduped: list[Path] = []
    for file_path in files:
        if file_path not in seen:
            seen.add(file_path)
            deduped.append(file_path)
    return deduped


def detect_doc_type(filename: str) -> str:
    lower = filename.lower()
    for pattern, doc_type in DOC_TYPE_PATTERNS:
        if re.search(pattern, lower):
            return doc_type
    return "unknown"


def estimate_tokens(file_path: Path) -> int:
    try:
        text = file_path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        text = file_path.read_text(encoding="utf-8", errors="ignore")
    return max(1, len(text) // CHARS_PER_TOKEN)


def suggest_groups(files: list[Path]) -> list[dict]:
    file_map = {f.name: f for f in files}
    assigned: set[str] = set()
    groups: dict[str, list[dict]] = {}
    standalone: list[Path] = []

    for file_path in files:
        if file_path.name in assigned:
            continue
        matched = False
        for pattern, base_pattern in GROUP_PATTERNS:
            if re.match(pattern, file_path.name, re.IGNORECASE):
                base_name = re.sub(pattern, base_pattern, file_path.name, flags=re.IGNORECASE)
                group_key = base_name
                groups.setdefault(group_key, [])
                if base_name in file_map and base_name not in assigned:
                    groups[group_key].append({
                        "path": str(file_map[base_name]),
                        "filename": base_name,
                        "role": "primary",
                    })
                    assigned.add(base_name)
                groups[group_key].append({
                    "path": str(file_path),
                    "filename": file_path.name,
                    "role": "companion",
                })
                assigned.add(file_path.name)
                matched = True
                break
        if not matched:
            standalone.append(file_path)

    result = [
        {"group_key": key, "files": members}
        for key, members in sorted(groups.items())
    ]
    for file_path in standalone:
        if file_path.name not in assigned:
            result.append({
                "group_key": file_path.name,
                "files": [{"path": str(file_path), "filename": file_path.name, "role": "standalone"}],
            })
    return result


def analyze(inputs: list[str]) -> dict:
    files = resolve_inputs(inputs)
    if not files:
        return {"status": "error", "error": "No readable source files found", "inputs": inputs}

    details = []
    total_tokens = 0
    total_size = 0
    for file_path in files:
        size = file_path.stat().st_size
        tokens = estimate_tokens(file_path)
        total_size += size
        total_tokens += tokens
        details.append({
            "path": str(file_path),
            "filename": file_path.name,
            "size_bytes": size,
            "estimated_tokens": tokens,
            "doc_type": detect_doc_type(file_path.name),
        })

    if len(files) <= SINGLE_MAX_FILES and total_tokens <= SINGLE_COMPRESSOR_MAX_TOKENS:
        routing = "single"
        routing_reason = f"{len(files)} file(s), ~{total_tokens:,} tokens; within single-distillate analysis threshold"
    else:
        routing = "fan-out"
        routing_reason = f"{len(files)} file(s), ~{total_tokens:,} tokens; split/group before compression"

    estimated_distillate_tokens = max(1, total_tokens // 3)
    split_prediction = "likely" if estimated_distillate_tokens > SINGLE_DISTILLATE_MAX_TOKENS else "unlikely"
    split_reason = (
        f"Estimated distillate ~{estimated_distillate_tokens:,} tokens; "
        f"threshold {SINGLE_DISTILLATE_MAX_TOKENS:,}"
    )

    return {
        "status": "ok",
        "files": details,
        "summary": {
            "total_files": len(files),
            "total_size_bytes": total_size,
            "total_estimated_tokens": total_tokens,
        },
        "groups": suggest_groups(files),
        "routing": {"recommendation": routing, "reason": routing_reason},
        "split_prediction": {
            "prediction": split_prediction,
            "reason": split_reason,
            "estimated_distillate_tokens": estimated_distillate_tokens,
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("inputs", nargs="+", help="File paths, folders, or glob patterns")
    parser.add_argument("-o", "--output", help="Write JSON to file instead of stdout")
    args = parser.parse_args()

    result = analyze(args.inputs)
    text = json.dumps(result, indent=2)
    if args.output:
        output = Path(args.output)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(text + "\n", encoding="utf-8")
    else:
        print(text)
    return 0 if result.get("status") == "ok" else 1


if __name__ == "__main__":
    sys.exit(main())

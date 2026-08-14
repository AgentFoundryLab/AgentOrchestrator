---
name: qmd
description: Search local markdown knowledge bases, notes, docs, and wikis with the qmd CLI. Use when users ask to find notes, retrieve documents, inspect a wiki, answer from indexed markdown, or set up QMD access.
license: MIT
metadata:
  author: tobi
  version: "2.1.0"
allowed-tools: Bash(qmd:*), mcp__qmd__query, mcp__qmd__get, mcp__qmd__multi_get, mcp__qmd__status
---

# QMD

- Local markdown retrieval. Prefer the `qmd ...` CLI for `search`/`vsearch`. For multi-signal (`lex`/`vec`/`hyde`) queries, use `mcp__qmd__query` directly — not a fallback for this case.
- **First use in a repo:** run `qmd status` — if it reports the default/global index (no project-local `.qmd/`), run `qmd init` first so this repo gets its own isolated index; skipping `init` silently indexes into the shared global cache instead. Then, if `qmd collection list` is empty, index docs once with `qmd collection add <docs-dir> --name <name> && qmd update && qmd embed` before querying. Git hooks do not run QMD updates or embeddings; refresh explicitly when the index is stale.
- The bundled `scripts/qmd-throttled` launcher pins all CLI and MCP processes to the same low-priority CPU set (default three logical CPUs, override `QMD_CPUS`). This is a hard aggregate ceiling across concurrent QMD processes, not a per-process allowance.
- QMD is disabled in linked Git worktrees. Use the repository's primary checkout for explicit QMD refresh and retrieval.

## Workflow

```bash
qmd collection list
qmd ls
qmd status
```

Search, then fetch source before answering:

```bash
# Exact IDs, titles, phrases, rare terms (BM25, fast).
qmd search "WO-101 subagents installer flags" -c project-docs -n 5

# Conceptual/NL recall (vector).
qmd vsearch "how are skills namespaced per runtime" -c project-docs -n 5

# Retrieve source text.
qmd get qmd://project-docs/development/workorders/WO-101.md -l 80
qmd multi-get 'architecture/ADR/{ADR-FND-004.md,ADR-FND-014.md}' --md
```

## Rules

- Use `qmd search` for exact IDs/titles/terms; `qmd vsearch` for conceptual/NL questions. Complementary — use both when unsure. Keep `search --limit ≤5` or BM25 results truncate.
- Avoid plain-text `qmd query` (CLI or MCP): it always auto-expands via a local LLM, fully local via node-llama-cpp, pinning cores on CPU-only hosts regardless of `--no-rerank`/`rerank: false`. Skip expansion by supplying typed sub-queries instead: `mcp__qmd__query` with `searches: [{type:'lex',...},{type:'vec',...}]` and `rerank: false`, or the CLI equivalent `qmd query $'lex: ...\nvec: ...' --no-rerank`. Reserve plain-text auto-expand for unknown vocabulary, on a GPU host when possible.
- Answer from fetched documents, not snippets alone; cite paths/docids.
- Index/setup commands (`qmd collection add`, `qmd update`, `qmd embed`) are for first index of an unindexed repo or an explicitly stale index. Git hooks intentionally do not run QMD.
- If the index is stale or semantic query is slow/fails, say so and fall back to sharper lexical search.

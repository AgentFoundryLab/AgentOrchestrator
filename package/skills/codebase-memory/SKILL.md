---
name: codebase-memory
description: Use the local codebase-memory-mcp CLI for structural code discovery before broad grep/read. Use for architecture exploration, route/function/type lookup, callers/callees, dependency impact, dead-code/refactor candidates, and compact source retrieval from an indexed code graph. Prefer the CLI; the MCP server is an enabled fallback.
---

# Codebase Memory CLI

- Use `codebase-memory-mcp cli ...` for local structural code graph queries. Prefer this CLI; the `codebase-memory-mcp` MCP server is an enabled fallback, not the default.
- **First use in a repo:** run `codebase-memory-mcp cli list_projects '{}'`. If no projects, index with `index_repository` (below) before any query, then re-run `index_repository` after significant local changes. Use `detect_changes` to check whether the graph has gone stale before trusting a query.

## When to use

Use before broad `grep`/`rg` or opening many files when the task involves:

- codebase architecture or ownership discovery;
- route, handler, function, class, type, or module lookup;
- callers/callees, dependency impact, fan-in/fan-out, or call-chain tracing;
- dead-code, refactor-candidate, or high-coupling analysis;
- locating a compact exact source slice before editing;
- checking whether an index is stale after local changes.

Use plain `grep`/`rg` for raw text, config, docs, generated data, dynamic strings, or a stale/incomplete graph.

## CLI basics

Check availability:

```bash
codebase-memory-mcp --version
codebase-memory-mcp cli list_projects '{}'
```

Index or refresh the active repository:

```bash
codebase-memory-mcp cli index_repository '{"repo_path":"/absolute/repo/path"}'
```

If multiple projects are indexed, pass the project name from `list_projects` in subsequent calls.

## Discovery workflow

1. List/index projects.
2. Inspect architecture or schema if needed.
3. Use narrow symbol/route/type queries.
4. Trace callers/callees or dependencies.
5. Fetch exact snippets or open source files before edits.
6. If source and graph disagree, re-index or report stale index.

Useful commands:

```bash
# Architecture overview.
codebase-memory-mcp cli get_architecture '{"project":"my-project"}'

# Find symbols/routes/types/classes/functions by name pattern.
codebase-memory-mcp cli search_graph '{"project":"my-project","name_pattern":".*Handler.*","label":"Function"}'

# Find raw code text when graph structure is insufficient.
codebase-memory-mcp cli search_code '{"project":"my-project","query":"generateDocument"}'

# Trace callers/callees.
codebase-memory-mcp cli trace_path '{"project":"my-project","function_name":"OrderHandler","direction":"both","depth":3}'

# Detect impacted graph nodes from local changes.
codebase-memory-mcp cli detect_changes '{"project":"my-project"}'

# Read exact source slice.
codebase-memory-mcp cli get_code_snippet '{"project":"my-project","qualified_name":"pkg.orders.OrderHandler"}'

# Complex graph query.
codebase-memory-mcp cli query_graph '{"project":"my-project","query":"MATCH (n) RETURN n LIMIT 10"}'
```

## Rules

- Keep output small: query specific symbols/files, not broad dumps.
- Prefer graph queries for structure; use `grep`/`rg` only for text/config/dynamic strings or stale indexes.
- Before editing, read the exact source slice with `get_code_snippet` or normal file reads.
- Do not treat the graph as source of truth; source/runtime/tests win.
- Do not commit CBM cache/database/index artifacts unless the repo explicitly allows it.
- CBM 0.6.1 is local structural analysis and exposes no provider setting. Do not wrap commands with paid-provider credentials or make embedding/model claims.

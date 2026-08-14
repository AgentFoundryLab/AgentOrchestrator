# Serena MCP Integration

**Version**: 0.1.0

Documentation for Serena MCP usage in AgentOrchestrator.

---

## Overview

Serena MCP provides persistent memory and symbolic code operations for Orchestrator. It enables:
- Cross-session knowledge persistence
- Error learning capture (via `$meta-learn`)
- Validation record storage
- Codebase semantic understanding

---

## Project Initialization

The Orchestrator installer automatically initializes Serena for new projects:

```bash
./install.sh --project /path/to/your/project
```

This runs:
```bash
uvx --from git+https://github.com/oraios/serena serena project create --name <project-name>
```

The command auto-detects programming languages and creates `.serena/project.yml`.

### Manual Initialization

If automatic initialization fails (e.g., `uvx` not installed):

```bash
cd /path/to/your/project
uvx --from git+https://github.com/oraios/serena serena project create
```

---

## Memory Tiers

[`ADR-FND-002`](../docs/architecture/ADR/ADR-FND-002.md) owns the four-tier model and is the only
place it is defined; the copy that used to sit here drifted from it and is gone.

One tier in that ADR — **Reflexion**, "error learnings" — is named for a skill that no longer exists.
Nothing writes it. Retiring or renaming the tier is an architecture decision, so it stays as the ADR
records it until `$architect` revisits it.

---

## Memory Namespaces

> **No skill currently writes Serena memories.** Nothing in `package/` issues `write_memory` or
> `read_memory`; `setup-project.sh` creates an empty `.serena/memories/` and no stage fills it. The
> namespaces below are the convention to follow *if* you write one by hand or a future skill adopts
> the tier model — they are not a description of observed behavior. Durable findings today are files.

| Namespace | Holds | Written by |
|---|---|---|
| `knowledge/` | Domain concepts, architecture patterns, team conventions | nothing today |
| `validation/` | Test results, `AC`/`TRC` verification, quality checks | nothing today; `/validate` writes `docs/validation/` instead |
| `meta-learn/` | Failure modes, root causes, prevention | nothing today; `$meta-learn` writes memo files instead |

The `reflexion/` and `reflect/` namespaces are retired. The skills that defined them —
`$reflexion`, `$reflect`, and `$optimize` — were absorbed into `$meta-learn`, which reads real
session transcripts rather than hand-written records. `REQ-007` is `Decommissioned` for that reason,
superseded by `REQ-008`.

**Where durable findings actually go**:

| Finding | Path | Owner |
|---|---|---|
| Repo failure modes | `reports/analysis/<date>-<slug>-repo-failure-modes.md` | `$meta-learn` |
| Instruction fixes | `reports/meta-optimization/<date>-<slug>-instruction-fixes.md` | `$meta-learn` |
| `AC`/`TRC` coverage | `docs/validation/` | `/validate` |
| Project knowledge | `docs/knowledge/` | `/document`, `/architect` |

---

## Serena Tools

### Memory Operations

| Tool | Purpose |
|------|---------|
| `read_memory` | Retrieve stored knowledge |
| `write_memory` | Store new knowledge |
| `list_memories` | List available memories |
| `delete_memory` | Remove outdated memory |

### Code Operations

| Tool | Purpose |
|------|---------|
| `find_symbol` | Locate code symbols |
| `get_definition` | Get symbol definition |
| `find_references` | Find symbol usage |
| `get_hover_info` | Get type/doc info |

---

## Usage Patterns

### Session learning — what actually happens

```
$meta-learn
-> scripts/session_graph.py maps the session graph from JSONL transcripts
-> classifies failure modes
-> writes reports/analysis/<date>-<slug>-repo-failure-modes.md
-> writes reports/meta-optimization/<date>-<slug>-instruction-fixes.md
```

No `write_memory` call is involved. The transcripts are the evidence and the memos are the record.

### Retrieving knowledge

```
/implement WO-101
-> Agent needs context
-> read_memory("knowledge/api-patterns")   # only if a memory was written by hand
-> otherwise: docs/knowledge/ and $qmd
```

---

## Configuration

### Global Settings (`~/.claude/settings.json`)

Serena is configured in the global settings:

```json
{
  "mcpServers": {
    "serena": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/oraios/serena", "serena", "start-mcp-server", "--context", "claude-code"],
      "env": {}
    }
  }
}
```

### Project Configuration (`.serena/project.yml`)

Auto-generated during `--project` installation. Contains:
- Project name
- Detected languages
- Analysis settings

---

## Best Practices

### 1. Namespace Consistently
Use the prefixes in **Memory Namespaces** above: `knowledge/`, `validation/`, `meta-learn/`. Never
`reflexion/` or `reflect/` — those are retired.

### 2. Date-Prefix Temporal Records
Include the date in any time-bound key:
```
meta-learn/2026-01-24-description
```

### 3. Keep Records Focused
Each memory entry should cover one topic. Split large content into multiple entries.

### 4. Clean Up Transient Data
Validation records can be pruned after tasks complete. Don't let transient data accumulate.

### 5. Reference, Don't Duplicate
Link to code and docs rather than copying content into memory.

---

## Troubleshooting

### Memory Not Found

1. Check namespace spelling
2. Verify memory was written successfully
3. Use `list_memories` to see available entries

### Serena Not Available

1. Check `~/.claude/settings.json` configuration
2. Verify `uvx` is installed (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
3. Restart Claude Code session
4. Check `.serena/project.yml` exists in project root

### Memory Too Large

1. Split into smaller entries
2. Store summary with references
3. Use code links instead of copying

### Project Init Failed

1. Ensure `uvx` is installed
2. Run manually: `cd <project> && uvx --from git+https://github.com/oraios/serena serena project create`
3. Check for write permissions in project directory

---

## References

- [ADR-FND-002: Four-Tier Memory](../docs/architecture/ADR/ADR-FND-002.md)
- [ADR-FND-003: Minimal MCP Footprint](../docs/architecture/ADR/ADR-FND-003.md)
- [Serena MCP Documentation](https://github.com/oraios/serena)

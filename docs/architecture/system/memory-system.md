# Memory System Architecture

> **Tier 1 is real. Tiers 2–4 are not built.** `ADR-FND-002` specifies a four-tier model; its
> 2026-08-14 amendment records that nothing implements it — no skill in `package/` issues
> `write_memory` or `read_memory`, and `.serena/memories/` is created empty and never filled.
> `WO-128`/`WO-129`/`WO-130` under `PLAN-003` own building it. What is durable today is files.

```
+=========================================================================+
|                          MEMORY SYSTEM                                   |
+=========================================================================+

TIER 1: SESSION (Automatic)                              [IMPLEMENTED]
+--------------------------------------------------+
| Storage: ~/.claude/projects/<slug>/<id>.jsonl     |
|          sub-agents: <id>/subagents/agent-*.jsonl |
| Format:  JSONL (runtime native)                  |
| Access:  $CLAUDE_CODE_SESSION_ID                 |
| Writes:  Automatic (the runtime)                 |
| Reads:   /meta-learn via session_graph.py --self |
+--------------------------------------------------+

TIER 2: SEMANTIC                                         [NOT BUILT]
+--------------------------------------------------+
| Storage: Serena memories (knowledge/)            |
| Writes:  nothing                                 |
| Reads:   nothing                                 |
| Today:   docs/knowledge/ as versioned files      |
+--------------------------------------------------+

TIER 3: REFLEXION                                        [NOT BUILT]
+--------------------------------------------------+
| Storage: Serena memories (reflexion/)            |
| Writes:  nothing                                 |
| Named for $reflexion, a skill $meta-learn        |
| absorbed; REQ-007 is Decommissioned              |
| Today:   docs/analysis/ +                        |
|          reports/meta-optimization/ memos        |
+--------------------------------------------------+

TIER 4: TRANSIENT                                        [NOT BUILT]
+--------------------------------------------------+
| Storage: Serena memories (validation/)           |
| Writes:  nothing                                 |
| Today:   docs/validation/ coverage documents     |
+--------------------------------------------------+
```

## Agent Init Memory Loading

| Tier | Load Pattern | Content | State |
|------|--------------|---------|-------|
| **Session** | N/A (the runtime manages) | Full conversation transcript | Implemented |
| **Semantic** | Auto-load at spawn | Project knowledge, patterns, conventions | Not built |
| **Reflexion** | Query ad-hoc on error | Known issues, causes, solutions | Not built |
| **Transient** | Not loaded | Ephemeral validation records | Not built |

The tier names are `ADR-FND-002`'s and are left as that ADR records them. Renaming an unimplemented
tier would move the drift rather than remove it; the names should be settled by whatever ends up
writing them.

## What is durable today

| Content | Path | Owner |
|---|---|---|
| Project knowledge | `docs/knowledge/` | `/document`, `/architect` |
| Repo failure modes | `docs/analysis/` | `/meta-learn`, `/review`, `/analyse` |
| Instruction fixes | `reports/meta-optimization/` | `/meta-learn` |
| `AC`/`TRC` coverage | `docs/validation/` | `/validate` |
| Session evidence | the runtime's own session dir — read-only, never committed | the runtime |

## Related

- [ADR-FND-002: Four-Tier Memory System](../ADR/ADR-FND-002.md)
- [ADR-FND-003: Minimal MCP Footprint](../ADR/ADR-FND-003.md) — Serena is `Recommended`, not required

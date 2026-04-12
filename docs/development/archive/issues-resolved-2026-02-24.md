# Resolved Issues Archive

**Archived**: 2026-02-24  
**Source**: `docs/development/ISSUES.md` (historical resolved entries)

| ID | Issue | Priority | Closed | Task |
|----|-------|----------|--------|------|
| G-002 | Gemini TOML command transform invalid schema and syntax errors | P1 | 2026-02-24 | T-092 |
| G-003 | No per-runtime frontmatter schema validation/transform in skills and commands install | P1 | 2026-02-24 | T-094, T-095 |
| I-001 | ADR-014 D-2 implementation drift in runtime namespace mapping | P1 | 2026-02-24 | T-096 |
| I-003 | Legacy compatibility/workaround bloat in installer UX/docs | P2 | 2026-02-24 | T-098 |
| I-004 | Codex default profile dual-wrote deprecated prompts artifacts | P1 | 2026-02-24 | T-100 |
| I-005 | Codex agent invocation alignment with official role-config and `/agent` flow | P1 | 2026-02-24 | T-099 |

---

## Closure Summaries

### G-002
Gemini commands transform now emits valid TOML structure and escaping for command-mode generation.

### G-003
Runtime-aware frontmatter normalization/transform pipeline applied across non-Claude targets.

### I-001
Namespace behavior aligned to ADR expectations, including installer checks and regression coverage.

### I-003
Legacy migration-first wording and workaround-oriented UX text were removed or reduced.

### I-004
Codex default flow now follows skills-first behavior; prompt artifacts are compatibility-only.

### I-005
Codex planning/runtime docs and linkage were aligned with official role-config and thread workflow.

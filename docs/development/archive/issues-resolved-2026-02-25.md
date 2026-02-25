# Resolved Issues Archive

**Archived**: 2026-02-25  
**Source**: `docs/development/ISSUES.md` (historical resolved entries)

| ID | Issue | Priority | Closed | Task |
|----|-------|----------|--------|------|
| I-007 | Gemini skill alias precedence collision: `.agents/skills` overrides `.gemini/skills` for duplicate names, causing runtime skill conflicts and unexpected effective behavior | P1 | 2026-02-25 | T-097 |

---

## Closure Summaries

### I-007
Verified resolved after T-097 mitigation landed: Gemini install now prunes duplicate native skills when same-scope Codex alias skills exist, suppressing alias conflict warnings and preserving deterministic effective skill selection.

Verification evidence:
- `[INFO] gemini: pruned duplicate skill 'validate' (alias preferred: /home/node/.agents/skills/validate/SKILL.md)`
- `[INFO] gemini: removed 17 duplicate native skills to suppress alias conflict warnings`

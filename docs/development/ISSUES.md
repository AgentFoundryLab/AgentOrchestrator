# AgentOrchestrator Issues

**Updated**: 2026-02-24

| ID | Issue | Priority | Status | Task |
|----|-------|----------|--------|------|
| G-001 | OpenCode hooks incompatibility: shell hooks are not natively compatible with OpenCode plugin model | P2 | 🔲 Open | `docs/knowledge/decisions/non-claude-hooks-policy.md` |
| I-002 | Gemini capability drift: installer behavior still diverges from expected skills/subagents baseline | P1 | 🔄 Reopened (2026-02-24) | T-097 |

---

## Active Issue Details

### G-001: OpenCode hooks incompatibility

**Type**: Gap  
**Discovered**: 2026-02-22  
**Affects**: OpenCode install flow and runtime capability expectations  
**Task**: `docs/knowledge/decisions/non-claude-hooks-policy.md`

OpenCode hook integration does not support the same shell-hook execution model used by Claude. Under current policy, non-Claude hooks remain intentionally out of scope.

---

### I-002: Gemini capability drift vs expected baseline

**Type**: Defect  
**Discovered**: 2026-02-22  
**Status**: Reopened (2026-02-24)  
**Affects**: Gemini capability modeling, installer defaults, and conformance behavior  
**Task**: T-097

The issue was previously marked closed but has been reopened because behavior is still reported as broken.

Current action:
- Keep issue active until capability behavior is re-validated end-to-end.
- Keep linked backlog task in progress.
- Do not archive until objective validation confirms closure.

---

## Resolved Issues Archive

Resolved issues were moved to:
- [archive/issues-resolved-2026-02-24.md](archive/issues-resolved-2026-02-24.md)

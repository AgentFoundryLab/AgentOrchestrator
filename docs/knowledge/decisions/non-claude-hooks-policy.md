# Decision: Non-Claude Hooks Integration Out of Scope

**Date**: 2026-02-24  
**Status**: Accepted

## Context

Claude hooks are implemented as shell-script commands via `settings.json`.

Non-Claude runtimes expose different hook models:
- Codex: limited `notify` callback model
- Gemini: settings-level hooks model
- OpenCode: JS/TS plugin event hooks
- Qwen: no user-facing lifecycle hook schema documented

Attempting a unified installer-level hook integration across these runtimes adds high maintenance cost and introduces adapter-specific runtime risk (notably OpenCode plugin wrappers for Claude shell scripts).

## Decision

For v0.x installer scope, hooks integration is supported only for Claude targets.

- Non-Claude runtimes (`codex`, `gemini`, `opencode`, `qwen`) do not install hook artifacts.
- Any explicit non-Claude hooks request is treated as unsupported by policy and must be surfaced clearly.
- `G-001` remains open as a known compatibility gap for visibility, but no implementation task is scheduled.

## Consequences

- Backlog item `T-093` is removed from active scope.
- Installer docs and roadmap/backlog language must not imply planned non-Claude hook adapter implementation.
- Runtime capability research may still document native runtime hook support; installer policy can intentionally choose not to implement it.

## Revisit Criteria

Re-open this decision only if all are true:
1. A single adapter approach has low operational risk and testability across supported non-Claude runtimes.
2. Policy/architecture owners approve expanded installer scope.
3. A new ADR or superseding decision record explicitly changes this policy.

## Related

- `docs/development/ISSUES.md` (`G-001`)
- `docs/architecture/adr/014-multi-agent-installer.md` — D-1A capability table documents native hook support per runtime; this policy intentionally does not implement it for non-Claude targets in v0.x
- `reports/research/2026-02-22-agent-capability-report.md`

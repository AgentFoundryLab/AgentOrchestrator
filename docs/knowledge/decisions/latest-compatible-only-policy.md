# Decision: Latest-Compatible-Only Runtime Policy

**Date**: 2026-02-24  
**Status**: Accepted

## Context

Installer/runtime docs have repeatedly drifted because deprecated compatibility paths were kept alongside current runtime-native behavior.

This creates recurring issues:
- Conflicting invocation guidance (native flow vs deprecated aliases)
- Expanded maintenance/test matrix without product value
- Slower convergence to current official runtime contracts

## Decision

Use latest compatible runtime behavior as baseline. Deprecated compatibility paths are out of scope, with one explicit transient compatibility exception.

- Installer MUST target current runtime-native artifact paths and invocation models from official docs.
- Deprecated runtime features/paths MUST NOT be installed by default or via compatibility dual-write behavior, except the transient command-mode compatibility exception below.
- Documentation MUST prioritize latest runtime-native usage and MUST NOT present deprecated flows as supported defaults.
- Exception (transient compatibility): `--profile commands` compatibility mode remains supported for now.
- If migration is required, prefer explicit migration guidance/scripts over persistent compatibility behavior.

## Consequences

- Existing deprecated compatibility behavior outside command-mode exception scope is technical debt and should be removed.
- Command-mode compatibility may remain as a transitional path while migration completes.
- Roadmap/backlog/docs should be aligned to latest-native behavior, with command-mode compatibility clearly marked as transitional.
- Current known non-compliance: Codex default flow still dual-writes `/prompts:*` artifacts; tracked as `I-004` for cleanup under `T-098`.

## Revisit Criteria

Re-open only if all are true:
1. Upstream runtime docs formally restore/endorse the older interface.
2. Product owners approve re-introducing compatibility scope.
3. A superseding decision record explicitly replaces this policy.

## Sunset Condition for Exception

The `--profile commands` exception should be removed once supported runtimes provide stable, production-ready native skill/agent parity and migration tooling is available for existing command-mode users.

## Related

- `docs/architecture/adr/014-multi-agent-installer.md`
- `docs/development/ISSUES.md` (`I-004`)

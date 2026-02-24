# TDR: Installer Modularity Principles

## Status

Accepted (stub — T-118 to add implementation evidence)

## Date

2026-02-24

## Context

`install.sh` grew to 2300+ lines across the v0.2.x series as each new runtime, capability profile, and transform pipeline was added inline. A single-file monolith creates three failure modes:

1. **Merge conflicts**: parallel work on different runtimes collides in one file.
2. **Cognitive overload**: navigating 2000+ lines to find a Gemini-specific function is impractical.
3. **Unconstrained growth**: no structural boundary stops a new feature from appending to an already-oversized file.

## Decision

Decompose `install.sh` into a modular tree. The following principles are binding for all future installer work:

### Principle 1: Single-responsibility per runtime module

Each runtime (`claude`, `codex`, `gemini`, `opencode`, `qwen`) gets its own module file under `install/runtimes/`. A runtime module owns:
- its canonical install paths
- its capability profile (commands/skills/hooks/scripts/subagents)
- its frontmatter/schema transforms

No runtime module may call functions defined in a sibling runtime module.

### Principle 2: Shared logic lives in `install/lib/` only

Functions used by more than one runtime are extracted into:
- `install/lib/transforms.sh` — frontmatter/schema transforms
- `install/lib/validation.sh` — path, schema, and flag validation
- `install/lib/utils.sh` — file I/O, logging, idempotency helpers

Runtime modules source only `install/lib/` entries, not each other.

### Principle 3: Main dispatcher is a thin orchestrator

`install/main.sh` (called by the top-level `install.sh` shim) is responsible only for:
- parsing global flags
- selecting runtimes to install
- delegating to runtime modules in sequence

No install logic lives in `main.sh`. It must remain under 150 lines.

### Principle 5: No silent cross-runtime side effects

A runtime module must not write to another runtime's config or path space. Any cross-runtime concern (e.g., shared root docs) must be handled explicitly in `main.sh` with a documented rationale.

## Consequences

- Onboarding new runtimes is bounded: add one file under `install/runtimes/`, source shared libs, done.
- CI enforces the LOC constraint; reviewer feedback is reinforced by tooling.
- The monolith cannot regrow — any attempt to add logic to `main.sh` or cross-source runtime modules fails CI.

## References

- T-115: Split install.sh into runtime-scoped modules
- T-116: Extract shared installer library
- T-117: This TDR
- `package/policy/PRINCIPLES.md` — Modular Composition principle
- `docs/architecture/DESIGN-PRINCIPLES.md`

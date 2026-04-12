# Decision: Flat Skill/Agent Install Paths

**Date**: 2026-02-19
**Status**: Accepted

## Context

Skills and agents can install into Claude Code at flat or dot-prefixed paths:

- Flat: `~/.claude/skills/spec/SKILL.md` + `name: spec` → invoked as `/spec`
- Dot-prefix: `~/.claude/skills/jarvis.spec/SKILL.md` + `name: jarvis.spec` → invoked as `/jarvis.spec`

Subdirectory namespacing (`~/.claude/skills/jarvis/spec/`) as used by commands is NOT supported for skills — that requires plugin packaging (`/plugin:skill`).

## Decision

Default to flat paths. The `--namespace <name>` flag installs using dot-prefix convention: skill directories become `<name>.<skill>/` and frontmatter `name:` is set to `<name>.<skill>`, invoked as `/<name>.<skill>`. A fully isolated distribution can be packaged as a plugin later.

## Rationale

- Flat paths give the cleanest user-facing invocation (`/spec`, not `/jarvis.spec`)
- Dot-prefix is available for coexistence when needed — no plugin required
- Plugin packaging remains the path for true isolation (`/plugin:skill`)

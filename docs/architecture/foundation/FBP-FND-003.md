# Component Blueprint: Skill System

## Capability Summary

A skill is a versioned procedure the host runtime can dispatch by name. The skill file carries the instruction; its frontmatter carries the contract — who may invoke it, which tools it may use, whether it forks, and into which agent. `SKILL.md` files flowing through the installer's transform are the elements this capability moves.

## Core Components

```component
name: SkillDefinition
container: Installed Runtime Root
responsibilities:
	- Declaring `name`, `description`, and the invocation contract in frontmatter
	- Carrying the procedure body the runtime loads on dispatch
	- Bundling its own `scripts/` and `references/` where it needs them
	- Reading shared artifact templates from the runtime root's `templates/`
```

```component
name: FrontmatterTransform
container: Installed Runtime Root
responsibilities:
	- Stripping keys the target runtime does not understand using `SkillDefinition` frontmatter
	- Mapping tool names to the target runtime's vocabulary
	- Leaving the body verbatim so one authored procedure stays one procedure
```

`#SkillDefinition` is authored; `#FrontmatterTransform` rewrites it per target at install time and never at runtime. The transform is deliberately one-way and lossy — a runtime receives less than was authored, never something different. That asymmetry is what keeps five installations behaviorally equivalent instead of merely syntactically valid.

A skill that owns an artifact declares `agent:` and `context: fork`, so dispatch runs the owning role. A skill that must keep the caller's session — retrieval, audit, orchestration — declares neither, because forking would either lose the context it analyses or lose the ability to spawn.

## System Contracts

### Key Contracts

- A skill's `name` equals its directory name.
- A declared `agent:` resolves within the installed agent set.
- `allowed-tools` bounds the skill; a skill cannot exceed the tools its agent is granted.
- An inline skill retains the caller's session and may spawn; a forked skill does neither.

### Integration Contracts

- **Host runtime**: dispatches by `name`, loads the body, honours `allowed-tools`.
- **Template directory**: shared per-record-type templates read from the runtime root, not bundled per skill.

## Architecture Decision Records

- [ADR-FND-004](../ADR/ADR-FND-004.md) — Skill and agent invocation paths
- [ADR-FND-013](../ADR/ADR-FND-013.md) — Extended skills

# Foundation Blueprint: Package and Runtime Model

## Foundation Summary

AgentOrchestrator is a package of instruction surfaces — policy, agents, skills, templates, workflows, hooks — authored once in this repository and installed into runtime roots it does not own. Nothing here is a running service. The architectural problem is therefore not runtime behavior but *distribution fidelity*: how one authored surface reaches five runtimes with different frontmatter schemas, path conventions, and capability sets, without the operator hand-editing anything and without a runtime receiving a file it cannot parse.

This foundation governs every other blueprint. It fixes the source-of-truth direction (`package/` is authored, runtime roots are deployed), the capability-gap discipline (report, never emulate), and the two-tier policy load.

## Scope

- Governed: the `package/` source layout, the installer contract, per-runtime transforms, policy loading, and the source-versus-deployed boundary.
- Excluded: the behavior of any individual agent or skill once installed — see the component blueprints.
- Excluded: the delivery workflow those components compose — see `FBP-FEAT-001`.

## Standards and Decisions

**Source of truth is one-directional.** `package/**` is authored; every runtime root holds a deployed copy. A deployed copy is overwritten on the next install, so a fix applied there is silently lost. This is the single most violated boundary in the system, which is why `$meta-learn` carries an explicit carve-out for it.

**Capability gaps are reported, never emulated.** When a runtime cannot support a capability, the installer records a gap rather than writing an artifact that runtime will fail to load. `install.sh --check` surfaces those gaps as first-class rows.

**Two-tier policy.** Global policy (`PRINCIPLES.md`, `RULES.md`) installs to each runtime root's `policy/`; project policy (`STANDARDS.md`, `GUIDELINES.md`) stays in the consuming repository. Sub-agents receive both through injected references. Recorded in `ADR-FND-006` and `ADR-FND-012`.

**Install is reversible.** Every install writes a timestamped backup and supports restore. An interrupted install must never leave a partially-written instruction set as the only copy.

**No language runtime for core operation.** The installer is shell. A skill may bundle a script in another language, but the skill must degrade to its documented procedure when that runtime is absent.

## Shared Contracts

### Key Contracts

- `package/` is authored; runtime roots are generated. Never edit a deployed copy to fix a source defect.
- A skill's `name` equals its directory name. Invocation and location never diverge.
- An agent's declared skills and a skill's declared agent must both resolve within the installed set.
- Unsupported frontmatter keys are stripped at install, never passed through.
- Uninstalling one runtime leaves every other runtime untouched.
- The installer writes only inside the runtime roots and project directories it declares.

### Integration Boundaries

- **Host runtime** owns skill dispatch, sub-agent spawning, and hook execution. The package owns only the definitions those mechanisms load.
- **MCP servers** are optional capability providers. Core workflows degrade to documented fallbacks when absent — see `FBP-FND-008`.
- **Consuming repository** owns its own `AGENTS.md`, project policy, and artifact paths. The package never assumes them.

## Architecture Decision Records

- [ADR-FND-003](../ADR/ADR-FND-003.md) — Minimal MCP footprint
- [ADR-FND-004](../ADR/ADR-FND-004.md) — Skill and agent invocation paths
- [ADR-FND-006](../ADR/ADR-FND-006.md) — Policy modularization
- [ADR-FND-012](../ADR/ADR-FND-012.md) — Governance rationalization
- [ADR-FND-013](../ADR/ADR-FND-013.md) — Extended skills

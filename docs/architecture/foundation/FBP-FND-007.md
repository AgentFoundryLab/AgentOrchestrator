# Component Blueprint: Policy and Knowledge

## Capability Summary

Policy is what every agent must obey; knowledge is what the project has learned. Both load automatically, from different tiers, and neither may restate the other. This capability owns the two-tier load and the ownership rule that keeps a rules file from becoming a second copy of a contract it should only cite.

## Core Components

```component
name: GlobalPolicy
container: Installed Runtime Root
responsibilities:
	- Carrying `PRINCIPLES.md` design philosophy and `RULES.md` enforcement tiers
	- Owning what any agent can violate — honesty, traceability, safety, delegation
	- Naming owners rather than restating the facts those owners hold
```

```component
name: ProjectPolicy
container: Consuming Repository
responsibilities:
	- Carrying `STANDARDS.md` and `GUIDELINES.md` for repository-specific rules
	- Overriding nothing in `#GlobalPolicy`; narrowing only
```

```component
name: KnowledgeIndex
container: Consuming Repository
responsibilities:
	- Organizing domain, patterns, runbooks, and TDR decisions under `docs/knowledge/`
	- Holding operational choices below ADR scope as TDRs
```

`#GlobalPolicy` installs to each runtime root and is referenced into the runtime's context document; `#ProjectPolicy` is read from the repository. Sub-agents receive both through injected references, so a delegated agent inherits the same contract as its caller.

The ownership rule is the load-bearing part. A rules file names owners; it never restates a cardinality, vocabulary, or list its owner holds. A restated fact drifts on its own branch, and the rules file then contradicts the contract it exists to enforce — which is why the record schema lives in `RULES.md` as grammar and *tables of required fields*, while every per-stage detail stays in the owning skill.

## System Contracts

### Key Contracts

- Global policy is generic; repository-specific policy never enters it.
- Project policy narrows global policy and never contradicts it.
- Skills and agent profiles are procedural checklists and may not redefine either tier.
- An instruction surface never encodes a workaround for a tooling defect.
- A TDR records an operational choice with local blast radius; an ADR changes structure or a durable contract.

### Integration Contracts

- **Runtime context document**: receives injected `@policy` references; injection is idempotent.
- **Delegated agents**: receive both tiers by reference in their brief, never pasted.

## Architecture Decision Records

- [ADR-FND-006](../ADR/ADR-FND-006.md) — Policy modularization
- [ADR-FND-012](../ADR/ADR-FND-012.md) — Governance rationalization

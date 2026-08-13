# Component Blueprint: Agent System

## Capability Summary

An agent is a role with a boundary. It carries a description that triggers delegation, a tool allowance that makes its boundary enforceable, and a skill list preloaded into its context. The capability's value is the enforcement: a role that cannot edit cannot redesign, and a role that cannot set status cannot declare itself validated.

## Core Components

```component
name: AgentProfile
container: Installed Runtime Root
responsibilities:
	- Declaring `name`, `description`, `tools`, and optional `disallowedTools`
	- Declaring the `skills` preloaded when the agent is spawned
	- Stating explicit will/won't boundaries the tool allowance backs
	- Declaring `hooks` for lifecycle reminders where the runtime supports them
```

```component
name: RoleBoundary
container: Installed Runtime Root
responsibilities:
	- Constraining what an `AgentProfile` may produce and must refuse
	- Reserving status mutation to the status role alone
	- Reserving product-code edits to the delivery role alone
```

`#RoleBoundary` is not a separate file — it is the invariant `#AgentProfile` encodes and the tool allowance enforces. A boundary stated in prose but contradicted by the allowance is decorative, which is why the two are reviewed together rather than separately.

Nine roles: Business Analyst, Architect, Planner, Developer, Validator, Security, Scout, Deployer, Tech Writer. Only Developer edits product code. Only Validator, running `$status-update`, sets status.

## System Contracts

### Key Contracts

- Every declared skill resolves within the installed skill set.
- An agent forbidden from editing is granted no edit tool.
- Only the status role sets a record's status; every other profile forbids it.
- A delegated agent executes its assigned slice only and returns changed artifacts, blockers, skipped scope, and residual risk.

### Integration Contracts

- **Host runtime**: spawns by `name` through its own sub-agent primitive; `description` drives auto-delegation.
- **Orchestration**: receives the model tier and the ids it may use in its brief; never allocates an id itself.

## Architecture Decision Records

- [ADR-FND-004](../ADR/ADR-FND-004.md) — Skill and agent invocation paths
- [ADR-FND-005](../ADR/ADR-FND-005.md) — Task decomposition hierarchy

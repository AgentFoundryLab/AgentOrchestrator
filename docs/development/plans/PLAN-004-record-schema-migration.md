# PLAN-004: Record Schema Migration

Kind: Development · Status: Active

The delivery Phase that replaced this repository's ad-hoc identifier conventions with the typed record
schema — `REQ`/`AC`, `TR`/`TRC`, `FBP`, `ADR`, `PLAN`, `WO`, `ISS`/`REG`/`TD`/`FB` — across both the
distributed package and this repository's own artifacts.

It runs as its own Phase rather than inside `PLAN-002` because it changes the artifact model every other
Phase's records are expressed in. Folding it into a delivery Phase would mean migrating the schema while
that Phase's Work Orders were being authored against it.

## Milestones

| Milestone | Gate | Passes when |
| --- | --- | --- |
| M1 | Package speaks the record schema | Policy, every agent profile, and every skill reference the record grammars; `install.sh --check` and the smoke suite pass |
| M2 | Repository artifacts migrated | Requirements, architecture, plan, and feedback layers are migrated in dependency order with no dangling id, and the id map is committed |

## Dependencies

None. This Phase is deliberately independent — it must be able to land regardless of what any delivery
Phase is mid-flight on.

## Membership

`Phase` and `Milestone` are authored on each Work Order's own record. Filter the Work Order index by
`Phase: PLAN-004`.

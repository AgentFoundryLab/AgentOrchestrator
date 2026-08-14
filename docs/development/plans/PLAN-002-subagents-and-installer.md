# PLAN-002: Subagents Extension and Installer Redesign

Kind: Development · Status: Active

The delivery Phase that extends delegation to every supported runtime's native sub-agent primitive and
rebuilds the installer to carry it. Two concerns travel together because the installer is what makes a
sub-agent definition reach a runtime at all — shipping the definitions without the install path would
deliver nothing usable.

## Milestones

| Milestone | Gate | Passes when |
| --- | --- | --- |
| M1 | Sub-agent artifacts install correctly per runtime | Conformance tests assert the expected path and frontmatter schema for every runtime, and the capability baseline includes the subagents dimension |
| M2 | Installer redesign lands without regression | The full smoke suite passes on the redesigned installer, and namespaced install/restore/cleanup remain reversible |

## Dependencies

- `PLAN-001` completion → this Phase's `M1` — the agent and skill systems must exist before their
  multi-runtime install path can be extended.

## Membership

`Phase` and `Milestone` are authored on each Work Order's own record. Filter the Work Order index by
`Phase: PLAN-002`.

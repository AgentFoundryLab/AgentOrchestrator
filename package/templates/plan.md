# PLAN-{{NNN}}: {{PHASE_NAME}}

Kind: {{Development | Coordination}} · Status: {{Draft | Active | Complete | Superseded}}

{{One or two paragraphs: what this delivery Phase establishes and why it exists as its own Phase.}}

## Milestones

A Milestone is a **coordination gate** — an integration validation, a merge, or a promotion. It is
not a work container and holds no scope of its own. A Milestone cannot pass until every configured
gate has recorded evidence; a failed Milestone creates remediation Work Orders.

| Milestone | Gate | Passes when |
| --- | --- | --- |
| M1 | {{what is being coordinated}} | {{the evidence that closes it}} |
| M2 | {{what is being coordinated}} | {{the evidence that closes it}} |

Declare no Milestones when the Phase is sequenced by Work Order `dependsOn` alone. Say so explicitly
rather than leaving the section empty.

## Dependencies

Cross-plan edges only — which Milestone in another Plan must pass before one here can.

- `PLAN-{{NNN}}` `M{{n}}` → this Plan's `M{{n}}` — {{why}}

## Membership

`Phase` and `Milestone` are authored on each Work Order's own record. **This document never lists its
Work Orders** — a second listing drifts the moment either side changes.

To ask what this Phase or a Milestone contains, filter the Work Order index by `Phase` / `Milestone`.

<!--
One Plan is one delivery Phase. A Plan holds Milestones and cross-plan edges, and nothing else:
no stages, no lanes, no WO listing.

Plan structure is revisable, unlike record ids -- a Milestone is a coordination gate, not a durable
artifact reference, so a wrong initial shape is meant to be fixed rather than worked around. Renaming
or removing a Milestone must carry its cross-plan edges with it. Record ids are never revisable.

PLAN ids are immutable and never recycled. Under $orchestrate they come from the brief.
-->

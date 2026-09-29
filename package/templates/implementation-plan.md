# Implementation Plan Template

Use this template for the optional implementation plan attached to a work order.
The owning Work Order must reference this file explicitly in its `Summary` section.

## Objective

State the delivery outcome this plan is meant to achieve.

## Assumptions and Dependencies

- Required upstream requirements or blueprints
- Required services, flags, migrations, or environment dependencies

## Target Files and Surfaces

- `path/to/file` - expected change
- `path/to/another-file` - expected change

## Delegation Map

State only what departs from `$orchestrate`'s default slicing: a split into several developer lanes, the shared surface a lane owns as integration owner, or primary-only steps. Write `Default` when nothing departs.

## Execution Steps

1. <first concrete change, naming its file or surface>
2. <next change and the dependency that orders it>

List only steps specific to this Work Order. The delivery procedure lives in the skills, not in each plan.

## Verification

- Unit, integration, or e2e checks to run
- Manual scenario to exercise

## Risks

- Known edge cases, migration concerns, or rollout hazards

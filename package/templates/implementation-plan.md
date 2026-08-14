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

- Developer sub-agent slice: files/surfaces owned, dependencies, and expected output
- Validator sub-agent slice: acceptance criteria, commands, and evidence to verify independently
- Primary-only work: integration, credentials, branch/PR/status continuation, or non-delegable steps

## Execution Steps

1. Make the first change needed to establish the implementation path.
2. Validate that change before moving on.
3. Continue with the next isolated change.

## Verification

- Unit, integration, or e2e checks to run
- Manual scenario to exercise

## Risks

- Known edge cases, migration concerns, or rollout hazards

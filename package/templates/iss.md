# ISS-<NNN>: <generalized problem title>

> Root-cause work item, not a concrete report. Author only after triaging the existing index for a
> record that already owns this cause. Category/scope route the work; issueType classifies the
> failure class only — the cause narrative lives in `Diagnosis` below, never in a table cell.
> Linked REG documents preserve exact symptoms and reproduction evidence.
>
> File at `docs/development/issues/ISS-NNN.md`. Ids are immutable and never recycled; under
> `$orchestrate` they come from the brief. Never retype or delete a durable ISS id.

## Classification

- Category / scope / type: `<category>` / `<scope>` / `<issueType>`
- Severity: `<Critical | High | Medium | Low>`
- Root-cause state: `<Unknown | Suspected | Confirmed>`
- Root cause: <current concise hypothesis or confirmed cause>

## Status

<Open | Investigating | Fixing | Validating | Closed | Reclassified> — <current state>.

## Links

- Affected REQ/TR: `REQ-<NNN>`, `TR-<NNN>`
- Affected AC/TRC: `AC-<NNN>.<n>`, `TRC-<NNN>.<n>`
- Related WO / TD: `WO-<NNN>` / `TD-<NNN>`
- Linked reports: `REG-<NNN>`

## Diagnosis

<Common mechanism that explains the linked regressions. Distinguish observation,
hypothesis, and confirmed evidence.>

## Remediation

<Owner-level fix and validation boundary shared by the linked regressions.>

## Reclassification

<If reclassified: REG id, target ISS id, rationale. Otherwise: Not reclassified.>

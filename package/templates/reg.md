# REG-<NNN>: <exact symptom title>

> Immutable concrete report, always created under a current ISS parent — never standalone.
> Relinking changes that parent and appends to `Link history` below; it never moves or rewrites
> this document.
>
> File at `docs/development/issues/REG-NNN.md`. A REG carries no severity of its own — it inherits
> its issue's. The `Reported behavior` section is write-once: never edit or collapse it while
> fixing, because it is the acceptance evidence the fix is validated against.

## Current issue

- Issue: `ISS-<NNN>`
- Source issue, if reclassified/extracted: `ISS-<NNN>`
- Affected REQ/TR: `REQ-<NNN>`, `TR-<NNN>`
- Affected AC/TRC: `AC-<NNN>.<n>`, `TRC-<NNN>.<n>`
- Related WO: `WO-<NNN>`

## Reported behavior

<Copy the exact reported bullets/examples/reproduction. Never edit or collapse them while
fixing; append clarifications separately.>

## Reproduction and evidence

<Environment, preconditions, steps, observed result, and immutable evidence references.>

## Closure matrix

> Broken-behavior characterization is evidence only; it does not count as acceptance.

| Exact reported condition | Corrected AC/TRC | RED evidence | Focused post-fix pass | Full/preview gate | Status |
| --- | --- | --- | --- | --- | --- |
| <condition> | `AC/TRC-*` | <test + ref> | <command + result> | <gate + result> | <Open/Closed> |

## Link history

| From ISS | To ISS | Rationale | Timestamp |
| --- | --- | --- | --- |
| — | `ISS-<NNN>` | Initial triage | <timestamp> |

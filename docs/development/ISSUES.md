# Issue Index

Active issues and their concrete regression reports. Closed records move to
[`../archive/development/ISSUES.md`](../archive/development/ISSUES.md).

`ISS` is the generalized root-cause work item; `REG` is one concrete symptom with its own write-once
report, always under exactly one current `ISS` parent. Record prose lives in `issues/`; this index is
the lookup surface. Status is owned by `$status-update`.

Ids are immutable — [`ID-MAP.md`](ID-MAP.md) resolves the pre-migration `I-`/`G-` forms.

## Issues

| ISS | Category | Scope | Type | Severity | Root Cause | Title | Related WO | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [ISS-002](issues/ISS-002.md) | bugfix | installer | config | High | Suspected | Gemini capability drift vs the validated baseline | `WO-097` | Open |
| [ISS-006](issues/ISS-006.md) | bugfix | installer | config | High | Confirmed | Runtime target isolation across global installs | `WO-097` | Closed |

## Regressions

| REG | Current Issue | Scope | Title | Related WO | Status |
| --- | --- | --- | --- | --- | --- |
| [REG-002](issues/REG-002.md) | `ISS-002` | installer | Gemini CLI rejects emitted command files | `WO-097` | Open |

---

`ISS-006` is closed but retained in the active index until its successor `ISS-002` closes, so the
reclassification stays visible. `REG-002` was extracted from `ISS-006` and relinked to `ISS-002` —
its report document was never rewritten.

`ISS-001`, `ISS-003`–`ISS-005` are permanently unissued: preserved numbering from the `I-`/`G-` forms
leaves those gaps. A skipped number is harmless; a recycled one is not.

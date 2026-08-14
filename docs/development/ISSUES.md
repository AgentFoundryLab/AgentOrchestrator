# Issue Index

Active issues and their concrete regression reports. Closed records live in
[`archive/issues-resolved-2026-02-24.md`](archive/issues-resolved-2026-02-24.md) and
[`archive/issues-resolved-2026-02-25.md`](archive/issues-resolved-2026-02-25.md).

The link this line used to carry — `../archive/development/ISSUES.md` — pointed at a file that was
never created. `docs/INDEX.md` declares `docs/archive/development/` as the archive root and
`WORKORDERS.md` moved there, but these issue archives did not; the move is half-finished.

`ISS` is the generalized root-cause work item; `REG` is one concrete symptom with its own write-once
report, always under exactly one current `ISS` parent. Record prose lives in `issues/`; this index is
the lookup surface. Status is owned by `$status-update`.

Ids are immutable — [`ID-MAP.md`](ID-MAP.md) resolves the pre-migration `I-`/`G-` forms.

## Issues

| ISS | Category | Scope | Type | Severity | Root Cause | Title | Related WO | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [ISS-002](issues/ISS-002.md) | bugfix | installer | config | High | Suspected | Gemini capability drift vs the validated baseline | `WO-097` | Open |
| [ISS-006](issues/ISS-006.md) | bugfix | installer | config | High | Confirmed | Runtime target isolation across global installs | `WO-097` | Closed |
| [ISS-007](issues/ISS-007.md) | bugfix | hooks | logic | Medium | Confirmed | SessionStart derives project context but never injects it | — | Open |
| [ISS-008](issues/ISS-008.md) | bugfix | installer | portability | High | Confirmed | Installer relies on GNU-only sed and awk syntax | — | Closed |

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

`ISS-008` is closed but retained in the active index for one cycle so the `portability` issueType
extension stays visible — it is the first record to use a value other than `config` or `logic`.

`ISS-009` is the next free id.

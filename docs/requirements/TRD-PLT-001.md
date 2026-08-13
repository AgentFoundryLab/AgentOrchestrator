# Technical Requirements: Platform and Distribution Constraints

## Overview

AgentOrchestrator installs instruction surfaces into runtimes it does not own, on machines it cannot inspect. Every constraint here exists to keep that install predictable: no hidden toolchain, no service dependency, no surprise footprint, and no divergence from the host runtime's own conventions.

These are the commitments that make the package safe to install and safe to remove.

## Scope

- In scope: the installer, the shipped package surface, and the runtime integration contract.
- Out of scope: the behavior of any individual agent or skill once installed — that belongs to the feature requirements.

## Constraints

### TR-001: No language runtime dependency for core operation

**Intent:** The package is instruction surfaces plus shell. Requiring a language toolchain to install instructions would make the package fail on hosts that only need the instructions.

**Requirements:**

- **TRC-001.1:** The installer and the shipped core shall operate with shell and standard POSIX utilities alone; no Python or Node runtime shall be required for install, verification, or uninstall.
- **TRC-001.2:** A skill that bundles a script in another language shall degrade to its documented procedure when that runtime is absent, rather than failing the skill.

### TR-002: Minimal MCP footprint

**Intent:** Every required MCP server is a dependency the operator must provision and trust. The baseline stays minimal so the package is usable before any of them exist.

**Requirements:**

- **TRC-002.1:** The system shall function with no MCP server configured, with retrieval and memory features degrading to documented fallbacks.
- **TRC-002.2:** Every MCP dependency shall be classified required, recommended, or optional, and no recommended or optional server shall be a precondition for a core workflow.

### TR-003: Install completes in seconds

**Intent:** An install that takes minutes gets interrupted, leaving a half-written instruction set.

**Requirements:**

- **TRC-003.1:** A single-runtime global install shall complete in under 30 seconds on a warm filesystem.
- **TRC-003.2:** The installer shall back up what it replaces and support restoring that backup, so an interrupted install is recoverable.

### TR-004: Host runtime compatibility

**Intent:** The package augments a stock runtime. A package that only works after the operator patches their runtime is not portable.

**Requirements:**

- **TRC-004.1:** The system shall work with a stock installation of each supported runtime, requiring no runtime source modification.
- **TRC-004.2:** Installed artifacts shall conform to each runtime's own frontmatter and path conventions, with unsupported keys stripped rather than passed through.
- **TRC-004.3:** A capability a runtime does not support shall be reported as an explicit gap, never emulated by writing an artifact that runtime cannot parse.

### TR-005: Self-contained operation

**Intent:** No external service should be able to break an install or observe its contents.

**Requirements:**

- **TRC-005.1:** Core operation shall require no network service beyond the host runtime's own model provider.
- **TRC-005.2:** The installer shall make no outbound network call.

### TR-006: Bounded and inspectable footprint

**Intent:** An operator must be able to see exactly what was added and remove all of it.

**Requirements:**

- **TRC-006.1:** Every installed path shall be enumerable before install and removable by the uninstall path.
- **TRC-006.2:** Uninstalling one runtime shall leave every other runtime's artifacts untouched.
- **TRC-006.3:** The installer shall write no file outside the runtime roots and project directories it declares.

## Standards and References

- Each supported runtime's own agent, skill, and settings documentation is authoritative for its conventions.
- `ADR-FND-003` records the minimal-MCP-footprint decision; `ADR-FND-014` records the multi-runtime installer design.

## Verification

- `bash install.sh --check` verifies package layout and registry declarations.
- `bash tests/install/smoke.sh` verifies post-install conformance per runtime, including capability presence and absence, namespacing, uninstall isolation, and idempotency.
- `TRC-003.1` is verified by timing a clean global install; `TRC-005.2` by observing that the installer performs no network call.

# Software Engineering Principles

**Core Directive**: Evidence > assumptions | Code > documentation | Efficiency > verbosity

## Philosophy
- **Task-First Approach**: Understand → Plan → Execute → Validate
- **Evidence-Based Reasoning**: All claims verifiable through testing, metrics, or documentation
- **Parallel Thinking**: Maximize efficiency through intelligent batching and coordination
- **Context Awareness**: Maintain project understanding across sessions and operations

## Engineering Mindset

### SOLID
- **Single Responsibility**: Each component has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Derived classes substitutable for base classes
- **Interface Segregation**: Don't depend on unused interfaces
- **Dependency Inversion**: Depend on abstractions, not concretions

### Core Patterns
- **DRY**: Abstract common functionality, eliminate duplication
- **KISS**: Prefer simplicity over complexity in design decisions
- **YAGNI**: Implement current requirements only, avoid speculation

### Structural Design
- **Modular Composition**: Build from small, single-responsibility units. Each module owns one concern; shared logic lives in explicit libraries, never duplicated across siblings. A module that is hard to name has more than one responsibility.
- **High Cohesion / Low Coupling**: Keep related behaviour together; minimize dependencies between modules.

### First-Principles, Cleanup-First Design
- **Derive, don't inherit**: Build the smallest design required by current requirements, invariants, constraints, and source of truth. Legacy is evidence, not authority.
- **Model the domain before code**: concepts, ownership, lifecycle, invariants, interfaces.
- **Dependencies point to domain owners**: modules have one concern; interfaces stay small; policy stays separate from mechanisms.
- **Best part is no part**: delete, merge, move, or consolidate before legacy reuse or adding files, helpers, wrappers, flags, mappings, fixtures, schemas, or parallel flows.
- **Reuse legacy only when** necessary, canonical, and simpler than removal. No fallback or compatibility overlay without an explicit requirement.
- **A good abstraction shrinks the system**: fewer branches, parameters, duplicated facts, and caller obligations. Remove indirection that only moves complexity.
- **Maintainability over local readability**: one owner and a centralized invariant beat repeated obvious code; keep boundaries and names legible.
- **Fix behavior at the source of truth**: no duplicate normalization, query, rendering, validation, deduplication, fallback, or caller patches.
- **Add code only when** it clarifies a boundary or removes more complexity than it adds; remove superseded paths in the same change unless required coexistence has a removal trigger.
- **When ownership or boundaries are unclear**, stop for Architect review; extend canonical tests and fixtures instead of cloning them.
- **Treat complicated design as a symptom** to investigate, not a fact to accommodate.

### Systems Thinking
- **Ripple Effects**: Consider architecture-wide impact of decisions
- **Long-term Perspective**: Evaluate immediate vs. future trade-offs
- **Risk Calibration**: Balance acceptable risks with delivery constraints

## Decision Framework

### Data-Driven Choices
- **Measure First**: Base optimization on measurements, not assumptions
- **Hypothesis Testing**: Formulate and test systematically
- **Source Validation**: Verify information credibility
- **Bias Recognition**: Account for cognitive biases

### Trade-off Analysis
- **Temporal Impact**: Immediate vs. long-term consequences
- **Reversibility**: Classify as reversible, costly, or irreversible
- **Option Preservation**: Maintain future flexibility under uncertainty

### Risk Management
- **Proactive Identification**: Anticipate issues before manifestation
- **Impact Assessment**: Evaluate probability and severity
- **Mitigation Planning**: Develop risk reduction strategies

## Quality Philosophy

### Quality Quadrants
- **Functional**: Correctness, reliability, feature completeness
- **Structural**: Code organization, maintainability, technical debt
- **Performance**: Speed, scalability, resource efficiency
- **Security**: Vulnerability management, access control, data protection

### Quality Standards
- **Automated Enforcement**: Use tooling for consistent quality
- **Preventive Measures**: Catch issues early when cheaper to fix
- **Human-Centered Design**: Prioritize user welfare and autonomy

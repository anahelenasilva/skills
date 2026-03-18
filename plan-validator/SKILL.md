---
name: plan-validator
description: Validates refactoring plans and architectural changes for security vulnerabilities, circular dependencies, architectural fit, scalability, and long-term maintainability. Use when validating refactoring proposals, module restructuring, architecture changes, or when the user asks to validate or review a technical plan.
---

# Plan Validator

Validates technical refactoring plans and architectural changes against critical quality dimensions.

## Core Validation Dimensions

When validating a plan, systematically analyze:

### 1. Security Vulnerabilities

- Authentication/authorization impact
- Data exposure risks (sensitive data, credentials)
- New attack surface areas
- Injection vulnerabilities (SQL, XSS, etc.)
- Dependency security issues

### 2. Circular Dependencies

- Map current vs. proposed dependency graph
- Identify circular imports/references
- Check for hidden transitive dependencies
- Verify dependency injection patterns
- Assess coupling levels (tight vs. loose)

### 3. Architectural Fit

- Alignment with project architecture patterns
- Layer separation integrity (domain/application/infrastructure)
- Consistency with existing abstractions
- Adherence to SOLID principles
- Impact on bounded contexts (DDD)

### 4. Scalability

- Performance implications
- Database query efficiency
- Caching strategy impact
- Horizontal/vertical scaling considerations
- Resource consumption changes

### 5. Long-term Maintainability

- Code complexity (cyclomatic, cognitive)
- Test coverage impact
- Documentation requirements
- Onboarding difficulty for new developers
- Technical debt creation or reduction
- Breaking changes and migration effort

## Validation Process

Follow this workflow:

1. **Understand the plan**: Read the proposed changes thoroughly
2. **Map dependencies**: Create before/after dependency diagrams
3. **Apply each dimension**: Systematically check all 5 dimensions
4. **Identify risks**: List potential issues by severity
5. **Generate recommendations**: Provide actionable mitigation steps

## Output Format

Structure your validation report as:

```
# Plan Validation Report

## Executive Summary
[2-3 sentences: overall assessment, primary concerns, recommendation to proceed/revise/reject]

## Critical Issues 🔴
[Issues that MUST be addressed before proceeding]
- Issue description with specific examples
- Why it's critical
- Suggested fix

## Warnings 🟡
[Concerns that should be considered and mitigated]
- Concern description
- Potential impact
- Mitigation strategy

## Positive Aspects 🟢
[Improvements and benefits of the plan]
- Benefit description
- Impact on codebase quality

## Detailed Analysis

### Security Assessment
[Findings with specifics]

### Dependency Analysis
[Current vs. proposed dependency graph, circular deps]

### Architectural Alignment
[How it fits/conflicts with current architecture]

### Scalability Impact
[Performance and scaling considerations]

### Maintainability Evaluation
[Long-term health implications]

## Recommendations
1. [Specific, actionable recommendation with rationale]
2. [Specific, actionable recommendation with rationale]
3. [Specific, actionable recommendation with rationale]

## Migration Risks
[Potential issues during implementation]
- Risk with likelihood (High/Medium/Low)
- Mitigation approach
```

## Validation Checklist

Copy this checklist when validating:

```
Plan Validation Progress:
- [ ] Plan understood and scope identified
- [ ] Current architecture documented
- [ ] Dependency graph mapped (before/after)
- [ ] Security vulnerabilities assessed
- [ ] Circular dependencies checked
- [ ] Architectural fit evaluated
- [ ] Scalability impact analyzed
- [ ] Maintainability factors reviewed
- [ ] Migration risks identified
- [ ] Recommendations documented
- [ ] Final recommendation provided
```

## Example Validation

**User request:** "Validate this plan to refactor usecases module to domain"

**Your process:**

1. **Map the change:**
   - Current: `usecases/` contains business logic
   - Proposed: Move to `domain/` layer

2. **Dependency analysis:**
   - Check what imports from `usecases/`
   - Verify `domain/` won't introduce circular deps with infrastructure
   - Ensure domain remains dependency-free (Clean Architecture)

3. **Security check:**
   - Verify no business rules expose sensitive data
   - Check if domain entities properly validate input

4. **Architecture evaluation:**
   - Confirm alignment with Clean Architecture/Hexagonal/DDD
   - Verify domain layer has no external dependencies
   - Check if use cases should stay in application layer instead

5. **Scalability/Maintainability:**
   - Assess if domain logic is properly encapsulated
   - Verify testability improvements
   - Check migration impact on existing tests

6. **Generate structured report** with findings

## Key Principles

- **Be specific**: Cite code locations, modules, or files when identifying issues
- **Explain impact**: Don't just list problems—explain consequences
- **Provide alternatives**: Suggest concrete fixes, not just "reconsider this"
- **Prioritize ruthlessly**: Distinguish critical blockers from nice-to-haves
- **Consider context**: Some "violations" may be acceptable trade-offs

## Common Refactoring Patterns to Validate

### Moving modules between layers
- Verify dependency direction (domain should not depend on infrastructure)
- Check for leaked abstractions

### Renaming/restructuring
- Assess breaking change impact
- Verify import path updates across codebase

### Splitting large modules
- Identify potential circular dependencies early
- Ensure cohesive module boundaries

### Introducing new abstractions
- Verify they don't increase unnecessary complexity
- Check if they align with existing patterns

---
name: fix-issues-critically
description: Fix known code issues (bugs, lint errors, test failures, bad patterns) by critically evaluating multiple approaches before applying the best solution. Use after a code review, test run, or lint check has identified issues. Triggers on: "fix the issues", "resolve these findings", "fix the failures", "fix what was found", "fix these problems". Do NOT use for code review itself — use only when issues are already identified.
license: CC-BY-4.0
metadata:
  author: Ana Helena
  version: 1.0.0
---

# Fix Issues Critically

Autonomously fix known code issues by analyzing root causes, evaluating multiple approaches, and applying the best solution with documented rationale.

## Instructions

### Step 1: Gather Issues

Extract all issues from the current context. Sources include:
- Code review output
- Test failure messages
- Linting/type-check errors
- Bad patterns flagged during analysis

List each issue with its location (file:line) and description.

### Step 2: Prioritize

Order issues by:
1. **Dependency order** — fix root causes before symptoms. If issue A causes issue B, fix A first.
2. **Severity** — security issues > bugs > test failures > lint errors > style issues
3. **Blast radius** — fix localized issues before ones spanning multiple files

### Step 3: Fix Each Issue

For each issue in priority order:

#### 3a. Read the relevant code

Read enough surrounding code to understand the full context. Never fix based on just the error line — understand the function, its callers, and its dependencies.

#### 3b. Diagnose root cause

Distinguish symptom from cause. A test failure is a symptom; the bug that causes the wrong behavior is the cause. Fix the cause.

#### 3c. Identify approaches

Generate at least 2 possible fixes. For non-trivial issues, aim for 3. Consider:
- Direct fix (smallest change)
- Refactoring fix (cleaner but larger change)
- Alternative approach (different strategy entirely)

#### 3d. Evaluate approaches

Rate each approach against these criteria:

| Criterion | Question |
|-----------|----------|
| Correctness | Does this fully fix the root cause, or just the symptom? |
| Security | Does this introduce any vulnerability? |
| Performance | Does this degrade performance in any scenario? |
| Maintainability | Is this easy to understand and maintain? |
| Blast radius | What else could break from this change? |

Select the approach that scores best across all criteria. The "simplest fix" is not always the right choice if it leaves the root cause partially addressed.

#### 3e. Apply the fix

- Make the minimal change needed for the chosen approach
- Do not add unrelated improvements, refactoring, or cleanup
- Do not add comments unless the fix is non-obvious

#### 3f. Verify the fix

- Run relevant tests. If no tests cover this area, manually trace the logic to confirm correctness.
- Check for regressions in related code.
- If the fix breaks something, evaluate whether to adjust the fix or flag the tradeoff.

### Step 4: Report

After all fixes are applied, provide a concise report. For each fix:

```
#### [Issue description]

**Root cause:** [what was actually wrong]

**Approach chosen:** [description of the fix]

**Why:** [why this approach was selected over alternatives]

**Alternatives rejected:**
- [Alternative 1]: [reason for rejection]
- [Alternative 2]: [reason for rejection]

**Verified:** [how verification was done]
```

## Examples

### Example 1: Post-review fixes

User says: "fix the issues from the review"
Context: Code review found 3 issues — a potential null pointer, an unhandled promise rejection, and a missing edge case in validation.

Actions:
1. Gather all 3 issues from review output
2. Prioritize: null pointer first (could be root cause for others), then promise rejection, then edge case
3. For each: read code → diagnose root cause → identify 2-3 approaches → evaluate → fix → verify
4. Report with rationale for each fix

Result: All 3 issues fixed, report explains why each approach was chosen

### Example 2: Test failures

User says: "fix the failing tests"
Context: `pnpm test` shows 2 test failures.

Actions:
1. Extract failure messages and locations from test output
2. Read the failing test code and the code it tests
3. Determine if tests are wrong or code is wrong — fix the right thing
4. Apply fixes, run tests to verify
5. Report

Result: Tests pass, report clarifies whether tests or code were fixed and why

### Example 3: Lint errors

User says: "resolve these lint errors"
Context: ESLint reports 5 errors across 3 files.

Actions:
1. Extract all lint errors
2. Group by file for efficiency
3. For each: understand the rule violation, identify approaches (suppress vs fix vs refactor)
4. Prefer fixing over suppressing unless the rule is genuinely misapplied
5. Apply fixes, run linter to verify
6. Report

Result: Lint clean, report notes any intentional suppressions with justification

## Troubleshooting

### Cannot determine root cause

The symptom is visible but the cause is unclear:
- Read more surrounding code and trace data flow
- Check git history for recent changes to this area
- If still unclear, apply the most targeted fix possible and note in the report that root cause analysis was inconclusive

### Fixes conflict with each other

Two issues require contradictory changes:
- Fix in dependency order — the earlier fix establishes the correct state
- If truly conflicting, pick the fix that addresses the more fundamental issue and note the tradeoff

### No clear "best" approach

Multiple approaches score similarly on evaluation:
- Prefer the approach with the smallest blast radius
- If tied, prefer the simpler change
- Document that approaches were nearly equivalent and explain the tiebreaker

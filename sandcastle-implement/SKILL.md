---
name: sandcastle-implement
description: Autonomously implements open GitHub issues labeled "Sandcastle" one at a time using the RALPH workflow (explore, plan, RGR test-first, verify, commit, close). Use when the user says "implement next Sandcastle issue", "process open issues", "run RALPH", or asks to work through the Sandcastle backlog. Assumes pnpm, gh CLI, and git are configured in the current repo.
---

# Sandcastle Implement (RALPH)

You are RALPH — an autonomous coding agent working through GitHub issues **one at a time**.

## Quick start

1. Run `./scripts/fetch-context.sh` to load open Sandcastle issues + recent RALPH commits.
2. Pick the highest-priority unblocked issue (see [Priority order](#priority-order)).
3. Follow the [Workflow](#workflow) end-to-end for that single issue.
4. Stop after one iteration. If nothing is actionable, output `<promise>COMPLETE</promise>`.

## Priority order

Work the highest-priority unblocked issue first:

1. **Bug fixes** — broken behaviour affecting users
2. **Tracer bullets** — thin end-to-end slices proving an approach
3. **Polish** — error messages, UX, docs
4. **Refactors** — internal cleanups, no user-visible change

Skip any issue blocked by another open issue.

## Workflow

For the chosen issue, complete every step in order:

- [ ] **Explore** — read the issue body + comments. Pull in parent PRD if referenced. Read relevant source files and tests **before** writing code.
- [ ] **Plan** — decide the smallest change that solves the issue. Note key decisions.
- [ ] **Execute (RGR)** — Red → Green → Repeat → Refactor:
  - Write a failing test first
  - Implement the minimum code to pass
  - Repeat for additional cases
  - Refactor with tests green
- [ ] **Verify & Commit** — run `./scripts/commit.sh "<message>"`. It auto-runs `verify.sh` (typecheck + tests) before committing and aborts on failure. See [Commit format](#commit-format).
- [ ] **Close** — run `./scripts/close-issue.sh <issue-number>`.


## Commit format

Single commit per iteration. Message MUST:

- Start with `RALPH:` prefix
- State the task completed and any PRD reference
- List key decisions made
- List files changed
- Note any blockers for the next iteration

Example:

```
RALPH: Fix null pointer in user resolver (PRD #42)

Decisions:
- Guard with optional chaining instead of throwing
- Added regression test in resolver.test.ts

Files:
- src/resolvers/user.ts
- src/resolvers/user.test.ts

Blockers: none
```

## Rules

- **One issue per iteration.** Never batch.
- **Never close** before committing and verifying tests pass.
- **No commented-out code or TODOs** in committed code.
- **If blocked** (missing context, unfixable test, external dep): leave a comment on the issue via `gh issue comment` and move on. Do **not** close it.

## Completion signal

When all actionable issues are done or every remaining one is blocked, output exactly:

```
<promise>COMPLETE</promise>
```

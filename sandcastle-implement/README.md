# sandcastle-implement

Autonomous RALPH workflow for implementing open GitHub issues labeled **Sandcastle**, one at a time, using a strict test-first (RGR) loop.

## What it does

Given a repo with open issues labeled `Sandcastle`, this skill:

1. **Fetches context** — lists open Sandcastle issues and recent RALPH commits.
2. **Picks one issue** — the highest-priority unblocked one (bugs → tracer bullets → polish → refactors).
3. **Implements it** — explore, plan, then Red → Green → Repeat → Refactor.
4. **Verifies & commits** — typecheck + tests must pass, commit message must start with `RALPH:`.
5. **Closes the issue** — with the standard `"Completed by Sandcastle"` comment.
6. **Stops** — one issue per iteration. Outputs `<promise>COMPLETE</promise>` when nothing is actionable.

## Requirements

The skill assumes the following are installed and configured in the target repo:

- [`pnpm`](https://pnpm.io/) — with `typecheck` and `test` scripts in `package.json`
- [`gh` CLI](https://cli.github.com/) — authenticated against the repo
- `git` — with commit author configured

## Installation

1. Drop the `sandcastle-implement/` folder into your skills directory.
2. Make the scripts executable:

   ```bash
   chmod +x sandcastle-implement/scripts/*.sh
   ```

3. That's it. Trigger it by asking your agent:
   - *"implement next Sandcastle issue"*
   - *"process open issues"*
   - *"run RALPH"*

## File overview

| File                       | Purpose                                                          |
| -------------------------- | ---------------------------------------------------------------- |
| `SKILL.md`                 | Core instructions the agent follows (priority, workflow, rules). |
| `scripts/fetch-context.sh` | Lists open Sandcastle issues + last 10 RALPH commits.            |
| `scripts/verify.sh`        | Runs `pnpm run typecheck` and `pnpm run test`.                   |
| `scripts/commit.sh`        | Auto-runs `verify.sh`, validates `RALPH:` prefix, then commits.  |
| `scripts/close-issue.sh`   | Closes the issue with `"Completed by Sandcastle"`.               |

## How it works (flow)

```
┌─────────────────────┐
│ fetch-context.sh    │  ← load issues + recent commits
└──────────┬──────────┘
           ▼
   Pick highest-priority
     unblocked issue
           ▼
   Explore → Plan → RGR
           ▼
┌─────────────────────┐
│ commit.sh "RALPH:…" │  ← runs verify.sh internally
└──────────┬──────────┘   (aborts if typecheck/tests fail)
           ▼
┌─────────────────────┐
│ close-issue.sh <ID> │
└──────────┬──────────┘
           ▼
  <promise>COMPLETE</promise>
  (when nothing left)
```

## Safety guarantees

- **No broken commits** — `commit.sh` refuses to commit unless `verify.sh` passes.
- **No malformed messages** — `commit.sh` enforces the `RALPH:` prefix.
- **No premature closes** — issues are closed only after a successful commit.
- **No batching** — one issue per iteration, always.

## When blocked

If an issue can't be completed (missing context, unfixable test, external dependency):

```bash
gh issue comment <ID> --body "Blocked: <reason>"
```

Then move on. **Do not close** blocked issues.

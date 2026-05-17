---
name: sandcastle-merge
description: Merges a specified branch into the current branch using pnpm-based verification (typecheck + tests), resolves conflicts, and optionally closes a GitHub issue via gh CLI. Use when the user mentions "Sandcastle", asks to merge a branch and close an issue, or references the Sandcastle merge protocol.
---

# Sandcastle Merge

## Quick start

**With explicit branch:**

```bash
bash scripts/merge.sh sandcastle/impl/2026-05-17T15-20-45
bash scripts/close-issue.sh 123   # skip if no issue
```

**With auto-detection** (picks most recent worktree):

```bash
bash scripts/merge.sh
bash scripts/close-issue.sh 123
```

Then output `<promise>COMPLETE</promise>` exactly.

## Locating the branch

The branch to merge lives in a worktree under **one of**:

- `.sandcastle/worktrees/`
- `.claude/worktrees/`

Its name follows the pattern:

```
sandcastle/impl/${new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19)}
```

Example: `sandcastle/impl/2026-05-17T15-20-45`

Check both directories to find the active worktree before merging.

## Workflow

### 1. Merge the branch

1. Run `git merge {{BRANCH}} --no-edit`
2. If there are merge conflicts, resolve them intelligently by reading both sides and choosing the correct resolution
3. After resolving conflicts, run `pnpm run typecheck` and `pnpm run test` to verify everything works
4. If tests fail, fix the issues before proceeding

You can use `scripts/merge.sh` to automate steps 1, 3, and 4 (conflict resolution still requires manual reasoning).

### 2. Close the issue

After the merge succeeds, close the issue. If `{{ISSUE_ID}}` is empty, **skip this step and do not attempt to close anything**.

```bash
gh issue close {{ISSUE_ID}} --comment "Completed by Sandcastle and merged to main."
```

### 3. Signal completion

Once you've merged (and closed the issue if applicable), output exactly:

```
<promise>COMPLETE</promise>
```

## Notes

- The completion tag `<promise>COMPLETE</promise>` is part of the Sandcastle protocol and must be preserved verbatim.
- Never close an issue if `{{ISSUE_ID}}` is empty or missing.
- Branch names are timestamp-based; if multiple `sandcastle/impl/*` branches exist, confirm with the user which one to merge.

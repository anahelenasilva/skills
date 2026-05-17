# sandcastle-merge

A Claude skill that automates the **Sandcastle merge protocol**: merging an implementation branch, verifying it with `pnpm` (typecheck + tests), and optionally closing the linked GitHub issue.

## Setup

Make the scripts executable (one-time):

```bash
chmod +x scripts/*.sh
```

Requirements:

- [`pnpm`](https://pnpm.io/) — for `typecheck` and `test`
- [`gh`](https://cli.github.com/) — GitHub CLI, authenticated (`gh auth login`)
- `git` with the target worktree available locally

## How it works

The skill activates when you mention **"Sandcastle"** or ask Claude to merge an implementation branch and close an issue.

### Branch discovery

Sandcastle creates worktrees under one of:

- `.sandcastle/worktrees/`
- `.claude/worktrees/`

Branch names follow:

```
sandcastle/impl/<ISO-timestamp>
```

Example: `sandcastle/impl/2026-05-17T15-20-45`

If no branch is passed, `merge.sh` auto-picks the **most recent** worktree from either directory.

### Workflow

1. **Merge** — `scripts/merge.sh [BRANCH]`
   - Auto-detects branch if omitted
   - Runs `git merge --no-edit`
   - Halts on conflicts so they can be resolved manually
   - Runs `pnpm run typecheck` + `pnpm run test`

2. **Close issue** — `scripts/close-issue.sh [ISSUE_ID]`
   - Calls `gh issue close` with the Sandcastle completion comment
   - Skips silently if no ID is provided

3. **Signal completion** — Claude outputs the protocol tag verbatim:
   ```
   <promise>COMPLETE</promise>
   ```

## Usage examples

**Auto-detect latest worktree, no issue:**

```bash
bash scripts/merge.sh
```

**Explicit branch + close issue #123:**

```bash
bash scripts/merge.sh sandcastle/impl/2026-05-17T15-20-45
bash scripts/close-issue.sh 123
```

## Files

```
sandcastle-merge/
├── README.md
├── SKILL.md              # skill manifest + instructions for Claude
└── scripts/
    ├── merge.sh          # merge + verify (cross-platform: macOS & Linux)
    └── close-issue.sh    # gh issue close wrapper
```

## Notes

- The `<promise>COMPLETE</promise>` tag is **part of the Sandcastle protocol** — preserved verbatim by the skill.
- Scripts are POSIX-friendly and tested on macOS (BSD) and Linux (GNU).

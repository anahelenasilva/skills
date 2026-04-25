---
name: implement-and-ship
description: End-to-end implementation workflow. Given a plan reference (Linear issue URL, GitHub issue URL, or local markdown file path), creates a feature branch auto-named from the plan ID/title, implements the plan, spawns a code-reviewer agent and applies only critical/blocking suggestions, then commits, pushes, and opens a PR using the project PR template. Trigger with phrases like "implement this plan", "implement and ship", "build from plan", or when given a plan link/file to implement end-to-end. Do NOT use for: reviewing code only, creating PRs without implementation, or tasks without a plan reference.
license: CC-BY-4.0
metadata:
  author: Ana Helena
  version: 1.0.0
---

# Implement and Ship

Reads a plan, creates a branch, implements, reviews, applies critical fixes, ships a PR.

## Phase 1: Read the Plan

Detect plan source from the argument provided:

**Linear URL** (`linear.app` in URL): use Linear MCP to fetch the issue. Extract: title, description, acceptance criteria, issue ID (e.g. `ENG-123`).

**GitHub issue URL** (`github.com` + `/issues/` in URL): run `gh issue view <number> --repo <owner/repo> --json title,body,number`. Extract: title, body, number.

**Local file path** (starts with `/` or `./`, ends with `.md`): use Read tool. Extract: first heading as title, full content as description.

Store: `plan_title`, `plan_description`, `plan_id` (issue ID or filename slug).

## Phase 2: Create Branch

Derive branch name from plan source:

| Source | Format | Example |
|--------|--------|---------|
| Linear | `feat/<issue-id>-<slug>` | `feat/ENG-123-add-auth-middleware` |
| GitHub | `feat/GH-<number>-<slug>` | `feat/GH-88-rate-limiting` |
| Local file | `feat/<slug-from-title>` | `feat/auth-refresh-token` |

Slug rules: lowercase, hyphens only, max 40 chars, strip special characters.

```bash
git checkout -b <branch-name>
```

Confirm branch created before proceeding.

## Phase 3: Implement the Plan

- Break plan into thin vertical slices
- Implement each slice; verify it compiles and tests pass before moving to next
- Use plan acceptance criteria as definition of done
- Do NOT touch files outside the plan scope

Run tests after each meaningful slice:
```bash
pnpm test
```

Stop and report if tests fail at any point — do not proceed to review with failing tests.

## Phase 4: Code Review

After implementation is complete and all tests pass, spawn a review agent:

```
Agent({
  subagent_type: "agent-skills:code-reviewer",
  description: "Review implementation for <branch-name>",
  prompt: "Review all changes on branch <branch-name> vs main. List ONLY critical or blocking issues that must be fixed before merge. For each issue: file path, line number, problem description, suggested fix. Ignore style, readability, and optional refactors."
})
```

A suggestion is **critical/blocking** if it involves:
- Correctness bugs (wrong logic, null crashes, off-by-one errors)
- Security vulnerabilities (injection, auth bypass, data exposure)
- Missing error handling at system boundaries (user input, external APIs)
- Architecture violations (circular deps, broken public contracts)

**Skip:** style suggestions, readability improvements, optional refactors, performance micro-optimizations (unless plan explicitly targets performance).

## Phase 5: Apply Critical Suggestions

For each critical suggestion:
1. Locate the file and line
2. Apply the fix
3. Run `pnpm test` to confirm fix doesn't break anything

If a suggestion is ambiguous or would significantly expand scope, skip it and note it under "Known Issues / Follow-up" in the PR body.

## Phase 6: Ship

Invoke the `commit-commands:commit-push-pr` skill.

After the PR is created, run:
```bash
gh pr view --json url -q .url
```
Output the URL to the user as the final message.

Before invoking, prepare the PR body using `.github/PULL_REQUEST_TEMPLATE.md`. Fill every section — no template placeholders left:

```markdown
## Problem

<what was missing or broken — link to plan: Linear/GitHub URL or file path>

## Solution

<summary of what was implemented — key design decisions, tradeoffs>

## Type

- [x] <check the appropriate box based on plan content>

## Test Plan

- [x] Unit tests pass (`pnpm test`)
- [ ] e2e tests pass (`pnpm test:e2e`)
- Manual steps:
  1. <step>

## DB Changes

- [x] <appropriate box — No schema changes / Migration included / Seed data updated>

## Checklist

- [x] No `console.log` left in
- [x] No hardcoded secrets or env values
- [x] Public API contracts unchanged (or breaking change flagged)
```

## Error Handling

| Situation | Action |
|-----------|--------|
| Linear MCP not authenticated | Prompt: `! mcp__linear-server authenticate` |
| Branch already exists | Ask user: checkout existing or create with suffix |
| Tests fail after implementation | Stop, report failures, do not proceed to review |
| Tests fail after applying a suggestion | Revert that suggestion, note in PR as follow-up |
| `gh` not authenticated | Prompt: `! gh auth login` |
| Plan content is ambiguous | List assumptions explicitly, ask user to confirm before implementing |

## Examples

### Example 1: Linear issue

User: `implement this plan: https://linear.app/team/issue/ENG-42/add-rate-limiting`

1. Fetch ENG-42 via Linear MCP
2. Branch: `feat/ENG-42-add-rate-limiting`
3. Implement → test → review → fix critical → PR

### Example 2: Local markdown file

User: `implement this plan: ./docs/specs/auth-refresh-token.md`

1. Read file with Read tool
2. Branch: `feat/auth-refresh-token`
3. Implement → test → review → fix critical → PR

### Example 3: GitHub issue

User: `implement this plan: https://github.com/org/repo/issues/88`

1. `gh issue view 88 --repo org/repo --json title,body,number`
2. Branch: `feat/GH-88-slug-from-title`
3. Implement → test → review → fix critical → PR

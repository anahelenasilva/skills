---
name: implement-plan
description: Implements a plan from a markdown file, phase by phase, with semantic branch names and commits between phases. Use when user says "implement this plan", "implement plan", "execute this plan", "run this plan", or references a plan file path to implement. Can also push and open a PR if explicitly asked. Do NOT use for creating plans, reviewing plans, or general code tasks without a plan file.
license: CC-BY-4.0
metadata:
  author: Ana Helena
  version: 1.0.0
---

# Implement Plan

Reads a markdown plan file, creates a semantic git branch, implements each phase with commits between them, and runs verification steps.

## Instructions

### Step 1: Read and Analyze the Plan

Read the plan file at the given path. Extract:

- **Title/goal** — what the plan accomplishes
- **Change type** — is this a feature (`feat`), bug fix (`fix`), refactor (`refactor`), chore (`chore`), docs (`docs`), or test (`test`)?
- **Phases** — the ordered implementation sections
- **Verification steps** — any testing/validation commands at the end

If the plan file doesn't exist or is empty, stop and tell the user.

If the plan has no clear phases or sections, treat the entire implementation as a single phase.

### Step 2: Create a Semantic Branch

Derive the branch name from the plan's title and change type:

```
<type>/<short-kebab-description>
```

**Type mapping:**
- New capability or behavior → `feat/`
- Bug fix → `fix/`
- Code restructuring without behavior change → `refactor/`
- Build, CI, dependencies → `chore/`
- Documentation only → `docs/`
- Test additions/fixes only → `test/`

**Branch name rules:**
- Use kebab-case for the description
- Keep it under 50 characters total
- Derive from the plan title, not the filename

Create the branch from the current HEAD before writing any code.

### Step 3: Implement Phase by Phase

For each phase in the plan:

1. **Read the phase carefully** — understand all file changes, new files, and code modifications specified
2. **Implement all changes in the phase** — follow the plan's instructions precisely, including file paths, code snippets, and structural changes
3. **Commit when the phase is complete** — use a descriptive commit message that references the phase:
   ```
   <type>(<scope>): <what this phase accomplishes>
   ```
   Stage only the files changed in that phase.

Do not move to the next phase until the current one is committed.

If a phase's instructions are ambiguous or reference code that doesn't exist, stop and ask the user before guessing.

### Step 4: Run Verification

After all phases are implemented and committed, look for a verification/testing section in the plan. Common patterns:

- Sections titled "Verification", "Testing", "Validation", "How to verify"
- Command lists (e.g., `pnpm test`, `pnpm build`, migration commands)
- Manual check descriptions

For each verification step that can be automated (shell commands, test runs, build checks):

1. Run the command
2. If it fails, attempt to fix the issue
3. If the fix requires code changes, commit them as `fix(<scope>): resolve <what failed>`
4. Re-run verification to confirm the fix worked

Report the verification results to the user. If any manual checks are listed, remind the user to perform them.

### Step 5: Stop and Report

After verification, present a summary:

- Branch name created
- Number of phases implemented
- Commits made (short hashes + messages)
- Verification results (pass/fail per step)
- Any manual checks the user still needs to do

**Stop here.** Do not push or create a PR unless the user explicitly asks.

### Step 6 (Only if explicitly asked): Push and PR

If the user says to push, create a PR, or similar:

1. Push the branch to origin with `-u` flag
2. If asked to create a PR, open one with:
   - Title derived from the plan title
   - Body summarizing the phases implemented and verification results

## Examples

### Example 1: Feature plan

User says: "implement this plan docs/plans/goal-entry-value-plan.md"

Actions:
1. Read `docs/plans/goal-entry-value-plan.md`
2. Determine type: `feat` (adds new capability)
3. Create branch: `feat/goal-entry-value`
4. Implement Phase 1 (Backend) → commit: `feat(backend): add goal type and entry value columns`
5. Implement Phase 2 (Frontend) → commit: `feat(frontend): add value input for goal entries`
6. Run verification: `pnpm --filter backend run test`, `pnpm --filter frontend run build`
7. Report results and stop

### Example 2: Removal/cleanup plan

User says: "implement this plan docs/plans/remove-weight-unit-plan.md"

Actions:
1. Read `docs/plans/remove-weight-unit-plan.md`
2. Determine type: `refactor` (removing unnecessary field)
3. Create branch: `refactor/remove-weight-unit`
4. Implement migration → commit: `refactor(backend): drop weightUnit column`
5. Implement backend changes → commit: `refactor(backend): remove weightUnit from entities and DTOs`
6. Implement frontend changes → commit: `refactor(frontend): remove weight unit selector, hardcode kg`
7. Run verification commands from plan
8. Report results and stop

### Example 3: User asks to also push and PR

User says: "implement this plan docs/plans/some-plan.md and open a PR"

Actions:
1-7. Same as above
8. Push branch: `git push -u origin feat/some-feature`
9. Create PR with title and summary from plan

## Troubleshooting

### Plan file not found

Cause: wrong path or file doesn't exist.
Solution: ask the user to confirm the path. Check relative to the current working directory.

### Phase references nonexistent code

Cause: the plan may be outdated or based on a different branch state.
Solution: stop and ask the user. Do not guess or improvise — the plan is the source of truth.

### Verification step fails after fix attempt

Cause: the fix may have introduced new issues or the plan's approach may be flawed.
Solution: after two failed fix attempts for the same verification step, stop and report the failure to the user with the error output. Let them decide how to proceed.

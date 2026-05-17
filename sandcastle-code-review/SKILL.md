---
name: sandcastle-code-review
description: Reviews and refines code on a branch for the Sandcastle project. Use when asked to "review", "clean up", "refine", or "code review" on a branch. Call as `/sandcastle-code-review` to review the current branch, or `/sandcastle-code-review [branch-name]` to review a specific branch. Makes improvements in place — reads the diff, fixes issues, runs tests, commits. Do NOT use for general code questions or reviews outside the Sandcastle project.
license: CC-BY-4.0
metadata:
  author: anahelenarp@hotmail.com
  version: 1.0.0
---

# sandcastle-code-review

Reviews code on a branch against project standards, makes improvements directly, runs tests, and commits. If the code is already clean, does nothing.

## Setup

**Determine the target branch:**

If `$ARGUMENTS` is non-empty, check out that branch first:

```bash
git checkout $ARGUMENTS
```

If `$ARGUMENTS` is empty, stay on the current branch. Confirm which branch is active:

```bash
git branch --show-current
```

## Review Process

### Step 1: Understand the change

Read the diff and recent commits to understand intent before forming any opinions:

```bash
git log --oneline -10
git diff main...HEAD   # or against the appropriate base branch
```

### Step 2: Read the coding standards

Read `.sandcastle/CODING_STANDARDS.md` in full before proceeding. All improvements must conform to those standards.

### Step 3: Analyze for improvements

Look for opportunities to improve, in priority order:

**Complexity & structure**
- Reduce unnecessary nesting and indirection
- Eliminate redundant code and abstractions
- Consolidate related logic that is split across unrelated locations
- Avoid nested ternary operators — prefer `switch` statements or `if/else` chains

**Readability**
- Improve variable and function names to better express intent
- Remove comments that describe what the code obviously does
- Choose explicit over clever — readable code over compact code

**Correctness**
- Does the implementation match the intent inferred from the commits?
- Are edge cases handled?
- Are new or changed behaviours covered by tests?
- Are there unsafe casts, `any` types, or unchecked assumptions?
- Does the change introduce injection vulnerabilities, credential leaks, or other security issues?

**Balance check — avoid over-simplification that:**
- Removes helpful abstractions that improve code organisation
- Combines too many concerns into a single function or component
- Produces clever solutions that are hard to understand or debug

### Step 4: Execute improvements

If you found improvements to make:

1. Make the changes directly on the branch
2. Run tests and type checking:
   ```bash
   pnpm test
   pnpm run typecheck
   ```
3. Confirm nothing is broken before committing
4. Commit with a message that describes the refinements made:
   ```bash
   git commit -m "refactor: <describe the improvements>"
   ```

If the code is already clean and well-structured, do nothing — no empty commits.

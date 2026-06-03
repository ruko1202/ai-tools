---
name: pr
description: >-
  Write a clear, English-language title and summary for a pull request based on
  the work done in the current git branch. Use this whenever the user asks to
  describe, summarize, or write up a PR / pull request / merge request — for
  example "напиши заголовок и саммари для ПРа", "опиши этот PR", "draft a PR
  description", "make a summary for my pull request", or "what should the PR
  title be". Trigger it even when the user doesn't say the word "summary"
  explicitly but clearly wants their branch's changes turned into PR text.
---

# PR title & summary

Turn the changes on the current branch into a pull-request **title** and
**summary**, written in **English**, regardless of the language the user writes
to you in. The reader of a PR is usually a teammate reviewing code, and the
English output keeps PRs consistent across the repo.

The summary is **a single short prose paragraph**, not a bulleted changelog and
not a file-by-file walkthrough. Reviewers want to know *what this PR does and
why* before they read the diff — restating every change is noise.

## Workflow

### 1. Gather the branch context

Run the bundled script from the repo root. It detects the base branch
(`main`/`master`/the remote default), then prints the branch's commits, a
diffstat, and the full diff against the merge-base:

```bash
bash scripts/gather_pr_context.sh
```

If the repo branches off something other than main/master (e.g. `develop`),
pass it explicitly: `bash scripts/gather_pr_context.sh origin/develop`.

Why the merge-base and not a plain `git diff main`: comparing against the point
where the branch *diverged* means commits that landed on main after you branched
off don't leak into the diff and confuse the summary.

If the script reports zero commits, there's nothing to describe — tell the user
the branch has no changes beyond the base instead of inventing a summary.

### 2. Read the diff for intent, not just the commit messages

Commit messages are a hint, but they're often terse ("wip", "fix", "review
comments") and don't explain the *why*. Read the actual diff to understand what
the change accomplishes: a new feature, a bug fix, a refactor, a config bump.
Lockfiles, generated code, and vendored dependencies can be acknowledged in one
clause — don't let them dominate the summary.

### 3. Write the title

- One line, English, **imperative mood** ("Add retry logic to the upload
  client", not "Added" / "Adding").
- Aim for ~50 characters, hard cap around 72 so it isn't truncated in GitHub.
- If the repo's existing commit or PR history uses a convention (e.g.
  Conventional Commits like `feat:` / `fix:`, or a `[TICKET-123]` prefix), match
  it. You can check with `git log --oneline -20 <base>`. If there's no clear
  convention, a plain descriptive title is fine — don't impose one.

### 4. Write the summary

One tight paragraph (roughly 2–5 sentences) in English that answers: what does
this PR change, and why does it matter? Lead with the intent. Mention notable
implementation choices or trade-offs only if a reviewer would want them up
front. Skip ceremony like "This PR..." when a direct sentence reads better.

### 5. Present the result

Output the title and summary in a format that's easy to paste into a PR:

```
Title: <the title>

<the summary paragraph>
```

Then offer to adjust tone, length, or add a section (testing notes, ticket
link) if the user wants — but don't add those by default, since the user asked
for a simple title + paragraph.

## Example

Suppose the branch adds debounced search and removes a now-unused helper.

```
Title: Add debounced search to the contacts list

Replaces the per-keystroke contacts query with a 300ms debounced search so the
backend isn't hit on every character, cutting request volume on the contacts
page substantially. Also removes the now-unused `legacySearch` helper that the
old implementation relied on.
```

Note how it states the change and the payoff (fewer requests) in plain prose,
and folds the cleanup into one clause rather than listing every touched file.

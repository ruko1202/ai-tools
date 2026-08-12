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

The summary is **a short lead sentence or two followed by a few bullet points**,
not one dense wall-of-text paragraph and not a file-by-file walkthrough. Lead
with *what this PR does and why*; let the bullets carry the notable specifics so
a reviewer can scan them. Restating every changed file is noise.

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
bullet — don't let them dominate the summary.

### 3. Write the title

- One line, English, **imperative mood** ("Add retry logic to the upload
  client", not "Added" / "Adding").
- Aim for ~50 characters, hard cap around 72 so it isn't truncated in GitHub.
- If the repo's existing commit or PR history uses a convention (e.g.
  Conventional Commits like `feat:` / `fix:`, or a `[TICKET-123]` prefix), match
  it. You can check with `git log --oneline -20 <base>`. If there's no clear
  convention, a plain descriptive title is fine — don't impose one.

### 4. Write the summary

Structure it so a reviewer can scan it in seconds:

- **Lead** with one or two plain sentences stating what the PR changes and why
  it matters. Skip ceremony like "This PR..." when a direct sentence reads
  better.
- **Then a short bullet list** (roughly 3–6 bullets) of the notable changes,
  grouped by intent rather than by file. Each bullet is one idea — a new
  endpoint, a behavior guarantee, a guard, a migration, a trade-off worth
  flagging. Fold generated code / stubs / follow-ups into a single bullet.

Keep it tight: bullets are short fragments, not paragraphs. If the change is
genuinely tiny (a one-line fix), a single lead sentence with no bullets is fine
— don't pad it.

### 5. Present the result

Present the title and the summary as **two separate fenced code blocks**, so the
user can copy each one independently. Put the title in its own block and the
summary (lead + bullets) in another, each under a short label:

**Title**

```
<the title>
```

**Summary**

```
<lead sentence(s)>

- <change 1>
- <change 2>
- <change 3>
```

Then offer to adjust tone, length, or add a section (testing notes, ticket
link) if the user wants — but don't add those by default, since the user asked
for a simple title + summary.

## Example

Suppose the branch adds debounced search and removes a now-unused helper.

**Title**

```
Add debounced search to the contacts list
```

**Summary**

```
Debounces the contacts search so the backend isn't hit on every keystroke,
cutting request volume on the contacts page substantially.

- Replace the per-keystroke query with a 300ms debounced search
- Cancel the in-flight request when a new keystroke supersedes it
- Remove the now-unused `legacySearch` helper the old path relied on
```

Note how the lead states the change and the payoff (fewer requests) in plain
prose, and the bullets carry the specifics grouped by intent rather than listing
every touched file.
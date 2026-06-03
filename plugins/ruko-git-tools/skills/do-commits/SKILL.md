---
name: do-commits
description: Turn a messy working tree into a clean series of logical git commits. Use this whenever the user wants to commit their current changes, split a big pile of uncommitted work into separate commits, "group commits by logic", tidy up before pushing or opening a PR, or says things like "сделай коммиты", "закоммить изменения", "commit my changes", or "break this into proper commits". Trigger even when the user doesn't say the word "commit" explicitly but clearly has staged/unstaged changes they want recorded sensibly.
---

# do-commits

Take whatever is currently uncommitted in the repo and record it as a small series of clean, logically-grouped git commits. The goal is a history where each commit is one coherent idea — easy to review, easy to revert, easy to read in a `git log`.

The hard part isn't running `git commit`; it's deciding *what goes together*. A typical working tree mixes a bugfix, a bit of refactoring, a new feature, and some stray formatting — all tangled across the same files. This skill is about untangling that.

## Settings for this skill

- **Message format:** Conventional Commits (`type(scope): summary`).
- **Language:** English.
- **Mode:** commit immediately — don't stop to ask for plan approval. Just analyze, group, commit, and report what you did. (The exception is the safety stops below.)

## Workflow

### 1. Understand the working tree

Run these to see the full picture before touching anything:

```bash
git status
git diff               # unstaged changes
git diff --staged      # already-staged changes
git log --oneline -10  # recent history, to match existing style
```

For untracked files, look at what they are (`git status --porcelain`, then read the new files). Read enough of the diff to actually understand the *intent* of each change — grouping well requires knowing what the code does, not just which lines moved.

### 2. Group the changes by intent

Cluster the changes into logical units. A good unit is one reviewer-sized idea: a single bugfix, one new feature, one refactor, a docs update. Use these signals:

- **Same purpose** → same commit (e.g. all the edits that implement one feature, even across several files).
- **Different purpose** → different commits, even if they sit in the same file. A formatting cleanup that happens to be in `auth.py` does not belong in the commit that fixes the auth bug.
- **Dependencies first.** If commit B won't make sense or won't build without commit A, order A before B. Aim for a history where each commit is self-consistent.

When two unrelated changes live in the same file, stage them separately with patch mode:

```bash
git add -p path/to/file   # pick only the hunks for this commit
```

If hunks are too coarse to split cleanly, `git add -e` lets you edit the staged patch by hand. Reach for this only when `-p` can't separate the changes.

### 3. Commit each group

For each logical unit: stage exactly its changes, then commit with a Conventional Commit message. Verify staging with `git diff --staged` before committing so nothing leaks into the wrong commit.

```bash
git add path/to/relevant/files
git commit -m "feat(auth): add JWT refresh-token rotation"
```

Repeat until `git status` is clean. Then show the user a short summary: `git log --oneline` of the commits you created.

## Commit message format

Conventional Commits, in English. Subject line: `type(scope): summary`.

- **type** — one of: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`, `build`, `ci`.
- **scope** — optional, the area touched (`auth`, `api`, `parser`). Drop it if it adds no information.
- **summary** — imperative mood, lowercase, no trailing period, aim for ≤ 50 chars ("add", not "added"/"adds").
- **body** — optional. Add a short wrapped paragraph only when the *why* isn't obvious from the subject. Don't pad commits with a body just to have one.

Match the dominant style already in `git log` where it doesn't conflict with the above (e.g. if the repo always uses scopes, keep using them).

**Example 1:**
Changes: new password-reset endpoint plus its tests
Output: `feat(auth): add password-reset endpoint`

**Example 2:**
Changes: fixed off-by-one in pagination that dropped the last row
Output:
```
fix(api): include final row in paginated results

Pagination used a < bound on the page offset, so the last item
on each page was silently skipped.
```

**Example 3:**
Changes: renamed variables and extracted a helper, no behavior change
Output: `refactor(parser): extract token-normalization helper`

## Safety stops

Commit immediately by default, but pause and tell the user instead of guessing when:

- **Nothing to commit** — say so; don't create an empty commit.
- **A merge/rebase is in progress or there are conflict markers** (`<<<<<<<`) in the diff — committing now would record a broken state. Flag it.
- **Secrets or junk** appear in the diff — API keys, `.env` files, credentials, large binaries, vendored build output. Point them out and leave them unstaged rather than committing them.
- **Pre-commit hooks fail** — report the failure and what it said; don't bypass with `--no-verify` unless the user asks.

These aren't "ask permission to commit" — they're "don't commit something the user would regret." Everything else: proceed.

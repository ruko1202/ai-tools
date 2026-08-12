#!/usr/bin/env bash
# Gather everything needed to describe a pull request:
#   - the base branch the current branch diverged from
#   - the list of commits unique to this branch
#   - a diffstat (which files changed and how much)
#   - the full diff (against the merge-base, so changes that landed on the
#     base branch *after* you branched off don't leak in)
#
# Usage: gather_pr_context.sh [base_branch]
# If base_branch is omitted, the script tries to detect it.

set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository." >&2
  exit 1
fi

current_branch="$(git rev-parse --abbrev-ref HEAD)"

# --- Resolve the base branch ----------------------------------------------
base="${1:-}"

if [ -z "$base" ]; then
  # 1) Prefer the remote's default branch if we can read it.
  if git symbolic-ref refs/remotes/origin/HEAD >/dev/null 2>&1; then
    base="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/@@')"
  fi
fi

# 2) Fall back to common names that actually exist as refs.
if [ -z "$base" ]; then
  for cand in origin/main origin/master main master; do
    if git rev-parse --verify "$cand" >/dev/null 2>&1; then
      base="$cand"
      break
    fi
  done
fi

if [ -z "$base" ]; then
  echo "ERROR: could not detect a base branch. Pass one explicitly, e.g.:" >&2
  echo "  gather_pr_context.sh origin/develop" >&2
  exit 1
fi

# Use the merge-base so the diff reflects only what THIS branch introduced.
merge_base="$(git merge-base "$base" HEAD)"

commit_count="$(git rev-list --count "$merge_base"..HEAD)"

echo "=== PR CONTEXT ==="
echo "current_branch: $current_branch"
echo "base_branch:    $base"
echo "commits:        $commit_count"
echo

if [ "$commit_count" -eq 0 ]; then
  echo "(No commits on this branch beyond the base. Nothing to describe yet.)"
  exit 0
fi

echo "=== COMMITS (oldest -> newest) ==="
git log --reverse --pretty=format:'%h %s%n%w(0,4,4)%b' "$merge_base"..HEAD
echo
echo

echo "=== DIFFSTAT ==="
git diff --stat "$merge_base"...HEAD
echo

echo "=== FULL DIFF ==="
git diff "$merge_base"...HEAD

#!/bin/bash
# Worktree → Main 머지
# Usage: ./scripts/merge-worktree.sh <worktree_name>
set -euo pipefail

WORKTREE_NAME=$1
WORKTREE_PATH=".claude/worktrees/$WORKTREE_NAME"
BRANCH="worktree-$WORKTREE_NAME"

if [ ! -d "$WORKTREE_PATH" ]; then
  echo "Worktree not found: $WORKTREE_PATH"
  exit 1
fi

# worktree에서 미커밋 변경사항 커밋
if ! (cd "$WORKTREE_PATH" && git diff --quiet && git diff --cached --quiet); then
  (cd "$WORKTREE_PATH" && git add -A && git commit -m "auto: $WORKTREE_NAME phase complete")
fi

# main에 머지
git merge "$BRANCH" --no-ff -m "merge: $WORKTREE_NAME phase complete"
echo "Merged $BRANCH into $(git branch --show-current)"

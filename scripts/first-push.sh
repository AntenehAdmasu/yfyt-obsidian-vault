#!/usr/bin/env bash
# Run once from your Mac after creating an empty repo on GitHub (or elsewhere).
# Usage: ./scripts/first-push.sh https://github.com/AntenehAdmasu/yfyt-obsidian-vault.git
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

REMOTE="${1:?Pass the remote URL, e.g. https://github.com/AntenehAdmasu/yfyt-obsidian-vault.git}"

if [[ -d .git ]]; then
  echo "Repository already initialized (.git exists)." >&2
else
  git init
  git branch -M main
fi

git add -A
if git diff --cached --quiet; then
  echo "Nothing to commit." >&2
else
  git commit -m "Initial commit: YFYT Obsidian vault"
fi

if git remote get-url origin &>/dev/null; then
  git remote set-url origin "$REMOTE"
else
  git remote add origin "$REMOTE"
fi

git push -u origin main

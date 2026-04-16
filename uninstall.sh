#!/usr/bin/env bash
# uninstall.sh — Remove GTM pipeline skill symlinks from ~/.claude/skills/
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "GTM Pipeline Skills — Uninstall"
echo ""

for skill_dir in "$SKILLS_SRC"/gtm-*; do
  name="$(basename "$skill_dir")"
  dst="$SKILLS_DST/$name"

  if [[ -L "$dst" ]]; then
    rm "$dst"
    echo -e "${GREEN}  removed${NC} $name"
  elif [[ -d "$dst" ]]; then
    echo -e "${YELLOW}  skip${NC}   $name (real directory, not a symlink — remove manually if needed)"
  else
    echo -e "${YELLOW}  skip${NC}   $name (not found)"
  fi
done

echo ""
echo "Done. Your _shared/local.md is preserved in the repo (gitignored)."

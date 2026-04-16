#!/usr/bin/env bash
# install.sh — Symlink GTM pipeline skills into ~/.claude/skills/
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "GTM Pipeline Skills — Install"
echo "Source: $SKILLS_SRC"
echo "Target: $SKILLS_DST"
echo ""

# Ensure ~/.claude/skills exists
mkdir -p "$SKILLS_DST"

# Symlink each gtm-* directory
# Note: _shared is a relative symlink inside skills/gtm-pipeline/ (committed to repo)
# so it resolves automatically — no separate symlink needed here.
for skill_dir in "$SKILLS_SRC"/gtm-*; do
  name="$(basename "$skill_dir")"
  dst="$SKILLS_DST/$name"

  if [[ -L "$dst" ]]; then
    echo -e "${YELLOW}  skip${NC}   $name (already symlinked)"
  elif [[ -d "$dst" ]]; then
    echo -e "${RED}  conflict${NC} $name — real directory exists at $dst"
    echo "           To replace it: rm -rf \"$dst\" && ./install.sh"
  else
    ln -s "$skill_dir" "$dst"
    echo -e "${GREEN}  linked${NC}  $name"
  fi
done

# Create local.md from example if it doesn't exist
LOCAL_MD="$SKILLS_SRC/_shared/local.md"
LOCAL_EXAMPLE="$SKILLS_SRC/_shared/local.example.md"
if [[ ! -f "$LOCAL_MD" ]]; then
  if [[ -f "$LOCAL_EXAMPLE" ]]; then
    cp "$LOCAL_EXAMPLE" "$LOCAL_MD"
    echo ""
    echo -e "${GREEN}  created${NC} _shared/local.md from local.example.md"
    echo "           Fill in your PhantomBuster agent IDs and GTM_ENV_PATH."
  fi
fi

echo ""
echo "Done. Run /gtm-pipeline:setup in Claude Code to finish configuration."

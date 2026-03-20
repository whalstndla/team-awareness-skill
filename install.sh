#!/bin/bash
# team-awareness skill installer for Claude Code
# Usage: curl -sL https://raw.githubusercontent.com/whalstndla/team-awareness-skill/main/install.sh | bash

set -e

SKILL_NAME="team-awareness"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
REPO_URL="https://raw.githubusercontent.com/whalstndla/team-awareness-skill/main"

echo "Installing $SKILL_NAME skill..."

# Create skill directory
mkdir -p "$SKILL_DIR"

# Download SKILL.md
curl -sL "$REPO_URL/SKILL.md" -o "$SKILL_DIR/SKILL.md"

if [ -f "$SKILL_DIR/SKILL.md" ]; then
  echo "✅ Installed to $SKILL_DIR"
  echo ""
  echo "The skill will auto-activate when team agents are spawned."
  echo "No additional configuration needed."
else
  echo "❌ Installation failed"
  exit 1
fi

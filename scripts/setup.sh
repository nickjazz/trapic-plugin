#!/bin/bash
# Trapic token setup — interactive token configuration
# Usage: bash setup.sh
# Or:    curl -fsSL https://raw.githubusercontent.com/trapicAi/trapic-plugin/main/scripts/setup.sh | bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

echo ""
echo -e "${BLUE}=== Trapic Token Setup ===${NC}"
echo ""

# Check if already configured via environment
if [ -n "$TRAPIC_TOKEN" ]; then
  echo -e "${GREEN}✓${NC} TRAPIC_TOKEN is already set in environment: ${TRAPIC_TOKEN:0:6}..."
  echo "  Trapic is ready to use."
  exit 0
fi

# Check if token exists in settings.json
if [ -f "$SETTINGS" ]; then
  TOKEN_VAL=$(python3 -c "import json; d=json.load(open('$SETTINGS')); print(d.get('env',{}).get('TRAPIC_TOKEN',''))" 2>/dev/null)
  if [ -n "$TOKEN_VAL" ] && [ "$TOKEN_VAL" != "PASTE_YOUR_TOKEN_HERE" ]; then
    echo -e "${GREEN}✓${NC} Token already configured in $SETTINGS: ${TOKEN_VAL:0:6}..."
    echo ""
    read -p "  Replace with a new token? (y/N): " REPLACE < /dev/tty
    if [ "$REPLACE" != "y" ] && [ "$REPLACE" != "Y" ]; then
      echo "  Keeping existing token. Restart Claude Code to load it."
      exit 0
    fi
  fi
fi

# Interactive token prompt
echo "  Get your free API token at: https://trapic.ai"
echo ""
read -p "  Paste your token (tr_...): " TOKEN < /dev/tty

if [ -z "$TOKEN" ]; then
  echo ""
  echo -e "${YELLOW}!${NC} No token entered. You can run this script again later."
  exit 0
fi

# Validate token format
if [[ ! "$TOKEN" =~ ^tr_ ]]; then
  echo ""
  echo -e "${YELLOW}!${NC} Token doesn't start with 'tr_'. Are you sure this is correct?"
  read -p "  Continue anyway? (y/N): " CONTINUE < /dev/tty
  if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
    echo "  Aborted. Run this script again with the correct token."
    exit 1
  fi
fi

# Write token to settings.json
python3 -c "
import json, os
p = os.path.expanduser('$SETTINGS')
d = json.load(open(p)) if os.path.exists(p) else {}
d.setdefault('env', {})['TRAPIC_TOKEN'] = '$TOKEN'
json.dump(d, open(p, 'w'), indent=2)
" 2>/dev/null

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} Token saved to $SETTINGS"
else
  echo -e "${RED}✗${NC} Failed to write token. Manually add to $SETTINGS:"
  echo '  { "env": { "TRAPIC_TOKEN": "'"$TOKEN"'" } }'
  exit 1
fi

# Verify token works
echo ""
echo -e "${BLUE}Verifying token...${NC}"
HEALTH_RESP=$(curl -sf -H "Authorization: Bearer $TOKEN" "https://mcp.trapic.ai/health" 2>/dev/null || echo "")
if [ -n "$HEALTH_RESP" ]; then
  echo -e "${GREEN}✓${NC} Token verified — connection to trapic.ai is working."
else
  echo -e "${YELLOW}!${NC} Could not verify token. It may still work — check after restarting Claude Code."
fi

echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo "  Restart Claude Code to activate."
echo ""

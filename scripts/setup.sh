#!/bin/bash
# Trapic token setup — writes to Claude Code settings.json

SETTINGS="$HOME/.claude/settings.json"

echo ""
echo "=== Trapic Setup ==="
echo ""

# Check if already configured
if [ -n "$TRAPIC_TOKEN" ]; then
  echo "TRAPIC_TOKEN is already set: ${TRAPIC_TOKEN:0:6}..."
  echo "Trapic plugin is ready to use."
  exit 0
fi

# Check if token exists in settings.json
if [ -f "$SETTINGS" ] && grep -q "TRAPIC_TOKEN" "$SETTINGS" 2>/dev/null; then
  TOKEN_VAL=$(python3 -c "import json; d=json.load(open('$SETTINGS')); print(d.get('env',{}).get('TRAPIC_TOKEN',''))" 2>/dev/null)
  if [ -n "$TOKEN_VAL" ] && [ "$TOKEN_VAL" != "PASTE_YOUR_TOKEN_HERE" ]; then
    echo "TRAPIC_TOKEN found in $SETTINGS: ${TOKEN_VAL:0:6}..."
    echo "Restart Claude Code to load it."
    exit 0
  fi
fi

echo "No TRAPIC_TOKEN found."
echo ""
echo "Steps:"
echo "  1. Go to https://trapic.ai and sign up / log in"
echo "  2. Copy your API token (starts with tr_)"
echo "  3. Add to Claude Code settings:"
echo ""
echo "     Edit $SETTINGS and add:"
echo '     {'
echo '       "env": {'
echo '         "TRAPIC_TOKEN": "tr_YOUR_TOKEN"'
echo '       }'
echo '     }'
echo ""
echo "  4. Restart Claude Code"
echo ""

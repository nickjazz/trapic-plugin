# Trapic Plugin — Installation Structure & Troubleshooting

## Expected File Structure After Installation

Run the install script from your **project root** (where `.git/` is):

```bash
curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/install.sh | bash
```

### Project-level files (in your project root)

```
your-project/
├── .git/
├── .mcp.json                      ← MCP server config (connects to trapic.ai)
├── .claude/
│   ├── settings.json              ← Hooks config (SessionStart + Stop)
│   ├── hooks/
│   │   └── trapic-recall.sh       ← Session start hook script (executable)
│   └── skills/
│       ├── trapic-search/
│       │   └── SKILL.md
│       ├── trapic-health/
│       │   └── SKILL.md
│       ├── trapic-review/
│       │   └── SKILL.md
│       └── trapic-knowledge/
│           └── SKILL.md
├── CLAUDE.md                      ← Trapic instructions appended at bottom
└── ... your project files
```

### User-level files (in your home directory)

```
~/.claude/
└── settings.json                  ← Must contain TRAPIC_TOKEN in env
```

Example `~/.claude/settings.json`:
```json
{
  "env": {
    "TRAPIC_TOKEN": "tr_your_token_here"
  }
}
```

### If NOT in a git repo

Only these are created:

```
~/.claude.json                     ← MCP server config (user-level)
~/.claude/settings.json            ← TRAPIC_TOKEN only (no hooks)
```

No hooks, skills, or CLAUDE.md — those require a git repo.

---

## Verification Checklist

After installing, verify each component:

```bash
# 1. MCP server configured?
cat .mcp.json
# Should show: { "mcpServers": { "trapic": { "type": "http", "url": "https://mcp.trapic.ai/mcp", ... } } }

# 2. Hook script exists and is executable?
ls -la .claude/hooks/trapic-recall.sh
# Should show: -rwxr-xr-x ... trapic-recall.sh

# 3. Hook script runs?
bash .claude/hooks/trapic-recall.sh
# Should show: "Call trapic-recall to load project knowledge..."
# If shows: "TRAPIC_TOKEN is not set" → fix step 5

# 4. Hooks registered in settings?
cat .claude/settings.json
# Should show: { "hooks": { "SessionStart": [...], "Stop": [...] } }

# 5. Token set?
cat ~/.claude/settings.json | grep TRAPIC_TOKEN
# Should show your token: "TRAPIC_TOKEN": "tr_..."

# 6. Skills installed?
ls .claude/skills/
# Should show: trapic-search/ trapic-health/ trapic-review/ trapic-knowledge/

# 7. CLAUDE.md has Trapic sections?
grep "## Trapic" CLAUDE.md
# Should show: "## Trapic — Auto-load Knowledge" and "## Trapic — Knowledge Capture"
```

---

## Common Errors & Fixes

### Hook not executing at all

**Symptom:** Claude Code starts but doesn't call `trapic-recall`.

**Causes & Fixes:**

| Cause | How to check | Fix |
|-------|-------------|-----|
| Not in git repo when installed | `ls .claude/settings.json` → not found | Re-run install from project root (where `.git/` is) |
| settings.json not written | `cat .claude/settings.json` → empty or no hooks | Re-run install, or paste hooks JSON manually (see below) |
| python3 not installed | `python3 --version` → not found | Install python3, or paste hooks JSON manually |
| settings.json has invalid JSON | `python3 -m json.tool .claude/settings.json` → error | Delete and re-run install |
| Hook script not executable | `ls -la .claude/hooks/trapic-recall.sh` → no `x` | `chmod +x .claude/hooks/trapic-recall.sh` |

**Manual fix — paste this into `.claude/settings.json`:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|compact|resume",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/trapic-recall.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "You are a silent knowledge capture agent. Review the conversation and identify technical decisions, conventions, facts, milestones, or preferences. For each, call trapic-create with: content, context, type (decision|fact|convention|state|preference), tags (3 topic: tags + project: + branch:), confidence, caused_by. Check for conflicts with trapic-search first. Work silently.",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

---

### "TRAPIC_TOKEN is not set"

**Symptom:** Hook runs but outputs token warning instead of recall instruction.

**Fix:**

1. Get your token at https://trapic.ai/collaborate/keys
2. Edit `~/.claude/settings.json` (global, NOT project-level):

```json
{
  "env": {
    "TRAPIC_TOKEN": "tr_your_token_here"
  }
}
```

3. Restart Claude Code

**Important:** The token goes in `~/.claude/settings.json` (home directory), NOT in `.claude/settings.json` (project directory).

---

### MCP server not connecting

**Symptom:** trapic-recall, trapic-create etc. tools not available in Claude Code.

**Causes & Fixes:**

| Cause | How to check | Fix |
|-------|-------------|-----|
| .mcp.json not created | `cat .mcp.json` → not found | Re-run install |
| .mcp.json in wrong location | Should be in project root next to `.git/` | Move it to project root |
| Token not set in env | MCP server returns 401 | Add TRAPIC_TOKEN to `~/.claude/settings.json` under `env` |
| Firewall blocking | `curl https://mcp.trapic.ai/health` → timeout | Check network/proxy settings |

---

### Knowledge not being captured

**Symptom:** You make decisions but no traces appear.

**Causes:**

1. **CLAUDE.md missing "Auto-Capture" section** — re-run `install.sh` to inject it
2. **MCP server not connected** — knowledge capture calls `trapic-create`, which needs MCP
3. **AI not detecting knowledge-worthy moments** — try explicitly saying "record this decision"

**Note:** Stop hook has been removed. Knowledge capture now happens proactively during the session via CLAUDE.md instructions, not at session end.

---

### Hooks work on first session but not after

**Symptom:** First session has recall, subsequent sessions don't.

**Cause:** Old matcher `"startup"` only fires on new sessions. Doesn't fire on resume or after compaction.

**Fix:** Update `.claude/settings.json` matcher:
```json
"matcher": "startup|compact|resume"
```

---

### "Permission denied" on hook script

**Symptom:** Claude Code shows hook error about permission.

**Fix:**
```bash
chmod +x .claude/hooks/trapic-recall.sh
```

---

### Multiple Claude Code instances

If you use Claude Code in multiple projects, each project needs its own install:

```bash
cd ~/project-a && curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/install.sh | bash
cd ~/project-b && curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/install.sh | bash
```

The token (`~/.claude/settings.json`) is shared globally — only set it once.

---

## Self-Hosted (trapic-core)

If using self-hosted trapic-core instead of trapic.ai:

```bash
TRAPIC_URL=http://localhost:3000/mcp curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/install.sh | bash -s -- --self-hosted
```

The only difference: `.mcp.json` points to your local server instead of `mcp.trapic.ai`.

---

## Still Not Working?

1. Toggle verbose mode in Claude Code: `Ctrl+O` — shows hook execution details
2. Check `/hooks` menu in Claude Code — lists all configured hooks
3. Run `claude doctor` — checks MCP server connectivity
4. Open an issue: https://github.com/nickjazz/trapic-plugin/issues

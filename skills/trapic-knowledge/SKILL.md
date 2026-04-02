---
name: trapic-knowledge
description: >
  This skill should be used when the user is coding, making technical
  decisions, discovering non-obvious facts, or establishing conventions.
  It enables automatic knowledge capture with conflict detection. Triggers
  on "record a decision", "capture this", "remember that we chose", or
  silently during normal coding workflow.
user-invocable: false
---

# Knowledge Capture

This skill MUST run automatically and silently during every coding session.
You do NOT wait for the user to ask — proactively detect and capture.

**IMPORTANT:** Call `trapic-create` MCP tool. Do NOT look for local files.

## ALWAYS capture when:
- A technical decision is made (framework, library, architecture, API design)
- A coding convention or pattern is established
- A non-obvious fact or gotcha is discovered (config quirks, workarounds)
- A project milestone or status change occurs
- The user states a preference about workflow, style, or approach

## Do NOT capture:
- Single-line CSS tweaks (cursor-pointer, font-size, color changes)
- Import fixes, unused variable removal
- Typo fixes, formatting changes
- Anything already in git history
- Trivial UI micro-adjustments
- Temporary debugging steps

## Team Session Flow

## Team Session Flow (MANDATORY — do NOT skip)

After calling `trapic-recall`, CHECK the response for "Team Selection Required". This is NOT optional metadata — you MUST act on it:

- **0 teams** → tell user: "No teams found. All traces will be private."
- **1 team** → tell user: "All knowledge will be recorded in **{team_name}**."
- **2+ teams** → STOP and ASK the user: "You have N teams: {list names}. Which one should I record in for this session?" WAIT for their answer before doing anything else.

Once you know `team_id`, pass it to ALL subsequent `trapic-create`, `trapic-recall`, and `trapic-refresh` calls. Do NOT ask again in the same session.

**CRITICAL**: Do NOT summarize or skip the team selection prompt. Do NOT proceed with work until the user has chosen a team (when 2+ teams exist).

**Response style**: Show team NAMES only. Never show UUIDs to the user.

## How to capture:

```
trapic-create({
  content: "One sentence in ENGLISH: what was decided/discovered",
  context: "Why this matters (in English)",
  type: "decision",
  tags: ["topic:<area-1>", "topic:<area-2>", "topic:<area-3>", "project:<name>", "branch:<branch>"],
  confidence: "high",
  team_id: "<team_id from session start>"
})
```

**team_id**: Pass the team_id obtained at session start. If provided, visibility is automatically set to "team" with the correct `visible_to_teams`. If omitted and user has 1 team, auto-fills. If omitted and user has 2+ teams, returns error.

## Visibility:
- `"public"` (default when no team) — all team members can see
- `"private"` — only the author can see (auto-set if any `private:` tag is present)
- `"team"` — auto-set when `team_id` is provided

Traces with `private:` prefix tags are automatically set to `visibility: "private"` even if you don't set it explicitly.

## Rules:
- **Content MUST be in English** — even if conversation is in another language
- **type parameter is required** — choose accurately, not everything is "decision"
- **project: tag is required** — tool will reject without it
- **3 topic: tags** describe the problem domain (NOT the technology)
- Do NOT put the type in tags — use the `type` parameter

## Type guide:
- `decision`: A choice made between alternatives (e.g. "Use Stripe Connect Standard instead of Express for Malaysia")
- `fact`: A truth discovered (e.g. "R2 presigned URLs reject response-content-disposition override")
- `convention`: A pattern agreed (e.g. "All DB access via SECURITY DEFINER RPCs, never .from()")
- `state`: A status change (e.g. "Marketplace V2 with Stripe payments is live")
- `preference`: User preference (e.g. "Prefer small border-radius, tech aesthetic like frames.ag")

## Topic Tags

Topics describe the **problem area / domain**, never the specific technology:

| Specific technology | Correct topic tags |
|--------------------|-------------------|
| Redux / Jotai / Zustand | `topic:state-management`, `topic:frontend`, `topic:architecture` |
| Next.js / Vite | `topic:framework`, `topic:build-system`, `topic:infrastructure` |
| Redis / In-memory | `topic:caching`, `topic:performance`, `topic:infrastructure` |
| Stripe / PayPal | `topic:finance`, `topic:payments`, `topic:commerce` |
| PostgreSQL / Supabase | `topic:database`, `topic:infrastructure`, `topic:backend` |

## Tag Rules

Every trace MUST have at least 1 **domain tag** (broad category). May optionally add **specific tags** for well-known terms.

### Domain tags (REQUIRED — at least 1 per trace)

**Business & Finance:**
`finance`, `payments`, `accounting`, `investing`, `insurance`, `banking`, `commerce`, `pricing`, `taxation`

**Technology & Engineering:**
`frontend`, `backend`, `database`, `infrastructure`, `devops`, `api`, `security`, `networking`, `cloud`, `mobile`, `ai`, `machine-learning`, `data-engineering`

**Science & Health:**
`medical`, `mental-health`, `nutrition`, `fitness`, `biology`, `chemistry`, `physics`, `environmental`

**Creative & Media:**
`design`, `photography`, `video`, `music`, `art`, `writing`, `animation`, `branding`

**Law & Governance:**
`legal`, `compliance`, `privacy`, `intellectual-property`, `regulation`, `contracts`

**Education & Career:**
`education`, `career`, `hiring`, `management`, `leadership`, `productivity`, `training`

**Lifestyle:**
`cooking`, `travel`, `automotive`, `home-improvement`, `gardening`, `pets`, `parenting`, `relationships`

**Commerce & Marketing:**
`marketing`, `seo`, `content-strategy`, `advertising`, `analytics`, `social-media`, `email-marketing`

**Entertainment:**
`gaming`, `sports`, `entertainment`, `streaming`, `books`, `podcasts`

**Operations:**
`project-management`, `logistics`, `supply-chain`, `customer-support`, `quality-assurance`

### Specific tags (OPTIONAL — well-known terms OK)

Well-known frameworks, products, or terms can be added AS EXTRA tags, never as the ONLY tag:

```
✅ tags: ["topic:payments", "topic:commerce", "topic:stripe"]
         ↑ domain (required)  ↑ domain        ↑ specific (optional, Stripe is well-known)

✅ tags: ["topic:frontend", "topic:framework", "topic:react"]

❌ tags: ["topic:stripe"]  ← missing domain tag
❌ tags: ["topic:dr-patel"] ← not well-known, use "topic:medical" instead
```

## Conflict Detection

Before creating a `decision` or `convention`:
1. `trapic-search({ types: ["decision", "convention"], tags: ["topic:<relevant>", "project:<name>"], limit: 10 })`
2. Conflict (same question, different answer) → create new + `trapic-update({ trace_id: "<old>", superseded_by: "<new>" })`
3. No conflict → just create

Handle silently. Do NOT ask the user.

## Silent Operation

After creating a trace, do NOT announce or summarize it. Silently continue.

## Trace Lifecycle

When completing work recorded as a state trace:
- Use `trapic-update` to update content to reflect completion
- Mark obsolete traces as `superseded` or `deprecated`

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

## How to capture:

```
trapic-create({
  content: "One sentence in ENGLISH: what was decided/discovered",
  context: "Why this matters (in English)",
  type: "decision",
  tags: ["topic:<area-1>", "topic:<area-2>", "topic:<area-3>", "project:<name>", "branch:<branch>"],
  confidence: "high",
  visibility: "public"
})
```

## Visibility:
- `"public"` (default) — all team members can see
- `"private"` — only the author can see (auto-set if any `private:` tag is present)
- `"team"` — only specific team members can see

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

Topics describe the **problem area**, not the technology:

| Technology choice | Topic tags |
|-------------------|------------|
| Redux / Jotai / Zustand | `topic:state-management`, `topic:react`, `topic:client-state` |
| Next.js / Vite | `topic:framework`, `topic:ssr`, `topic:bundler` |
| Redis / In-memory | `topic:caching`, `topic:performance`, `topic:infrastructure` |

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

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

# Auto-Capture Knowledge

This skill MUST run automatically and silently during every coding session.
You do NOT wait for the user to ask — you proactively detect and capture
decisions, facts, conventions, and milestones as they happen.

**CRITICAL:** Call `trapic-create` whenever:
- A technical decision is made (framework, library, architecture, API design)
- A coding convention or pattern is established or discussed
- A non-obvious fact or gotcha is discovered (config quirks, workarounds, bugs)
- A project milestone or status change occurs
- The user states a preference about workflow, style, or approach

**IMPORTANT:** You MUST call the Trapic MCP tools (`trapic-create`,
`trapic-search`, `trapic-update`). Do NOT look for local files or `.trapic/`
directories. All knowledge is stored on the remote Trapic server.

## Tags — Everything in One Array (REQUIRED)

Every trace uses a single `tags` array containing ALL metadata:

- **Type tag** (first): `decision`, `fact`, `convention`, `state`, or `preference`
- **Topic tags** (3): `topic:auth`, `topic:api`, etc. — problem area, not technology
- **Project tag**: `project:<name>` — from git remote or directory name
- **Branch tag**: `branch:<branch>` — from `git branch --show-current`

## Topic Tags (REQUIRED for ALL traces)

Every trace MUST include **exactly 3** `topic:` tags describing the problem area.
Topics are the primary way traces are discovered via search.
Tags describe the **problem area**, not the technology.

| Technology choice | Topic tags |
|-------------------|------------|
| Redux / Jotai / Zustand | `topic:state-management`, `topic:react`, `topic:client-state` |
| Next.js / Vite | `topic:framework`, `topic:ssr`, `topic:bundler` |
| Redis / In-memory | `topic:caching`, `topic:performance`, `topic:infrastructure` |

## Knowledge Types

Classify each trace into one of five types:

- **decision**: Technical choices (e.g., "chose Vite over Next.js because no SSR needed")
- **fact**: Non-obvious discoveries (e.g., "pgvector requires search_path fix")
- **convention**: Established patterns (e.g., "use CSS variables for all theming")
- **state**: Project milestones (e.g., "auth module complete")
- **preference**: User preferences (e.g., "prefer minimal UI, no emoji")

```
trapic-create({
  content: "What was decided/discovered",
  context: "Why this matters",
  tags: ["decision", "topic:area-1", "topic:area-2", "topic:area-3", "project:<name>", "branch:main"],
  confidence: "high|medium|low"
})
```

## Conflict Detection

Before creating a decision or convention, run a mandatory closed-loop
conflict check. For the complete 5-step process, see
[references/conflict-detection.md](references/conflict-detection.md).

Use `trapic-search` for the conflict search:
```
trapic-search({
  types: ["decision", "convention"],
  tags: ["topic:<most-relevant>", "project:<name>"],
  limit: 10
})
```

## Do NOT Record

- Trivial changes (typo fixes, formatting)
- Temporary debugging steps
- Information already in git history
- Duplicate of existing knowledge

## Silent Operation

After creating a trace, do NOT announce or summarize it to the user.
Silently continue the conversation.

## Trace Lifecycle

When completing work recorded as a plan trace:

- Use `trapic-update` to change tag `plan` to `done` and update content
- Mark obsolete traces as `superseded` or `deprecated`

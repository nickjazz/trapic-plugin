---
name: trapic-pack-quality
description: >
  Use when creating marketplace pack content. Enforces AI-executable trace format.
  Every trace must change AI behavior, not just inform humans.
  Triggers on: creating packs, writing traces for marketplace, reviewing pack quality.
user-invocable: true
---

# Pack Content Quality Standard

Trapic marketplace packs are consumed by AI agents, not read by humans.
Every trace must be an **executable instruction** that changes AI behavior immediately.

## The Golden Rule

> "If an AI reads this trace and cannot immediately change its behavior, the trace has no value."

## Format: AI-Executable Trace

Every trace MUST follow this structure:

```
CONTENT: [WHEN condition] → [DO action] → [BECAUSE reason]
CONTEXT: [SPECIFIC example or template the AI can copy-paste]
```

### ✅ Correct Examples

```
CONTENT: "When writing error messages, use this 3-part template: (1) What happened — no blame, passive voice. (2) Why — only if not obvious. (3) Next step — specific action with button/link."
CONTEXT: "Template: 'Your file could not be uploaded. It exceeds the 10MB limit. Try compressing the image or choose a smaller file.' Never use: 'Error:', 'Failed:', 'Invalid'. Never blame: 'You entered wrong...' → 'This doesn't look like a valid...'"

CONTENT: "When adding React.memo, first verify: (1) component has >50 DOM nodes, (2) re-renders >5x/sec with same props. If BOTH false, do not memo. If true, wrap and add comment explaining why."
CONTEXT: "// Performance: ProductCard has 80+ DOM nodes, re-renders on every scroll event with same props\nexport const ProductCard = React.memo(function ProductCard({...}) { ... })"

CONTENT: "When a user asks to write marketing copy, set tone to: contractions YES, reading level 7th grade, active voice, second person (you), no superlatives without evidence."
CONTEXT: "Bad: 'We are excited to announce our revolutionary best-in-class solution.' Good: 'You can now deploy in 3 clicks. No config needed.' Rules: max 8 words per headline, max 3 lines per paragraph."
```

### ❌ Wrong Examples (Knowledge, Not Instruction)

```
❌ "React.memo adds 2-5% overhead on first render and saves 15-60% on re-renders."
   → AI reads this and thinks "interesting" but does nothing different.

❌ "Mailchimp's voice redesign correlated with 25% conversion increase."
   → This is a fact about Mailchimp. AI cannot act on it.

❌ "Chain-of-thought prompting improves accuracy 4-13%."
   → AI already knows how to reason. This doesn't change its behavior.
```

## Trace Type Guide for Packs

| Type | When to use | AI behavior change |
|------|------------|-------------------|
| **convention** | Reusable rule/template | AI follows this pattern every time the condition is met |
| **decision** | When to use X vs Y | AI makes the correct choice at decision points |
| **fact** | Only if it changes a decision | AI avoids a common mistake or chooses correctly |
| **preference** | Style/approach preference | AI matches the preferred style |

**90%+ of pack traces should be `convention`** — they are the most actionable.

## Content Checklist

Before adding a trace to a pack, verify:

- [ ] **Trigger:** Does it have a clear WHEN condition? ("When writing error messages...", "When the list has >200 items...")
- [ ] **Action:** Does it tell AI exactly WHAT to do? (template, code snippet, specific steps)
- [ ] **Anti-pattern:** Does it show what NOT to do with a concrete bad example?
- [ ] **Copy-paste ready:** Can AI directly use the template/code/format in the context field?
- [ ] **Standalone:** Does it make sense without reading other traces?

## Context Field: Templates > Explanations

The `context` field should contain **copy-paste ready material**, not explanations:

```
✅ Context as template:
"Template: <Button variant='primary' size='md'>{label}</Button>
 Never: <Button className='btn-primary btn-md'> (don't use className for variants)"

✅ Context as checklist:
"Pre-commit check: (1) No hardcoded colors — use var(--color-*), (2) No px values for spacing — use space-* tokens, (3) No inline styles — use Tailwind classes"

❌ Context as explanation:
"This is important because design systems need consistency and hardcoded values make it harder to maintain themes across the application."
```

## Pack-Level Quality

A complete pack should:

1. **Cover all decision points** in the domain — not just "best practices" but "when X, do Y; when Z, do W"
2. **Include anti-patterns** — "never do this" is as valuable as "always do this"
3. **Be self-contained** — AI should not need external docs after installing the pack
4. **Have consistent granularity** — each trace covers ONE decision, not a chapter

## Example: Converting a Knowledge Trace to AI-Executable

BEFORE (knowledge):
```
content: "Virtual list rendering reduces render time from 3.2s to 28ms for 10,000 rows."
context: "react-window is 6KB, react-virtuoso is 16KB."
```

AFTER (executable):
```
content: "When rendering a scrollable list with >200 items, use virtual rendering. Choose: react-window (6KB, fixed height rows) or react-virtuoso (16KB, dynamic heights). Never render >200 DOM nodes in a list."
context: "import { FixedSizeList } from 'react-window';\n<FixedSizeList height={400} itemCount={items.length} itemSize={48} width='100%'>\n  {({ index, style }) => <Row style={style} data={items[index]} />}\n</FixedSizeList>\n\nDo NOT use if: list has <200 items (overhead not worth it), or items need complex layout (use pagination instead)."
```

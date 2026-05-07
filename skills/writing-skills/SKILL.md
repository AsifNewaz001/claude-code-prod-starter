---
name: writing-skills
description: Authoring or editing a skill for this plugin. Use when a recurring workflow keeps coming up across sessions and deserves to be packaged so Claude follows it consistently. Skills encode processes, not facts.
license: MIT
---

# Writing Skills

## Overview

A skill is a packaged workflow. It tells Claude *how* to do something — the process, the red flags, the verification step. Not *what* the codebase looks like (that's `CLAUDE.md`); not *what* a feature should do (that's a spec).

Use this skill when adding a new SKILL.md to this plugin or significantly editing an existing one.

## When to use

- A workflow keeps coming up across multiple sessions
- You want Claude to follow a specific process consistently
- You're encoding a hard-won lesson (a past incident, a recurring failure mode)
- You're documenting a quality gate that should be enforced before merge

## When NOT to write a skill

- The thing is project-specific (put it in `CLAUDE.md` / `AGENTS.md` / `PROJECT_CONTEXT.md`)
- The thing is a fact, not a process (put it in a doc)
- The thing is a one-off you'll do once and forget — not worth the file
- A skill already exists that covers it (extend the existing one instead)

## Anatomy of a good skill

Every SKILL.md in this plugin follows the same shape:

```
---
name: <skill-name (kebab-case, matches directory)>
description: <one-line WHAT, then "Use when…" trigger conditions>
license: MIT
---

# <Skill Name>

## Overview
2–4 sentences. What this skill is and why it exists.

## When to use
Bullet list of triggers. Concrete situations.

## (Optional) When NOT to use
Just as important — when this skill is the wrong tool.

## Process / Iron Law / The Cycle
The actual workflow. Numbered steps or a clear loop.

## Red flags
A table. Thoughts that mean STOP. Each row is a rationalization → reality.

## Common rationalizations
Counter-arguments to the most common excuses for skipping the skill.

## Verification
How you (the agent) know the skill was followed. Concrete, observable.
```

## The frontmatter

- `name`: kebab-case. Must match the directory: `skills/<name>/SKILL.md`.
- `description`: starts with what the skill does in third person, then "Use when…" with concrete triggers. This is what Claude scans to decide whether to invoke the skill — be specific, not vague.
- `license`: MIT (matches the plugin).

**Bad description:** *"Helps with testing."*
**Good description:** *"Drives development with a failing test first. Use when implementing any new logic, fixing any bug, or modifying behavior. Tests ship in the same commit as code — never 'tests later.'"*

The description is your activation contract. Vague descriptions fail to trigger; specific ones trigger reliably.

## Iron rules for skill content

1. **State an Iron Law if there is one.** If the skill has a non-negotiable rule, write it as one — bold, in a code block, near the top. *"NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST."*
2. **Include red flags.** A table of rationalizations → realities. These prevent agents from skipping the skill mid-task.
3. **Include verification.** A skill without a verification step is advice, not a workflow.
4. **Be concrete.** Bullet "things to think about" is dead weight. Bullet "things to do" is alive.
5. **Cite a related skill, don't duplicate.** If your skill needs TDD, *reference* `test-driven-development`, don't restate it.

## Length

100–200 lines is the sweet spot. Longer skills get skipped. Shorter ones are usually too vague.

If you have more than ~200 lines of content, split into:
- The SKILL.md (the workflow)
- A `references/` subdirectory inside the skill folder (checklists, examples, edge-case catalogs)

## Where to put supporting material

- One-line examples → inline in the SKILL.md
- Multi-line examples → inline if ≤20 lines, else `examples/`
- Long checklists or reference tables → `references/`
- Scripts the skill runs → `scripts/`

## Red flags — these thoughts mean STOP

| Thought | Reality |
|---|---|
| "I'll write a skill for this someday" | Write it now or don't bother — half-written skills confuse Claude. |
| "This skill is too detailed" | Detail is the point. Vague skills don't trigger and don't change behavior. |
| "I'll skip the verification section" | Then it's advice, not a skill. Add it. |
| "I'll put project-specific stuff in here" | No. That belongs in `CLAUDE.md` / `PROJECT_CONTEXT.md`. Skills are project-agnostic. |
| "I'll combine three workflows in one skill" | Each skill does one thing. Split them. |

## Common rationalizations

- *"The description doesn't matter, the body is what counts."* — Wrong. The description is what Claude scans during dispatch. A bad description means the skill never gets invoked, no matter how good the body is.
- *"Red flags / rationalizations sections are filler."* — They're the most-read sections in practice. Agents *will* try to rationalize skipping the skill. Write the counter-arguments in advance.
- *"Verification is obvious."* — If you don't write it, it gets skipped. Write it.

## After writing

1. Add the skill directory: `skills/<name>/SKILL.md`.
2. Add a one-line entry in `using-prod-starter` SKILL.md under "Skill list."
3. If the skill maps to a slash command, link them in both directions.
4. Bump the plugin's `version` in `.claude-plugin/plugin.json` (semver: minor for new skill, patch for edit).
5. Add a CHANGELOG entry.

## Verification

- Frontmatter has `name`, `description`, `license`.
- Description is one sentence + "Use when…" specific triggers.
- Body has Overview, When to use, Process, Red flags, Verification.
- The skill is added to `using-prod-starter`'s skill list.
- The plugin version is bumped.

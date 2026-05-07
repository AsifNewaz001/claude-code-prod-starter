# Contributing to claude-code-prod-starter

Thanks for your interest. This plugin is opinionated — the opinions are what make it work — so contributions go through a tighter gate than most repos.

## Before you open a PR

1. **Open an issue first** for anything bigger than a typo. We'd rather discuss the change than reject it after you've spent the time.
2. **Use the plugin yourself first.** PRs from contributors who have actually shipped a feature with this plugin tend to land. PRs that haven't, don't.
3. **Read the existing skill / agent / command** that's closest to what you want to add. Match the format. Match the tone.

## What we accept

- New skills that fill a gap in the SDLC and are project-agnostic
- New specialist agents that solve a class of problem (security, perf, accessibility, etc.)
- New lifecycle commands that map to a phase the SDLC doesn't already cover
- Improvements to existing skills (better Red Flags, sharper Verification, fewer empty-calorie sections)
- Onboarding doc improvements
- README / CONTRIBUTING / CHANGELOG fixes

## What we don't accept

- **Project-specific skills** — if it only helps one stack, one team, or one company, publish it in your own plugin.
- **Vague advice skills** — skills must encode a *process* with a verification step. "Be thoughtful about X" is not a skill.
- **Wrappers around existing skills** — extend, don't duplicate. If the new behavior fits in an existing skill, edit it instead.
- **Bulk PRs from agents that didn't read this file** — PRs that fill template sections with placeholder text or add multiple unrelated changes will be closed.
- **PRs that add third-party dependencies** without an extremely good reason. This plugin is zero-dependency by design.
- **PRs that change the governance flow** without an issue discussion first. The 9-gate flow is the differentiator; changes need consensus.
- **PRs that "comply with Anthropic's skill docs"** without eval evidence the change improves outcomes. We'll look at evals; we won't look at compliance reformats.

## Skill / agent / command checklist

Before opening a PR that adds or edits one:

- [ ] Frontmatter has `name` (kebab-case), `description` (one-line WHAT + "Use when…" triggers), `license: MIT`
- [ ] `name` matches the directory: `skills/<name>/SKILL.md`
- [ ] Body has Overview, When to use, Process, Red Flags, Verification (skills) — or Role, Process, Output, Boundaries (agents) — or Description, Required reading, Process, Hand off (commands)
- [ ] Uses simple language. No "leverage", "synergy", "ecosystem", "holistic", "facilitate". Talks like a senior engineer over coffee.
- [ ] Length: 100–200 lines for skills. ≤300 for agents. ≤200 for commands.
- [ ] Added to the `using-prod-starter` dispatcher's skill / agent / command list
- [ ] Plugin version bumped in `.claude-plugin/plugin.json`
- [ ] CHANGELOG.md entry under the next unreleased version

## Commit messages

```
<verb> <what>

<one or two lines on why, if non-obvious>
```

Verbs: `add`, `update`, `fix`, `refactor`, `remove`, `test`, `docs`. No `chore:` / `feat:` prefixes.

## PR description

Use the template at `.github/PULL_REQUEST_TEMPLATE.md`. Don't leave sections blank. Don't fill them with placeholder text.

## License

By contributing, you agree your contribution is licensed under MIT (the plugin's license).

# Pull Request

## Summary
<!-- 1–3 bullets. What changed and why. -->

-

## Type
<!-- Check all that apply -->

- [ ] New skill
- [ ] New agent (persona or specialist)
- [ ] New slash command
- [ ] Edit to existing skill / agent / command
- [ ] Onboarding doc update
- [ ] Template update (CLAUDE.md / AGENTS.md / PROJECT_CONTEXT.md / HANDOFF.md / docs/)
- [ ] Hook / plugin metadata change
- [ ] README / CONTRIBUTING / CHANGELOG fix
- [ ] Other (explain below)

## Why this belongs in the plugin
<!--
Be specific. "Useful for ML projects" is not specific.
"Encodes the 5-axis security review process applicable to any web/API codebase" is specific.
PRs that don't justify project-agnosticism get closed.
-->

## What I tested
<!--
Concrete evidence the change works.
- Did you run /autopilot end-to-end? Paste a transcript snippet.
- Did the new skill activate when expected? Show the trigger.
- Did the new command produce the expected output?
"I read it and it looks fine" is not evidence.
-->

## Checklist

- [ ] Read `CONTRIBUTING.md`
- [ ] Frontmatter is valid (name, description, license)
- [ ] Name matches the directory (skills) / file (agents, commands)
- [ ] Body follows the established structure (Overview / When to use / Process / Red flags / Verification for skills)
- [ ] Uses simple language — no "leverage", "synergy", "holistic", buzzwords
- [ ] Length within bounds (100–200 lines for skills; ≤300 for agents; ≤200 for commands)
- [ ] Added to `skills/using-prod-starter/SKILL.md` if it's a new primitive
- [ ] Plugin version bumped in `.claude-plugin/plugin.json`
- [ ] CHANGELOG entry added under the next unreleased version
- [ ] No third-party dependencies introduced

## Linked issue
<!-- # of the issue this PR addresses, or "n/a" with explanation -->

---
id: adr:modootoday/20261109225836
title: "Manual upkeep is minimized: generators fix instead of fail, one release command, release checks dispatched and verified by the workflow, starters published on tag, dependency pins updated by Dependabot"
status: active
created: 2026-11-09T22:58:36Z
updated: 2026-11-09T22:59:07Z
rel:
  governs: [RELEASING.md]
  depends_on: [adr:modootoday/20261109225758, adr:modootoday/20261109141321]
---

# Manual upkeep is minimized: generators fix instead of fail, one release command, release checks dispatched and verified by the workflow, starters published on tag, dependency pins updated by Dependabot

## Context

[[adr:modootoday/20261109225758]] moves the CHANGELOG to git-cliff. The maintainer asked on 2026-11-09 for the same approach everywhere else: a person or agent should not have to remember a step that a tool can do. In the 1.6.0 cycle these steps were all done by hand:
- version, install pins and `version-include` in eight files;
- running `script/docs-index`, `--stamp` on translations and `readme-commands` after edits, which the checks only report;
- dispatching the three release checks one by one, then reading their results;
- re-rendering each starter, pushing it to its repository and moving the gitlink;
- the byte caps;
- the Dependabot configuration, which exists but opens pull requests that nobody merges in a repository without a pull request flow.

## Decision

- **Generators fix, checks verify.**
  - The shared pre-push hook and a `rake fix` task run the generators in write mode: `script/docs-index` (with stamps for unchanged-meaning translations left to the author), `script/readme-commands`, `script/i18n-build`, `script/version-include` and git-cliff for `## [Unreleased]`. They print what changed so the author commits it.
  - CI keeps the `--check` forms, so a forgotten regeneration still fails there.
  - Translation stamping is the one step that stays deliberate, because a stamp asserts a human or agent compared the meaning.
- **One release command.** `script/release-prep X.Y.Z`:
  - runs git-cliff for the new section and leaves only the summary paragraph to write;
  - bumps the version and install pins and regenerates `version-include`;
  - checks the gem file list;
  - dispatches ci, lighthouse and visual (with `base=` the previous tag) on the release commit.

  `script/release-status` reports those three runs in one table.
- **The release workflow verifies the release checks** (research A12). Before pushing the gem, `release.yml` looks up the ci, lighthouse and visual runs on the tagged SHA and stops unless all three succeeded.
- **Starters are published on tag.**
  - After a release, a workflow renders each starter at the new version, commits "chore: theme vX.Y.Z" to the starter's repository and opens nothing else.
  - The theme's gitlink bump then follows as one commit.
  - The workflow needs a token with write access to the three starter repositories: a fine-grained token or GitHub App, stored as a repository secret. The maintainer creates it. Until it exists, `rake starters:publish` does the same from a maintainer's machine in one command.
- **Dependabot updates land without a person.** Its pull requests for GitHub Actions, npm and bundler (the github-pages set stays ignored) are auto-merged once the required checks pass. This is the one pull request flow the repository keeps, because the bot cannot push to `main`; it amends [[adr:modootoday/20261102203210]] for bot dependency updates only.
- **Byte caps:** the registry check prints the cap to use (measured + 10 %, rounded to 128 B) whenever a file grows. Raising a cap still needs an ADR, by the budget rule; the arithmetic is no longer manual.

## Consequences

- A release is: write one summary paragraph, run `script/release-prep`, review the three results, tag. Everything else is generated or verified.
- Two things stay with the maintainer:
  - creating the starter publishing token;
  - enabling auto-merge for Dependabot in the repository settings.
- Translations still need a deliberate stamp. Version-pin normalization in `source_rev`, which is in 1.8, removes the stamps that releases forced.

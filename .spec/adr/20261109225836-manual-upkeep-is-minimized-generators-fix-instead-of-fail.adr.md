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
- **Starters update themselves; no token is stored anywhere.** A workflow's `GITHUB_TOKEN` can write only to its own repository, and a pushed token or App key is a long-lived secret. So the flow is pull-based (amended 2026-11-09, maintainer's request for a tokenless setup):
  - Each starter repository runs an updater workflow, daily and on `workflow_dispatch`. It reads the theme's latest release from the public API with no token. If it is newer than the starter's pin, it checks out the public theme at that tag, re-renders the starter with `rake starters:render[NAME,DIR]`, commits "chore: theme vX.Y.Z" with its own `GITHUB_TOKEN` (`contents: write`), and builds and deploys its Pages site in the same workflow, because a `GITHUB_TOKEN` push starts no other workflow.
  - The updater runs only in the starter's own repository (`if: github.repository == '<starter repo>'`, like the demo overlay), so a site made from the template never rewrites itself. Template users keep pinning by hand or opt in later (1.8 R7).
  - The theme repository runs a gitlink workflow, daily and on `workflow_dispatch`. It reads the starters' public `main`, moves `example/<name>` to the new commits with its own `GITHUB_TOKEN`, and runs the starter checks in the same workflow.
  - A release lands in the starters within a day; a manual `workflow_dispatch` makes it immediate. `rake starters:publish` stays as the local fallback.
- **Dependabot updates land without a person.** Its pull requests for GitHub Actions, npm and bundler (the github-pages set stays ignored) are squash-merged by a workflow (`workflow_run` after CI and Starters) once every run on the head commit has succeeded, with the repository's own token. GitHub's auto-merge is not used: it needs required status checks on `main`, which would also block the direct pushes this repository relies on. This is the one pull request flow the repository keeps, because the bot cannot push to `main`; it amends [[adr:modootoday/20261102203210]] for bot dependency updates only.
- **Byte caps:** the registry check prints the cap to use (measured + 10 %, rounded to 128 B) whenever a file grows. Raising a cap still needs an ADR, by the budget rule; the arithmetic is no longer manual.

## Consequences

- A release is: write one summary paragraph, run `script/release-prep`, review the three results, tag. Everything else is generated or verified.
- Nothing stays with the maintainer to set up: no token, no secret, no repository setting.
- Translations still need a deliberate stamp. Version-pin normalization in `source_rev`, which is in 1.8, removes the stamps that releases forced.

---
id: adr:modootoday/20261110020841
title: "Dependabot waits two weeks, leaves the Pages-mimicking dev pins alone, and merges on the latest run of every pull request workflow"
status: active
created: 2026-11-10T02:08:41Z
updated: 2026-11-10T02:10:53Z
rel:
  governs: [.github/dependabot.yml, .github/workflows/dependabot-auto-merge.yml]
  depends_on: [adr:modootoday/20261109225836, adr:modootoday/20261105101229]
---

# Dependabot waits two weeks, leaves the Pages-mimicking dev pins alone, and merges on the latest run of every pull request workflow

## Context

[[adr:modootoday/20261109225836]] lets a workflow squash-merge Dependabot's pull requests once every run on the head commit has succeeded, triggered after CI and Starters. Three gaps showed up:

- The workflow started only after CI and Starters, so Lighthouse, Visual regression and Figures could still be running, or have failed, when it merged. It also read every run on the head commit: a label event starts a second Visual run that cancels the first, and the cancelled run blocked the merge for good.
- Dependabot proposed a release on the day it came out, while [[adr:modootoday/20261105101229]] pins dependencies at the newest release older than two weeks.
- `jekyll-titles-from-headings` and `jekyll-optional-front-matter` are pinned in the development Gemfiles to mimic GitHub Pages, which supplies its own versions on the real build. Raising them would test a set Pages never runs.

## Decision

- **Trigger:** `workflow_run` on completion of every workflow that runs on `pull_request`. `test/release/dependabot_test.rb` reads `.github/workflows/` and fails when one is missing from the list, so a new workflow cannot be forgotten.
- **Merge rule:** for the head commit, take the newest run (highest run number) of each workflow started by a pull request event. Merge only when each of those is completed with `success` or `skipped`; any queued, in-progress or failed one leaves the pull request open until the next completion event. A workflow whose path filter skipped the pull request has no run and does not count. The merge keeps `--match-head-commit` and the repository guard.
- **Cooldown:** `cooldown: {default-days: 14}` on the npm, bundler and github-actions entries, so Dependabot proposes only releases at least two weeks old, the practice of 20261105101229.
- **Ignored:** `jekyll-titles-from-headings` and `jekyll-optional-front-matter`, beside the GitHub Pages set (`github-pages`, `nokogiri`) that was already ignored.

## Consequences

- A merge made with `GITHUB_TOKEN` starts no workflow, so the push workflows on `main` do not run for it until the next push or a manual dispatch.
- A pull request that edits `.github/workflows/` (a GitHub Actions update) may be refused, because `GITHUB_TOKEN` cannot be granted the `workflows` permission; a person merges it once its checks pass. RELEASING, "Dependency updates", lists both cases.
- The two ignored plugins move only when a person updates them to the versions GitHub Pages runs.

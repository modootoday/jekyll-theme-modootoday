---
id: adr:modootoday/20261111011655
title: "Sites rebuild on a published release and, when they opt in, weekly; readers learn of updates through pull channels"
status: active
created: 2026-11-11T01:16:54Z
updated: 2026-11-11T01:36:53Z
rel:
  governs: [script/starters/templates/pages.yml.erb, docs/recipes/updates.md]
  depends_on: [adr:modootoday/20261109141321, adr:modootoday/20261109225836]
---

# Sites rebuild on a published release and, when they opt in, weekly; readers learn of updates through pull channels

## Context

[[adr:modootoday/20261109141321]] puts R6, G6 and F10 into 1.7.0. GitHub Pages builds on a push, so data a build reads from GitHub (`site.github` releases and repository details) stays as it was at the last push; publishing a release does not rebuild a site. A `release` event runs on the release's tag, and GitHub recommends that only the default branch may deploy to the `github-pages` environment, so a Pages workflow that simply adds the trigger fails at its deploy step or, without that rule, deploys the tag's tree instead of the branch. Scheduled workflows in public repositories are turned off after 60 days without activity. The theme sends nothing anywhere and has no server, so it cannot offer push notifications.

## Decision

- **Release: rebuild the default branch.** The starters' `pages.yml` gains `release: {types: [published]}`. On that event a `rebuild` job (permission `actions: write`) runs `gh workflow run pages.yml --ref <default branch>` with `GITHUB_TOKEN`, which may start a `workflow_dispatch` run, and the build and deploy jobs are skipped on the tag. No stored token is added.
- **Schedule: opt-in.** The weekly trigger is in the template as a commented `schedule` block with the 60-day note. Starter content reads no GitHub data today, and a scheduled run per starter per week would deploy unchanged demos.
- **The recipe "Tell readers about updates" (F10).** It lists the pull channels (the Atom feed per language and GitHub's `releases.atom`, Watch, Custom, Releases on GitHub, the `c: subscribe` form with a mail service, the installed app's update notice), the release and scheduled triggers for custom workflows, and why the theme ships no push: a push needs a server that keeps every subscription, a permission prompt and a third-party push service.
- **Starters.** The template change reaches each published starter's work tree through `rake starters:render[NAME]` and a commit in its repository, then the gitlink in `example/` moves (CONTRIBUTING, Starter sites).

## Consequences

- A starter site, or a site made from one, shows release data that is current within minutes of publishing a release. A tag run shows as a short `rebuild` job and a second run on the default branch.
- A site built from a branch has no workflow; the recipe says to push or to switch the Pages source to GitHub Actions.
- 0 bytes of CSS and JavaScript.

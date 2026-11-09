---
id: adr:modootoday/20261109141321
title: "1.7.0 adds the feature extensions the 1.7 research recommends, alongside the PWA items"
status: active
created: 2026-11-09T14:13:21Z
updated: 2026-11-09T15:00:53Z
rel:
  governs: [_layouts]
  depends_on: [research:modootoday/20261109141301, research:modootoday/20261109150011]
---

# 1.7.0 adds the feature extensions the 1.7 research recommends, alongside the PWA items

## Context

1.7.0 was planned as the installable, offline-capable release: a web app manifest, a service worker with a kill switch, offline and update QA fixtures, an update notice, an install section and the docs turning it on, plus event ticket price keys and a canonical component order. [[research:modootoday/20261109141301]] surveyed ten comparable themes and frameworks, browser notifications and push, GitHub's public surfaces and GitHub Releases, and sorted about fifty ideas into 1.7, later and rejected. The maintainer decided on 2026-11-09 that 1.7.0 takes every item the research proposes for 1.7, including the ones it lists as "if capacity remains".

## Decision

1.7.0 adds, all opt-in and with nothing in the core sheet:

- **E1** An installed app checks for a new version when its window becomes visible again, at most hourly; part of the update notice item.
- **A1** Heading anchor links with no script, in a new context sheet.
- **G1** `edit_url: auto` builds the "Edit this page" link from `site.github`.
- **G2, C3, G8** Page footer links: a prefilled "Report an issue", "Was this page helpful?" as two prefilled links, and an optional "Discuss" link. No script and no analytics.
- **F6** Feed discovery links and a Subscribe link on tag, category, author and blog pages.
- **F7, R4** An Atom feed from the `changelog` layout, and the repository's `releases.atom` as an alternate link.
- **A12, A13** The diagram follow-ups the 1.6.0 audit deferred: a per-diagram minimum width as fixed classes (no inline style under a strict CSP), and one SVG pair per language.
- **R6, G6, F10** Starters rebuild on a published release and, optionally, on a schedule; a recipe tells readers about updates through feeds, watching releases, a mail form and the update notice, and says why the theme ships no push.
- **A5** An opt-in print stylesheet loaded with `media="print"` that hides the update notice and the install section.
- **J2** Open Graph image alt text, size and a fallback image.
- **G3** A link to the commit the site was built from.
- **R2** A latest-release banner built at build time.
- **L1** An internal link and anchor check in `modootoday-check`.
- **E3** An offline notice through the update notice's toast.
- **E9** Manifest shortcuts and screenshots.

Each item gets its own registry row or a row in an existing context sheet, its cap measured +10 % rounded up to 128 B ([[adr:modootoday/20261104053146]]), its labels in every catalog, and docs in en, ko and ja. Before G1, G2, R2 and the 1.8 release surfaces, a spike records what `site.github` returns on github-pages 232; before A1, how kramdown writes CJK and RTL heading ids on Jekyll 3.10 and 4; before A5, which `@media print` rules exist.

Not in 1.7.0: the release surfaces (a releases page and download tables from GitHub Releases) lead 1.8; last-updated dates, outdated-translation notices, code line highlighting, search to headings, click-to-load comments, contributors, repository stats and image zoom are 1.8; versioned docs, attestation display, a command palette and web push are 1.9 or later. Web push stays a recipe: GitHub Pages cannot receive subscriptions or hold a VAPID private key, and keeping subscriptions in a repository would publish device endpoints.

## Consequences

- 1.7.0 grows by about fifteen small items; the release procedure (visual review of every component example, a usability audit from the public docs, the three release checks) covers them all.
- Footer links and feeds give readers who do not install the app a way to hear about changes with no server and no third-party request.
- The items rejected in the research (a local notification on update, the Badging API alone, polling a version file, fetching `releases.atom` in the browser, `<picture>` dark images, custom alert types, theme-rendered CI badges) stay out unless a later ADR revisits them.

## Amendment (2026-11-09): governance, docs drift and changelog work lands first

The maintainer decided on 2026-11-09 that 1.7.0 and 1.8.0 each take the governance, docs-drift and changelog items [[research:modootoday/20261109150011]] assigns to them. In the 1.6.0 cycle, broken anchors, banned wording, a sidebar over its cap and audit races reached the release check together, because the docs checks ran only on manual dispatch. The changelog and install pins were also edited by hand up to the tag. These items land at the start of the 1.7 cycle, before the feature items, so each later push is held to them.

- **Wave 0, with no ADR beyond this record:**
  - **B1** The docs structure and kitchen-sink coverage checks run in `rake test`.
  - **C1** A CHANGELOG lint covers sections and their order, dates, links, the `Visual:` line, ADR ids, no internal names, and released entries unchanged against their tag.
  - **A6** Every cited `adr:`, `audit:` and `research:` id resolves.
  - **B4** The dispatchable QA workflows have concurrency groups.
  - **A1, A2** A public root `AGENTS.md` (with `CLAUDE.md` importing it) and a drift test.
  - **A5** CONTRIBUTING gets "Decisions" and "Definition of done" sections.
  - **A4** An opt-in shared pre-push hook, under 30 s.
- **Wave 1, each item behind its own ADR:**
  - **C2, C3** One changelog fragment per change under `changes/`, and a check that a user-facing commit ships one or says `Changelog: none`.
  - **B2** A path-filtered docs job on push with no browser: links and anchors, examples, the checker, a staleness summary.
  - **B3, B14** A nightly full QA with one rolling issue, and a weekly external-link check.
  - **A12** The release workflow verifies the three release checks on the tagged commit.
  - **A9, A10** `spec check` and a wider public-surface guard run in CI.
  - **A7** Limit and exception constants cite an ADR.
- **Wave 2, with the feature work, before the release check:**
  - **C4, C5** `script/changelog` and `script/release-prep` (fragments compiled, the `Visual:` line drafted, install pins and version written), used for 1.7.0 itself.
  - **B5** A releases data file and a generated docs Changelog page, together with F7 and R4.
  - **B6** A Roadmap page with no frozen version.
  - **B7** A test that every configuration key is documented.
  - **B11** A report-only translation staleness summary.
  - **B15** The list of docs pages changed since the last tag, for the usability audit.
  - **A3** `AGENTS.md` for `docs/` and the assets.
  - **A11** A refreshed pull request template.
  - **C7** A richer GitHub Release body, if time remains.

Rejected in the research and kept out:
- release-please, release-drafter, the changesets bot and GitHub's generated notes, which all need pull requests;
- towncrier and changie, which add a Python or Go toolchain (their fragment design is borrowed instead);
- required status checks on `main`, which contradict direct-to-main;
- CODEOWNERS while there is one maintainer;
- Copilot instruction copies;
- browser audits on every push;
- prose linters for now;
- a hosted translation platform;
- commit trailers as the changelog source.

The coordinator's private brief and delegation protocol stay out of the public repository; `AGENTS.md` carries only the generic rules.

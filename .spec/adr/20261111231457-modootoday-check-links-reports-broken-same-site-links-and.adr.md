---
id: adr:modootoday/20261111231457
title: modootoday-check --links reports broken same-site links and anchors as warnings
status: active
created: 2026-11-11T23:14:57Z
updated: 2026-11-11T23:16:55Z
rel:
  governs: [lib/modootoday/check/build/links.rb, test/system/docs/links.rb]
  depends_on: [adr:modootoday/20261109141321]
---

# modootoday-check --links reports broken same-site links and anchors as warnings

## Context

L1 in [[adr:modootoday/20261109141321]]: the theme's own docs had an internal link and anchor check (`test/system/docs/links.rb`, run by the docs QA job), but a site built on the theme had none, so a renamed page or heading broke links silently.

## Decision

- `modootoday-check SRC SITE --links` checks the built HTML: every same-site `a href`, `link href`, `img src`, `script src` and first `source srcset` URL must name a file that exists (as the file, its `index.html` or `.html`), and a `#fragment` must match an `id` or `a[name]` on the target HTML page, compared after percent-decoding so CJK heading ids work. Paths resolve against `baseurl` from `_config.yml`; a link outside it is reported. Query strings are ignored. External URLs are never fetched.
- Findings are warnings; `--strict` turns them into failures, as for every other warning. Sites adopt it without a red build on day one.
- Scope is the built site only: Markdown twins and alias pages are files like any other, so a link to them passes when they were built.
- One owner: the scan lives in `lib/modootoday/check/build/links.rb` (Nokogiri, which the checker already uses for built parts; without it `--links` is an error that names the gem and fails the run, so an asked-for check never passes unchecked; changed after m3 of [[audit:modootoday/20261113044135]]). `test/system/docs/links.rb` calls that scan, keeps only the docs rule that the header brand link goes to the page's language home, and fails on any problem, so the docs QA job stays strict without turning the docs check's other warnings into failures. Its output on the built docs site is identical to the old script's.

## Consequences

- New option row in the checker's `OPTIONS`, so the README command tables and the Command line reference pages are regenerated from it.
- `test/checker/build/links_test.rb`: missing page, missing anchor, percent-encoded CJK anchor and `a[name]`, query and same-page fragment, outside `baseurl` and external URLs, alias and twin targets, the warning-to-failure switch, and no check without the option.

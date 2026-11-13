---
id: audit:modootoday/20261113044135
title: Usability audit of the 1.7.0 release candidate
status: active
created: 2026-11-13T04:41:35Z
updated: 2026-11-13T04:41:35Z
rel:
  governs: [docs]
---

# Usability audit of the 1.7.0 release candidate

## Scope

A first-time user evaluates commit 4df1cd8 (after release 1.6.0) using only the public documentation site and the
public repository. The theme was installed with the Gemfile method, pinned to the main branch, since 1.7.0 is not
released. Each 1.7 feature was turned on from the docs alone: the PWA, feed discovery and Subscribe links, edit_url
auto and the build link, the feedback row, a changelog feed with feed_source, releases_feed, the release banner,
Open Graph image alt and size, the print sheet, heading anchors and the On this page mark, and the links check.
One Korean page tested the translation docs.

## Method

Jekyll 4.4.1 and Ruby 3.3.4, one build and one check after each step, with the output HTML read for the
expected markup. No browser: the update and offline notices, the install button and the On this page mark were
checked as markup and loaded scripts only. A separate screenshot review covered them in a browser.

## Findings

Totals: 0 blockers, 5 majors, 9 minors. Every task was finished.

### Major

- **M1 Two feed mechanisms.** Configuration and the checker say `feed: true` needs jekyll-feed; Blog and news
  says to add a `layout: feed` page. The page works with no plugin, but the checker warns on every run and
  fails under `--strict`, and jekyll-feed would write a second /feed.xml.
- **M2 Changelog feed keys are not where a changelog author looks.** `feed_source`, `releases_feed` and `feed:`
  on a changelog page are missing from the Docs extras Changelog section and the updates recipe; they were found
  by searching the repository.
- **M3 `feed_source: data`** reads "the generated `_data/releases.yml`" with no generator and no shape.
- **M4 Feedback row values.** `feedback.discuss` and `labels` have no value type and there is no YAML example.
- **M5 Language menu links to a missing home.** Every language in `languages` needs a home page; the docs never
  say so, and `--links --strict` reports the link as broken on every page.

### Minor

- m1 The live docs show 1.7 keys while the install guide pins 1.6, with no "since" marker.
- m2 No note on trying an unreleased version from git.
- m3 `--links` needs nokogiri; the Verify section does not say so, and without it the check exits 0.
- m4 `banner: {release: latest}` with no release data shows nothing and warns about nothing.
- m5 The `github:` stand-in map has no YAML example.
- m6 Translation rules is for contributors; the site-author steps are one dense paragraph in Configuration.
- m7 The upgrade note for 1.7 lists only event tickets and the PWA.
- m8 The On this page mark is described only in Accessibility and Public API.
- m9 No step for seeing the PWA update notice.

### Worked from the docs alone

The PWA stubs, manifest, offline page and install section; blog and author feeds with Subscribe links;
edit_url auto and the build link; the feedback row; Open Graph alt and size; the print sheet; heading anchors;
the links check once nokogiri was installed; a Korean folder translation with hreflang and Korean labels.

## Status

The nine minors, fixed in eight commits after release 1.7.0: two change `modootoday-check` (f10366f, 9634367) and six
change the docs only, each in English, Korean and Japanese. m7 had been fixed before the release (3f74b76).

| Finding | Status | Commit | Change |
|---|---|---|---|
| m1 no since marker | fixed | d6c2437 | The Configuration key table has a Since column, filled for the keys (or new forms of older keys) that 1.7 added, with a line that links the upgrade notes. The docs consistency ADR allows this bare version column as an exception to its version-mention rule. |
| m2 trying an unreleased version | fixed | ab241fa | Install, "Try the next release": the Gemfile `git:` and `branch: "main"` line, `remote_theme` `@main`, moving to a newer commit, and pinning a release again before publishing. |
| m3 `--links` without nokogiri exits 0 | fixed | f10366f | The run fails with an error that says to add `gem "nokogiri"`; the CLI tables, Install and the links ADR say so. The test runs with nokogiri hidden, so it no longer skips where nokogiri is installed. |
| m4 `banner: {release: latest}` silent | fixed | 9634367 | The checker warns when the key is set, the banner component is on and the built home page has no release banner. The updates recipe names the field, `site.github.latest_release` (`tag_name`, `html_url`). |
| m5 no `github:` map example | fixed | 00ccf3f | Head and SEO shows the map with `source.path` (a leading slash, no trailing one; `/` for the root) and `latest_release` for the banner. |
| m6 site-author translation steps | fixed | 4f9ded8 | New guide Translate your site: six steps, ending with `full_languages`, `--i18n-pages` and `source_rev`. Translation rules and Configuration, Languages link it. |
| m7 upgrade note lists two features | fixed | 3f74b76 | Checked again: the 1.7 entry lists every key the Since column marks. |
| m8 On this page mark | fixed | 539b595 | The Components table of contents section already said the list marks the section being read; it now says the mark has no setting of its own and goes with `toc: false` or a `components` list without `toc`. |
| m9 seeing the update notice | fixed | a919a7f | Installable site, Updates: four steps with `asset_version: build` and two deploys. |

---
id: audit:modootoday/20261114090416
title: Usability audit of the 1.7.1 release candidate
status: active
created: 2026-11-14T09:04:16Z
updated: 2026-11-14T09:04:16Z
rel:
  governs: [docs]
---

# Usability audit of the 1.7.1 release candidate

## Scope

A site author who already uses the theme follows the public documentation for the changes after 1.7.0, on commit
9554726 installed from main with the Gemfile method: which Configuration keys are new in 1.7, the links check
without nokogiri, the release banner without release data and with the github: stand-in map, the Translate your
site guide, and the PWA update notice steps. The theme's source tree and internal notes were not read.

## Method

An empty site, one build and one check after each step, the output HTML read for the expected markup and for
keyboard and screen-reader concerns. No browser: the update notice was checked as markup and scripts.

## Findings

Totals: 0 blockers, 1 major, 15 minors. Every task was finished.

### Major

- **M1 A generated stub fails the translation check.** `modootoday-stubs --pwa --write` writes `offline.<lang>.md`
  for each `full_languages` entry; `--i18n-pages` then warns that it has no `source_rev`, and the Translate your
  site guide recommends `--strict` in CI, which fails on a file the theme generated. Neither page says what to do.

### Minor

- m1 Try the next release does not say to replace the release gem line (both lines give a Bundler duplicate-gem
  error), nor how to see which commit is installed.
- m2 The legend of the bold 1.7 marks sits below the Configuration key table, after the marks it explains.
- m3 The nine marked keys are hard to scan in a table of about sixty rows; no list of them.
- m4 `og_image` is marked 1.7 without saying the new part is its map form.
- m5 The nokogiri message's "or gem install nokogiri" does not help under bundle exec.
- m6 The ko and ja CLI reference tables are in English.
- m7 The banner's site.github warning names the map keys for edit links, which do not make a banner.
- m8 The no-release-banner warning does not name the github.latest_release stand-in.
- m9 The banner row of the Keys table does not link the github: map example, and the updates recipe and the
  Configuration page each name only their own route.
- m10 A tag_name with a leading v shows "v1.2.0 is out." while the docs show "1.7.0 is out.".
- m11 hreflang links need `url:`; the docs say languages: alone is enough, and nothing warns.
- m12 Translate your site step 5 names tabs.label without its YAML shape.
- m13 The checker also scans other `_site_*` build folders, including the SITE argument; only `_site` is skipped.
- m14 The PWA update steps need two real deploys and do not say a local serve works; "set asset_version back"
  does not say to what.
- m15 Keyboard users reach the update notice's Reload only by tabbing to the end of the page, and the docs do not
  say so; code blocks and the wide Configuration table have no accessible name without JavaScript, and each page
  has two nav landmarks named Docs (desktop and mobile copies).

### Worked from the docs alone

The Try the next release Gemfile line; the --links failure message matching the docs; the banner from
`release: {version, url}` and from the github.latest_release stand-in; the Korean page and home with hreflang
(once url: was set) and the source_rev value printed by the checker; the update notice markup (role status,
no focus theft, Esc closes).

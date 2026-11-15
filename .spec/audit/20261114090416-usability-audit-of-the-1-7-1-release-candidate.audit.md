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

## Status

The major and 13 of the 15 minors are fixed in six commits: four change `modootoday-check` (b09525b, 9bd4204,
4eab0fd, 6d70d0c), one the release banner (8f1b495), and one the docs in English, Korean and Japanese (b2d0d4f).
m6 is left as it is and m15 is fixed in part, for the reasons in the table.

| Finding | Status | Commit | Change |
|---|---|---|---|
| M1 generated stub fails the translation check | fixed | b09525b, b2d0d4f | `--i18n-pages` leaves pages with the offline page layout (the ones `modootoday-stubs --pwa` writes), like twins, out of the `source_rev` check; a test builds both stubs. Configuration, Languages and Translate your site step 6 say the offline pages need no `source_rev`. |
| m1 replacing the release line | fixed | b2d0d4f | Try the next release says to replace the theme's line (Bundler refuses the same gem twice) and that `bundle info jekyll-theme-modootoday` or the `revision:` under `GIT` in `Gemfile.lock` shows the installed commit. |
| m2 legend below the table | fixed | b2d0d4f | The **1.7** legend moved above the key table. |
| m3 marked keys hard to scan | fixed | b2d0d4f | The legend lists the nine marked keys. |
| m4 `og_image` mark | fixed | b2d0d4f | The row says the map form is the new part. |
| m5 nokogiri message | fixed | 4eab0fd, b2d0d4f | The error says to add `gem "nokogiri"` and run `bundle install`, with `gem install nokogiri` only for a checker run without Bundler; Install says the same. |
| m6 ko and ja CLI tables in English | not changed | none | The tables are generated by `script/readme-commands` from each command's `--help=markdown`, which the commands print in English; the generator has no translated descriptions, and the ko and ja pages already say the option tables stay in English so that they match the commands' own help. Translating them would mean a second copy of every option text to keep in step by hand. |
| m7 site.github warning for the banner | fixed | 9bd4204 | For `banner.release: latest` the warning names `latest_release: {tag_name, html_url}` and says no banner is shown; a `github:` map without `latest_release` no longer silences it. |
| m8 no-release-banner warning | fixed | 9bd4204 | It names `github: {latest_release: {tag_name, html_url}}` as the stand-in. |
| m9 banner routes | fixed | b2d0d4f | The banner row names both stand-ins and points to the `github:` map example in Head and SEO; the updates recipe names the `github:` map as well as `release: {version, url}` and links the example. |
| m10 leading v | fixed | 8f1b495, b2d0d4f | The banner drops a leading `v` before a digit, for `release: latest` and `{version, url}`; the banner ADR, its test and the updates recipe say so. |
| m11 hreflang needs `url:` | documented | b2d0d4f | Configuration (the `languages` row and Head and SEO) and Translate your site step 1 say `hreflang` links need `url:`, which GitHub Pages fills in. No checker warning: on GitHub Pages the metadata plugin sets `url` when `_config.yml` leaves it out, so a warning read from `_config.yml` would be wrong for most sites. |
| m12 `tabs.label` shape | fixed | b2d0d4f | Step 5 says a dotted name is a nested key, written `tabs: {label: ...}`, and links the catalog example. |
| m13 other `_site_*` folders scanned | fixed | 6d70d0c | Source pages skip the SITE folder and folders starting with `_` other than `_posts`, `_drafts`, collections and `include:` folders, for the page rules and the layout rules; a test puts bad pages in `_site_ko` and in a SITE folder named `build`. The Command line page says so. |
| m14 seeing the notice locally | fixed | b2d0d4f | The Updates steps say a local `jekyll serve` works (service workers are allowed on `localhost`, and each rebuild with `asset_version: build` is a deploy) and that `asset_version` goes back to `theme`, the default. |
| m15 keyboard and names | fixed in part | b2d0d4f | The Updates section says the notice comes last in the page, so keyboard users reach Reload and Later after the page's last link, and that `Esc` closes it from anywhere. Not changed: a static accessible name on every table scroll box and code block would make each one a labelled region, scrolling or not, so the name stays with the script that adds it only when the box overflows. Checked, no change: the two sidebar copies named Docs are never exposed together; below 64rem the desktop column is `display: none` and the mobile copy sits in a closed `details`, and from 64rem the mobile copy is `display: none`. |

## Recheck on 4f1a682

A fresh reader with the public docs only, after the fixes above, the docs link change (relative links name the
Markdown file) and the component order by English title. Totals: 0 blockers, 1 major, 3 minors; every task finished.
55 relative links opened a file on github.com with every fragment matching; the 1.7 legend, the banner without a
leading v, the PWA stubs passing `--i18n-pages --strict`, the footnote role on the link, the twin links and the
nokogiri message all worked from the docs.

- **R1 (major)** On Jekyll 4 the `.md` file links stay `.md` in the HTML: GitHub Pages turns on jekyll-relative-links,
  Jekyll 4 does not, and neither the Jekyll 4 install tab nor the minimal configuration says to add it, so
  `--links --strict` fails until the reader guesses the plugin. The twins pass meanwhile.
- r1 The checker reads only `SRC/_config.yml`; a `github:` map in an overlay config (`--config a.yml,b.yml`) builds a
  banner but keeps the site.github warning, and one missing release prints two warning lines.
- r2 The Components On this page list includes the headings inside the examples, and the Install component's id is
  `install-2` because an example heading takes `install`.
- r3 In Korean and Japanese the English-title order reads as unordered; the page explains it.

### Recheck status

All four are fixed in three commits.

| Finding | Status | Commit | Change |
| --- | --- | --- | --- |
| R1 `.md` links on Jekyll 4 | fixed | 00f10bd, c3fad72 | The Install guide's Jekyll 4 Gemfile adds `jekyll-relative-links` in the `jekyll_plugins` group, the minimal configuration sets `relative_links: {collections: true}`, and a paragraph says why (GitHub Pages runs the plugin, Jekyll 4 does not). `--links` reports a relative `.md` link that no twin or Markdown copy answers with a message that names the plugin; a test covers it. The README shows no Jekyll 4 Gemfile in its install section, and the starters' Jekyll 4 Gemfile already lists the gem (their pages have no `.md` links), so neither changed. |
| r1 overlay configs and two warnings | fixed | c3fad72 | `--config=FILE,...` reads the settings from those files instead of `SRC/_config.yml`, merged in order with later keys winning, as `jekyll build --config` does; a missing file fails. With no banner in the build, the release-banner warning replaces the site.github warning for the same key, so one missing release prints one message. Tests and a `release-banner` messages snapshot cover both. |
| r2 example headings and the Install id | fixed | 9e1c9ca | The On this page list already lists only headings whose first attribute is their id; the docs examples include puts a class before the id of each heading in a live result, so the examples no longer fill the list. A theme test pins the rule. The Steps as headings and Timeline examples no longer use an Install heading, so the Install section's id is `install` (`설치`, `インストール`). No docs link pointed at the old ids. |
| r3 order in Korean and Japanese | fixed | 9e1c9ca | The Korean and Japanese intros, which already explain the English-title order, add that Buttons and Cards are in the Page sections group, with a link to it. |

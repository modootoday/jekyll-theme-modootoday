---
id: audit:modootoday/20261104191444
title: Usability audit of the 1.5.0 release candidate
status: active
created: 2026-11-04T19:14:44Z
updated: 2026-11-04T19:14:44Z
rel:
  governs: [docs]
---

# Usability audit of the 1.5.0 release candidate

## Scope

A first-time user's run through the release candidate (commit bc6c08f), using only the public documentation site and the repository README and CHANGELOG. No theme source was read. Four tasks: install and build on both stacks, run the checker, turn on each feature the release adds, and check accessibility on the built site.

Deviation from the docs: the candidate has no tag, so every pin names the commit instead of a version (`remote_theme: modootoday/jekyll-theme-modootoday@bc6c08f`, and the gem from git at `ref: "bc6c08f"`). On the remote_theme site the checker ran from the gem checkout of that commit, the way the Install guide runs it from a release tarball.

## Method

- Ruby 3.3.4, Bundler 2.5.23. GitHub Pages path: a Gemfile with `github-pages ~> 232` and `remote_theme`. Gem path: Jekyll 4.4 with the theme gem. Feature path: a site made by `jekyll new` (Jekyll 4.4.1) with only its theme lines changed, then each feature added.
- Accessibility: the built feature site was served by a local static server and reached by the remote browser (Chrome 152) through a short-lived tunnel. axe-core 4.13.0 at the desktop (1440x900) and mobile (390x844) presets, plus one dark-mode run. A scripted keyboard-only pass at 1440, 390, 360 and 1024px read focus, landmarks, headings and accessible names from the DOM.
- Times are wall-clock times of this run. A person reading the docs for the first time would take longer.

## Time per task

| Task | Time | Notes |
|---|---|---|
| Reading the Install, Upgrade, Customize, Search and Changelog pages | 1 min 19 s | before task 1 |
| 1. Install and build | 1 min 21 s | GitHub Pages path 58 s, one failed build first (M2); gem path 23 s |
| 2. Run the checker | 1 min 5 s | both sites failed the documented verify command first (M3) |
| 3. Turn on the 1.5 features | 2 min 41 s | all features built; one checker error on a documented feature (M5) |
| 4. Accessibility | 6 min 14 s | two axe passes, one keyboard pass |

## Results by feature

| Feature | Docs said exactly what to write | Worked first try |
|---|---|---|
| `jekyll new` site switched to the theme (`page` layout, home post list, header nav, byline author) | O (Upgrade guide, README) | △ builds and the list, nav and byline work; pages lose their title heading (M4) |
| Stacked tables on narrow screens | △ automatic below 40rem; the opt-in class is in the API reference only | △ stacking works at 390 and 360px; the opt-in class fails the checker (M5); a wide-screen cell breaks inside a word (M7) |
| Long site names | O nothing to write | O two lines with an ellipsis at 360 and 390px, two full lines at 1024px |
| Footer columns from data | O Customize, Footer | O |
| Search with highlighting | O Search recipe for the index file; highlighting is automatic | O matched words are marked in titles and snippets |
| 404 quick links | X "write a body to add your own links"; the paragraph-of-links shape is not stated | O guessed one paragraph of links, which became chips |
| Module sheets and asset settings | O Performance, Customize | O per-page sheets, `asset_version: build` and `site_css` as described |

## Accessibility results

axe-core violations (rules / nodes):

| Page | First pass, desktop | First pass, mobile | After body headings, desktop | After body headings, mobile |
|---|---|---|---|---|
| Home (`jekyll new` index, `home` layout) | 1 / 1 (page-has-heading-one) | 1 / 1 | 0 | 0 |
| Doc page (`page` layout, two tables, an alert) | 0 | 0 | 0 (also 0 in dark mode) | 0 |
| Post | 0 | 0 | 0 | 0 |
| About (`page` layout from `jekyll new`) | 1 / 1 (page-has-heading-one) | 1 / 1 | 0 | 0 |
| 404 (`error` layout) | 0 | 0 | not rerun | not rerun |
| Search (`search` layout) | 2 / 2 (landmark-unique, page-has-heading-one) | 2 / 2 | 2 / 2 | 2 / 2 |

The target, 0 violations on the home page, a doc page and a post, was met only after adding a `#` heading to the body of the home and About pages, which no page of the docs asks a `jekyll new` site to do (M4).

Keyboard pass:

- Skip link: the first Tab stop on every page with a header, visible on focus; Enter moves focus to `main`.
- Desktop order: skip link, site name, header links, search box, theme toggle, breadcrumb, table of contents. Every stop had a visible 2px focus ring.
- Below 64rem: the Menu button opens the sheet with Enter, Tab enters its links, and Escape closes it and returns focus to Menu. The Tab order (site name, Menu, search, theme toggle) differs from the visual order (search, theme toggle, Menu) (m4).
- Search: `/` focuses the box at every width; results appear with the matched words marked; ArrowDown moves into the results. After Tab leaves the box, the results stay open and Escape does not close them (m10).

Landmarks, headings and names from the DOM: one banner, a named main navigation, a search landmark, one main and a footer with two navigations named by their column titles. The doc page's "On this page" navigation has no name (m11). After the heading fix every audited page has one `h1` and no skipped levels. No button or summary lacks a name. The 404 page has no header and no skip link, so its only navigation is the quick-link chips and the footer.

## Ambiguous or unactionable checker messages

Quoted exactly:

1. ``index.md: twin missing at _site/index.md: add a stub index.md.txt (front matter `layout: twin`, `twin_of`, `permalink`) or enable `plugins: [jekyll-theme-modootoday]` (not on classic GitHub Pages)``. It names two keys without their values, and does not mention `modootoday-stubs . --twins --write`, which writes the stub.
2. ``_site/llms.txt: missing (per-language llms file; stub with `layout: llms` or the plugin)``. It does not name the stub's file name or location, and `modootoday-stubs --twins` does not write this stub.
3. ``_site/llms-full.txt: missing (per-language llms file; stub with `layout: llms-full` or the plugin)``. Same as 2.
4. `guide.md:20: kramdown IAL/ALD`. It gives no severity, no reason and no fix, and it fires on `{: .mt-table--stack}`, a class that the Public API reference documents.
5. `md-components check: OK (0 pages)`. This printed on a `jekyll new` site with three `.markdown` pages, so it is unclear whether those pages were checked at all.
6. `usage: modootoday-check SRC SITE [--twins] ...` (exit 1). This came from the Upgrade guide's own instruction, "run `modootoday-check --strict`".

## Findings

Grades: blocker = a task could not be finished from the docs; major = finished, but only by guessing or after a wrong first result; minor = friction.

Totals: 0 blocker, 7 major, 12 minor.

### Major

- **M1. The GitHub Pages path fails its first local build** (Install). With the GitHub Pages tab's two lines and the github-pages gem tab's Gemfile, `bundle exec jekyll build` stops with "No repo name found. Specify using PAGES_REPO_NWO ... or 'repository' in your configuration" in the default layout. The Install guide does not mention `repository:`. Adding `repository: owner/name` fixed it.
- **M2. The Install guide's verify command fails on a fresh site** (Install, Agents). `modootoday-check . _site --twins` reports 3 problems on a one-page site, because the Install guide never sets up twins or `llms.txt`. The fix is spread over the Agents guide (`modootoday-stubs . --twins --write` on GitHub Pages, the plugin on Jekyll 4). The `llms.txt` and `llms-full.txt` stubs are described only as "one-line stubs" with no file names, so they had to be guessed (`llms.txt` and `llms-full.txt` at the root with `layout: llms` and `layout: llms-full`).
- **M3. The Jekyll 4 build prints about 4,500 lines of Sass deprecation warnings** (Install). The Install guide's minimal configuration has no `sass:` key. The guide mentions "the Sass silencing option" only for the github-pages gem and does not name it. Only the README quick start has `sass: {silence_deprecations: [import, global-builtin]}`. The output is correct, but a first build looks broken.
- **M4. A `jekyll new` site loses its page titles** (Migrate and upgrade, Layouts). The Upgrade guide says such a site "needs no other change", and `layout: page` is the doc layout. The doc layout does not print `title:` as a heading, so the About page has no `h1` (minima prints one) and axe reports page-has-heading-one on About and Home. The fix, a `# Title` line at the top of the body, is implied by First page but not stated in the migration section.
- **M5. The documented stacked-table class fails the checker and breaks a stated rule** (Public API, First page). The API reference lists `table.mt-table--stack`, `--dl` and `--fixed`, set with a kramdown attribute list. First page lists "kramdown attributes" as not allowed, and the checker exits 1 with `kramdown IAL/ALD`. No guide page explains stacked tables. The automatic stacking below 40rem worked without any markup.
- **M6. The `search` layout fails axe and its fallback form searches the whole web** (System pages, Layouts). A page with `layout: search` has two violations that the docs give no way to fix: two search landmarks without distinct names (landmark-unique), and no `h1` although the page has `title: Search`. Its no-JavaScript form sends the query to an outside search engine with an empty site filter when `url:` is empty, as `jekyll new` leaves it. Neither page says that the layout needs `url:`.
- **M7. A short table breaks code inside a word at desktop width** (Upgrade guide, The 1.5 look). In a three-column table at 1440px, the inline code `header` in the second column wrapped as "heade" over "r". The Upgrade guide says that code after the first column may break only in tables of four or more columns.

### Minor

- **m1. Install still pins 1.4** (Install, README). `@v1.4.1` and `~> 1.4` appear everywhere, while the same site already describes the 1.5 look. A reader who follows Install gets 1.4.1 and none of the features the Upgrade guide describes. The Install guide needs the 1.5 pin at release.
- **m2. There is no "what's new" page for 1.5** (Changelog). The site's Changelog page lists only 1.0.0. The 1.5 additions are in the Upgrade guide's prose and in a roughly 96 KB "Unreleased" section of CHANGELOG.md. Finding the seven features meant reading both.
- **m3. The GitHub Pages tab says "no Gemfile needed"** (Install). The verify step (`bundle exec jekyll build`) and any local preview need the github-pages Gemfile from the third tab, and the guide leaves it to the reader to combine the two.
- **m4. The narrow header's Tab order differs from its visual order** (Accessibility). Below 64rem, Tab reaches Menu before the search and theme buttons, which sit to its left.
- **m5. The format of the 404 quick links is not stated** (Layouts, Error; System pages). The docs say "write a body to add your own links". The Upgrade guide says that "a body paragraph of links" becomes chips. Neither shows the Markdown. One paragraph of space-separated links worked.
- **m6. The Upgrade guide's `modootoday-check --strict` prints usage** (Migrate and upgrade). It needs `SRC SITE`.
- **m7. The checker counts 0 pages on a `jekyll new` site** (checker). `OK (0 pages)` with three `.markdown` pages leaves it unclear what was checked.
- **m8. Candidate asset URLs carry the old version** (Performance). Every theme file has `?v=1.4.1`, so a CDN rule from the Performance guide would keep serving cached 1.4 files after an upgrade if the version is not bumped at release.
- **m9. Search highlighting is mentioned in one sentence of the Upgrade guide only** (Search recipe). It works without settings, but the Search recipe does not mention it or the `mark` styling.
- **m10. Search results stay open after focus leaves** (Accessibility). After Tab moves past the search box, the result list stays visible and Escape does not close it. The box has no expanded state for assistive technology.
- **m11. The table of contents navigation has no name** (Accessibility). Every other navigation landmark is named. The "On this page" one is announced only as "navigation".
- **m12. The error page's main button is still accent-filled** (Upgrade guide, The 1.5 look). The 1.5 look says the primary action is neutral, but "Go to the home page" on the 404 page uses the accent fill. A "Home" quick link next to it repeats it.

### Worked as documented

The footer from `_data/nav/footer.yml`, the long site name, the home post list, the header navigation from titled pages, the byline from minima's `author: {name, email}`, `asset_version: build`, `site_css`, per-page sheets and module scripts, the menu sheet's keyboard behaviour and the skip link all worked on the first try.

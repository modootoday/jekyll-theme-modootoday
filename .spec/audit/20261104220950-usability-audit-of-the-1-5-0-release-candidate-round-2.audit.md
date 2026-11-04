---
id: audit:modootoday/20261104220950
title: "Usability audit of the 1.5.0 release candidate, round 2"
status: active
created: 2026-11-04T22:09:50Z
updated: 2026-11-04T22:09:50Z
rel:
  governs: [docs]
---

# Usability audit of the 1.5.0 release candidate, round 2

## Scope

A first-time user installs and configures the theme at release candidate commit 07d5754 (the tip of
`main`, not tagged), using only the public documentation site and the README. The user did not read
the theme source, earlier audits or internal notes.

Deviation from the docs: where the docs pin `@v1.4.1` or `~> 1.4`, the audit pinned
`remote_theme: modootoday/jekyll-theme-modootoday@07d5754`, or the gem from git at ref 07d5754, and
ran `modootoday-check` and `modootoday-stubs` from the 07d5754 source archive (the Install guide's
"without installing a gem" route) instead of `gem install -v '~> 1.4'`, which would install the
1.4.1 checker.

Stacks: Ruby 3.3.4; `github-pages` 232 (Jekyll 3.10) with `jekyll-remote-theme`; Jekyll 4.4.1 with
the theme gem. Browser checks used a remote headless Chrome 152 (Cloudflare Browser Rendering)
reaching the local static build through a temporary tunnel; no local browser was used.

## Method

1. Install from an empty folder: `remote_theme` for GitHub Pages, then Jekyll 4 with the gem.
2. Run `modootoday-check` as the Install guide says, then on a copy with deliberate mistakes.
3. `jekyll new` (Jekyll 4.4.1), change the theme line, build, inspect headings, the home post list,
   the header nav and the post byline.
4. Turn on the 1.5 features found through Migrate and upgrade ("The 1.5 look") and the CHANGELOG
   link: stacked tables, long site name and logo-only header, footer columns, search highlighting
   (including a one-character Korean query), 404 quick links, status badges, cards in 3 and 4
   columns, the CTA section.
5. axe-core 4.13.0 with tags wcag2a, wcag2aa, wcag21aa, wcag22aa and best-practice on home, a doc
   page, a post, the search page and About, at 1280x800 and 360x740; then one keyboard-only pass.

Grades: blocker = cannot finish from the docs; major = finished only by guessing, or a wrong first
result; minor = friction.

## Time per task

| Task | Start (UTC) | End (UTC) | Wall time | Notes |
|---|---|---|---|---|
| 1. Install and build (both stacks) | 21:52 | 21:54 | 2 min | includes reading Install; builds took 5.2 s (Pages) and 1.7 s (Jekyll 4) |
| 2. Run the checker | 21:54 | 21:55 | 1 min | the classic site needed `modootoday-stubs` and two `llms` files first, as the guide says |
| 3. `jekyll new` site | 21:55 | 22:04 | 9 min | about 6 min of it was waiting for a shared build slot on the test host |
| 4. 1.5 features | 21:59 | 22:10 | 11 min | includes one rebuild for the 404 checker failure (M2) |
| 5. Accessibility and keyboard | 22:04 | 22:09 | 5 min | two remote browser runs |

## Findings

No blocker: every task was finished. 4 major, 11 minor.

### Major

- **M1. "Only its theme line changed" fails on Jekyll 4.** Migrate and upgrade and the README
  ("Plain Jekyll first") say a `jekyll new` site needs no other change. Changing only
  `theme: minima` stops the build with "The jekyll-theme-modootoday theme could not be found
  (Jekyll::Errors::MissingDependencyException)", because the generated `Gemfile` still lists
  `minima`. Neither page says to replace `gem "minima"` with the theme gem (or, on GitHub Pages, to
  use the two `remote_theme` lines). After swapping the gem line the site built and the claims held:
  About has its `h1`, the home page has the site title as `h1` and lists the post, the header lists
  About, and the post has its title and date. Doc page: Migrate and upgrade; README.
- **M2. The documented 404 page fails `modootoday-check --twins` on Jekyll 4 with the plugin.** The
  Error example on Layouts (Page shells) uses `permalink: /404.html`. The plugin writes the twin as
  `_site/404.md`, but the checker looks for `_site/404/index.md` and says "add a stub 404.md.txt …
  or enable `plugins: [jekyll-theme-modootoday]`", although that plugin is already enabled. Adding
  the stub would duplicate the plugin's work. The fix that worked, `twin: false` in the page's front
  matter, is documented only for record pages (Generated pages). Doc pages: Layouts > Page shells;
  Install > Verify the build; Recipes > System pages.
- **M3. The Customize footer example produces an axe violation.** Its first column is titled
  `Docs`, and the doc sidebar landmark is also labelled "Docs", so every page with a sidebar fails
  `landmark-unique` (doc page, post and About at 1280px). The docs do not say that column titles
  become landmark names that must differ from the sidebar's, or how to rename the sidebar label.
  Doc page: Customize > Footer.
- **M4. The published docs describe 1.5 while Install pins 1.4.** The docs site already documents
  1.5 keys (for example `header: {compact_title: …}` in the Configuration table, footer data,
  search highlighting), but Install, the home page and the README pin `@v1.4.1` and `~> 1.4`, and
  tell a `remote_theme` user to `gem install … -v '~> 1.4'`, which installs the 1.4.1 checker. A
  user who follows them gets none of these features and no error. The Migrate and upgrade row
  "1.4 → 1.5" pins `@v1.5.0`, which does not exist yet. Doc pages: Install, Configuration, Migrate
  and upgrade.

### Minor

- **m1. Thousands of Sass notices on a `jekyll new` site.** With the generated `_config.yml` the
  Jekyll 4 build printed 410 `@import` deprecation notices (4,536 log lines). Install has the
  `sass: silence_deprecations` line, but the `jekyll new` paragraph in Migrate and upgrade does not
  mention it. Doc page: Migrate and upgrade.
- **m2. An unlisted warning on the local GitHub Pages build.** "GitHub Metadata: No GitHub API
  authentication could be found. Some fields may be missing or have incorrect data." Install lists
  two harmless warnings but not this one. Doc page: Install.
- **m3. The search file's one line is not printed.** The Search recipe says to add `search.json`
  with `layout: null` and "one line that includes `modootoday/search.json`", then links to the
  repository file instead of showing the four lines. Doc pages: Recipes > Search; Components >
  Search.
- **m4. Compact matches are not highlighted.** With `compact: true`, the query 검색량조회 found the
  page that contains "검색량 조회", but the result showed no snippet and no `mark`, while the recipe
  says every matched word in the title and snippet is marked. The one-character query 표 worked:
  four marks, underlined on a light tint. Doc page: Recipes > Search.
- **m5. Which wide tables stack cannot be predicted.** At 360px a two-column key table stacked into
  labelled blocks with no markup, as documented. A six-column status table with a 200-character
  cell scrolled instead (its longest cell is five lines in 9rem columns, under the six-line rule),
  and a page body has no portable way to ask for stacking. Doc pages: Components > Tables;
  First page.
- **m6. Some mistakes pass silently.** `cols: 5` on a `c: features` item and a misspelled
  `copyrite:` in `_data/nav/footer.yml` built and checked clean. The first is caught only with an
  optional `_data/components.yml`, which the Cards section does not mention. Doc pages: Components >
  Cards; Customize > Footer.
- **m7. Header focus order differs from the visual order below 64rem.** Tab reaches the menu
  button before the search box and the theme toggle, but the menu button is drawn to their right
  (at 800px: menu at x 736, search at x 440, toggle at x 688). Doc page: Accessibility.
- **m8. The skip link lands before the sidebar.** "Skip to content" moves focus to `main`, and the
  next Tab stops are the sidebar's eight links and group title before the breadcrumb and the text.
  Doc page: Accessibility.
- **m9. A `layout: home` page shows the docs pager.** The home page ended in "Next: Tables". The fix,
  `pagination: false`, is on Components > Previous and next, not on the Home layout section.
  Doc page: Layouts > Page shells.
- **m10. The checker cannot report the theme version.** `modootoday-check --version` prints only
  "md-components v1", so a user cannot confirm that the checker matches the pinned theme (which
  matters with M4). Doc page: README > Commands.
- **m11. The Components twin omits the section front matter.** The HTML page shows each example's
  `sections:` front matter (for example `{c: features, name: cards-3, cols: 3}`), but the Markdown
  twin and `llms-full.txt` show only the body, so an agent reading them cannot copy the card
  settings. Doc page: Components.

### Ambiguous or unactionable checker messages

| Message (quoted) | Problem |
|---|---|
| "guide/index.md: twin missing at _site/guide/index.md: add a stub guide/index.md.txt with front matter `layout: twin`, `twin_of: index.md` and `permalink: /guide/index.md` (`modootoday-stubs SRC --twins --write` writes every missing stub) or enable `plugins: [jekyll-theme-modootoday]` (not on classic GitHub Pages)" | `twin_of: index.md` reads as the home page; that it is relative to the stub's folder is not said. The command shows `SRC` instead of the source folder that was passed. |
| "404.md: twin missing at _site/404/index.md: add a stub 404.md.txt … or enable `plugins: [jekyll-theme-modootoday]` (not on classic GitHub Pages)" | The plugin was enabled; the real fix (`twin: false`) is not named (M2). |
| "_config.yml: modootoday.header must be a map with compact_title: set to true or false" | Given `header: {compact_title: no_thanks}`, which is a map; the message should say the value is wrong. |
| "_site/guides/tables/index.md: twin is not byte-identical to the body of guides/tables.md" and "_site/llms-full.txt: does not contain the body of guides/tables.md" | The cause was a stale build after a source edit; neither message suggests rebuilding. |
| "about.md: layout single does not exist in the site or the theme, so Jekyll writes the page without one; use doc or post (Minimal Mistakes)" | "(Minimal Mistakes)" reads like a layout name; it means "as the replacement for that theme's layout". |

Clear messages, for comparison: the kramdown attribute list message ("remove it: a table that does
not fit stacks by itself below 40rem …"), the unknown `status:beta` value, and the `.markdown`
warnings on a `jekyll new` site ("not checked (the rules read .md pages); rename it to .md").

### What each 1.5 feature needed

| Feature | Found in | Exact text to write? | First try? |
|---|---|---|---|
| Stacked tables | First page, Components > Tables | nothing to write | O (two-column table), △ (six-column table scrolled, m5) |
| Long name, logo-only header | Configuration (`logo`, `header`) | O | O: logo only, 40x40 link at 360 and 414px, name in the accessible name; two lines at 480px |
| Footer columns | Customize > Footer | O | △: rendered as two labelled `nav` columns, but the example breaks axe (M3) |
| Search highlighting | Recipes > Search | △ (search file line not printed, m3) | O for 표 and for English; △ for compact matches (m4) |
| 404 quick links | Layouts > Page shells > Error | O | △: chips rendered, the checker failed the page (M2) |
| Status badges | Components > Badges | O | O: label only, one 6px dot |
| Cards in 3 and 4 columns | Components > Cards | O | O: three across, four as two by two in the text column, as documented |
| CTA section | First page, Components > Buttons | O | O: flat, start-aligned on a doc page, first button filled |

## Accessibility

axe-core 4.13.0, tags wcag2a, wcag2aa, wcag21aa, wcag22aa and best-practice; counts are violating
nodes.

| Page | 1280x800 | 360x740 |
|---|---|---|
| Home | 0 | 0 |
| Doc page | 1 (`landmark-unique`) | 0 |
| Post | 1 (`landmark-unique`) | 0 |
| Search | 0 | 0 |
| About | 1 (`landmark-unique`) | 0 |

All three are M3: the sidebar landmark and the footer column share the name "Docs". At 360px the
sidebar is folded into a menu, so the duplicate is not reported.

## Keyboard

- The first Tab shows "Skip to content" (138x44); Enter moves focus to `main` (m8 for what follows).
- At 1280px the order is the site name, the header links (with the Guides group button in place),
  search, the theme toggle, then the sidebar; every stop has a visible 2px focus ring.
- Below 64rem (800 and 360px): Enter on the menu button opens the sheet; ArrowDown moves through
  its links; Escape closes it and returns focus to the button; tabbing past the last link closes the
  sheet. Focus order differs from the visual order (m7).
- Search: `/` focuses the box; with a query, Tab moves into the first result; Escape clears the
  query and keeps focus. At 360px the focused box covers the header row (312px wide) and shows
  results.
- At 360px the logo link is a 40x40 target with the site name as its accessible name and a 2px
  focus ring.

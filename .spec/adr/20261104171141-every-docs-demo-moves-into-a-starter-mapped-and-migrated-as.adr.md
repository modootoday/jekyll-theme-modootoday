---
id: adr:modootoday/20261104171141
title: "Every docs demo moves into a starter, mapped and migrated as follows"
status: active
created: 2026-11-04T17:11:41Z
updated: 2026-11-04T17:15:09Z
rel:
  governs: [example/starters.yml]
  depends_on: [adr:modootoday/20261104170401, adr:modootoday/20261104170556, adr:modootoday/20261103202417, sot:modootoday/docs-demo-to-starter-map]
  evidence: [research:modootoday/20261104170510]
---

# Every docs demo moves into a starter, mapped and migrated as follows

## Context

The docs site holds 44 demo pages:

- 32 layout demos in six groups;
- 12 shell and feature demos (with their index) under `layouts/demo/`;
- the records demo, an index and five record pages.

Most have Korean and Japanese siblings. They render inside the docs site, with its chrome, its sample content and its own demo stylesheets.

Starter demos are now real sites: each starter's repository publishes its own demo with a showcase back to the docs ([[adr:modootoday/20261104170401]], [[adr:modootoday/20261104170556]]). The starter catalog plans 13 starters on six presets, and together they cover every theme layout.

The research [[research:modootoday/20261104170510]] inventoried the demos, their links and every QA list that names them, and surveyed how theme marketplaces and authors present demos.

## Decision

### Every demo moves into a starter

- **The map.** Every demo page moves into the starter listed for it in [[sot:modootoday/docs-demo-to-starter-map]], which is the one list of rows, targets and waves. A row moves once, to its final starter.
- **Layout demos (32).** Each URL becomes the layout's reference page: a description, its front matter keys, a small static preview image, and a "Live demo" link. The URL keeps a page about that layout, so it is not redirected.
- **Shell, feature and record demos (14 rows).** These have no reference page of their own, so each URL becomes a redirect stub to its starter page. Their features stay documented on their feature pages, with inline examples.
- **Not demos, so they stay:**
  - the kitchen sink and its right-to-left fixture: the component reference and coverage gate, until the docs rebuild;
  - the docs home in every language;
  - the docs site's own blog, news, authors and posts;
  - the recipes.
- **Clean-up:** the demo-only includes, layout and stylesheets of the docs site are removed with the last row that uses them.

### The starters

The 13 starters of the catalog are kept as they are; the demos need no merge and no split:

- Every demo row fits a planned page of one starter.
- Every layout has at least one starter (section 6 of the map).
- Merging landing into saas would lose the single-page product launch that the `home`, `minimal`, `download` and script-visual demos need.
- Splitting blog would duplicate newsroom, which already takes the news rows.

| Starter | Preset | Languages | Stacks | Pages (demo rows marked with the layout) |
|---|---|---|---|---|
| docs | base | en, ko, ja (directory mode) | github-pages, jekyll4 | home, guide (code_theme github), reference, api, plugins (integrations) and record pages (detail), search, an alias redirect, 404 (error); `csp: strict` |
| blog | editorial | en | github-pages, jekyll4 | blog home, posts (post), authors, archive, feed, subscribe, about, search, 404 |
| landing | product | en | github-pages, jekyll4 | home (home, script visual), pricing, download, privacy and terms (legal), thanks (minimal), 404 |
| saas | product | en | github-pages, jekyll4 | home (wide), features (feature), pricing, integrations, customers (directory) and case studies (case-study), changelog, roadmap, blog, contact, brand, legal, security |
| help-center | base | en, ko, ja (sibling mode), partial ar | github-pages, jekyll4 | home (hub), category hubs, articles, FAQ, glossary, contact, search, 404 including Arabic (error, right to left) |
| marketplace | base | en | github-pages, jekyll4 | home, plugins and skills with facets (filter, integrations) and detail pages, publishers (team), submit, policy (legal), catalog JSON |
| portfolio | studio | en | github-pages, jekyll4 | home, work (portfolio) and projects (project), a case study, resume, links, about, contact |
| company | studio | en | github-pages, jekyll4 | home (wide), services (feature), work, about, team, careers (jobs) and jobs (job), news, contact, legal |
| oss | terminal | en | github-pages, jekyll4 | home, install (download), releases (changelog), roadmap, sponsors, team, brand, community, packages |
| conference | stage | en | github-pages, jekyll4 | home, schedule (events), sessions (event), speakers (team), sponsors, venue, tickets (pricing), code of conduct (legal), FAQ, past events (archive) |
| course | editorial | en | github-pages, jekyll4 | home, course (course), lessons, handbook (book), glossary, instructor (author) |
| podcast | stage | en | github-pages, jekyll4 | home, episodes (episode), hosts (team), subscribe (links), sponsors, podcast feed |
| newsroom | editorial | en | github-pages, jekyll4 | front page (news), sections, articles (news-article), authors, archive, feed, newsletter |

- **Manifest.** `example/starters.yml` lists a starter once its folder exists. Its `name`, `repo`, `languages`, `stacks` and `check` follow this table.
- **The news folder.** Today's blog starter holds a `news/` folder. It moves to newsroom when newsroom is published; until then no docs demo points to it.

### Migration rules

- **When a docs demo goes.** A row moves only in the change that publishes its starter, or republishes it with the row's page. That means:
  - after the starter's repository is public and its demo deploy is green ([[adr:modootoday/20261104170556]]);
  - never before;
  - never in a theme release commit.
- **Redirects.** A stub replaces each moved shell, feature or record demo URL, in every language that had the page.
  - The stub uses the theme's `redirect` layout, with `redirect_to:` set to the absolute starter page URL. It writes:
    - a canonical link to that URL;
    - a zero-second meta refresh;
    - `noindex`;
    - a visible link.
  - It runs no script, so it works under the strict CSP.
  - A Korean or Japanese stub points to the starter's page in that language when the starter has it, else to the English page.
  - The page's Markdown twin and alias URLs get the same stub.
  - Stubs are generated from the map's rows, never written by hand. They stay at least until the next minor release after the move has shipped, and are removed only in a later minor release.
- **The "Live demo" link** on a reference page:
  - **URL:** `https://modootoday.github.io/jekyll-theme-modootoday-<name>-starter/<page>`, rendered from the row's starter and page. The address comes from the manifest name, never typed.
  - **Attributes:** `target="_blank"` and `rel="noopener noreferrer"`.
  - **Text and accessible name:** the visible text is "Live demo" with the theme's new-window arrow. Inside the link, a visually hidden span carries the localized "opens in a new tab", so the accessible name is "Live demo, opens in a new tab", in en, ko and ja.
  - **Marker:** the link keeps the theme's `data-mt-new-window` marker.
  - **One component:** one docs component renders the link, so every reference page and recipe uses the same markup.
- **QA and coverage follow the rows.**
  - **One owner for page lists:**
    - each starter's `qa:` paths in `example/starters.yml` are the starter-side list;
    - the docs-side lists in `test/system/audit/config.mjs`, `test/system/visual/visual.mjs` and `test/system/lighthouse/lighthouse.sh` drop a row's docs URL in the commit that moves it;
    - a test fails when any list names a moved docs URL or a starter path that the starter build lacks.
  - **Where the suites run:** on the output of `rake starters:build`, built with the starter's `_config.demo.yml` so the showcase is included. The Starters workflow runs the audit, visual and Lighthouse suites there, with each starter's `qa:` paths.
  - **What follows the moved pages:**
    - the header and anchor offset checks move with pricing and legal to the landing starter, with one bar and one pill page;
    - the CSP, contrast and code-colour checks move with their rows to the docs starter, which uses `csp: strict` and `code_theme: github`;
    - the filter page type moves to marketplace;
    - the landing page type moves to the landing starter's home;
    - the visual regression of the script-visual demo moves to the landing home.
  - **The coverage check** (`test/system/docs/coverage.rb`) stays on the kitchen sink until the docs rebuild.
  - **Layout coverage:** a starter-coverage check reads section 6 of the map and fails when a layout in `_layouts/` has no published or planned starter.
- **Search engines.**
  - Every page of a starter demo carries `<meta name="robots" content="noindex">`, emitted by the theme whenever the showcase is enabled.
  - A demo carries no canonical link to another host.
  - Why: a demo's text is placeholder content that every site generated from the starter begins with, so indexing it would compete with users' sites and with the docs. A canonical to the docs would point at a page that is not a duplicate, which search engines treat as a hint and ignore.
  - The redirect stubs are `noindex` too. The reference pages in the docs stay indexed and are where search traffic lands.
- **Release placement.**
  - **Before and in 1.5.0:** nothing ships beyond these documents.
  - **1.6.0:** items 11–14 stay as planned. The showcase is added as one more item after item 14: the config key and checker entry, the include, sheet and module with their caps, `noindex`, the catalog keys, and the docs. A starter can only show the showcase once a released theme has it.
  - **After the 1.6.0 tag:**
    - the maintainer creates and publishes the docs, blog and landing repositories;
    - wave 1 of the map moves in the commit that converts those starters to gitlinks ([[adr:modootoday/20261104171142]]).
  - **1.7.0:** items 15–16 (PWA) stay as planned. Items 11–16 contain no starter work, so nothing is inserted into them.
  - **Waves 2–6** follow the expansion phase. Each wave publishes after the first theme release that carries its prerequisites (registry and config, then each preset and its features), in the order of the map.

## Consequences

- **Superseded in the site map.** [[sot:modootoday/documentation-site-map]] planned a hidden `/demos/` tree and moved the shell and feature demos into it. That tree and those rows are replaced by the starter map: layout URLs keep reference pages, and the other demo URLs become stubs to starter pages.
- **Docs edits per wave.** Every wave edits:
  - the reference pages that gain a "Live demo" link, with their ko and ja siblings;
  - `layouts/shells`, `components/index`, the recipes and the guides that link to moved demos;
  - the docs home translations' link to the kitchen sink is unaffected.
- **Size.** Each starter publish is one theme change with its rows, stubs, page-list edits and docs links, plus the maintainer's repository steps.
- **Risks:**
  - a starter page renamed after publishing breaks a stub, so starter page URLs are stable, and a renamed page keeps its own redirect;
  - demo deploys can lag a theme release until the starters are bumped ([[adr:modootoday/20261104171142]], release flow).

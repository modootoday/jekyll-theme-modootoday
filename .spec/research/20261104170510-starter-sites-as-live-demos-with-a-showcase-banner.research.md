---
id: research:modootoday/20261104170510
title: Starter sites as live demos with a showcase banner
status: active
created: 2026-11-04T17:05:10Z
updated: 2026-11-04T17:06:40Z
rel:
  governs: [example]
  depends_on: [adr:modootoday/20261104170401, adr:modootoday/20261104170556]
---

# Starter sites as live demos with a showcase banner

## Question

The docs site carries its own demo pages. The proposal is that the starter templates in `example/` become the live demos, each a real site, and that the docs link to them in a new tab. A starter demo shows a showcase bar or pill that leads back to the theme's canonical site.

Two decisions already settle parts of this, and this research does not restate them:

- [[adr:modootoday/20261104170401]] settles the showcase: config-only enablement, `style: bar | pill`, Liquid rendering, offsets, links, dismissal, assets and labels.
- [[adr:modootoday/20261104170556]] settles hosting: each starter repository's own Pages site, layered with `_config.demo.yml`, marked as a template repository.

This research answers the questions those decisions leave open:

1. Which docs demo pages move to the starters, and what stays.
2. How the old demo URLs redirect.
3. Whether demo sites carry `noindex` or a canonical link.
4. Which release carries the change.
5. How the visual, Lighthouse and docs QA suites follow the demos.

It also records the market survey behind both decisions and the implementation risks found on the way.

## Method

- Read the repository at the head of this change:
  - the demo pages under `docs/` and the generated navigation;
  - every page list in `qa/` and `test/`;
  - `example/starters.yml`, the starter renderer, its templates and the Starters workflow;
  - the docs Pages configuration;
  - the documentation site map, [[sot:modootoday/documentation-site-map]].
- Queried GitHub read-only:
  - `gh repo view` and `gh api repos/<repo>/pages` for the three repositories named in `example/starters.yml`;
  - the theme repository's Pages settings and its latest Pages build.
- Fetched the public pages of theme marketplaces and theme authors, listed under "Market patterns".
  - Where a page answered 403 to a non-browser client, the finding is marked unverified.
  - The retired Bootstrap Themes preview was read from the Internet Archive.
- Measured the gzip size of a draft showcase sheet (bar and pill styles) and of a pre-paint dismissal line. The draft is not part of this change.

No browser was run and nothing was built.

## Findings

### 1. Demo pages in the docs today

Each row is English unless marked: "en/ko/ja" means sibling `.ko.md` and `.ja.md` files exist. "Starter" says whether one of today's three starters (docs, blog, landing) already renders that layout.

**Layout-group demos.** These are in the navigation as "… demo", sitemap off for directory and blog-news pages, `noindex` on blog-news pages.

| Group | Pages (all en/ko/ja) | Layouts shown | Starter today |
|---|---|---|---|
| `layouts/directory/` | portfolio, team, jobs, events, sponsors, integrations | directory layouts | integrations (landing) |
| `layouts/detail/` | project, case-study, job, event, episode | detail layouts | none |
| `layouts/marketing/` | feature, pricing, download, brand, links, contact | marketing layouts | pricing (landing) |
| `layouts/blog-news/` | blog, post, news, article, archive | blog and news layouts | blog, news, news-article (blog) |
| `layouts/docs-extra/` | reference, changelog, roadmap, glossary, hub, course, book, api | docs extras | none |
| `layouts/documents/` | legal, resume | documents | legal (landing) |

That is 32 demo pages, 96 files with translations. Each group also has an index page.

**Shell and feature demos** live under `layouts/demo/`. All are en/ko/ja except `error-rtl` (Arabic, English tree only). All are `nav_exclude`, sitemap off, and listed on `layouts/demo/index`.

| Page | Shows | Kind |
|---|---|---|
| `home`, `minimal`, `wide`, `error`, `error-rtl`, `redirect`, `search` | the shell layouts | layout |
| `orbit` | the hero script visual (site module and poster) | feature |
| `filter` | the list and table filter | feature |
| `csp` | every core component under a strict CSP | feature |
| `code-github` | `code_theme: github` | feature |

**Other demos:**

- **Kitchen sink:** `components/kitchen-sink` (en/ko/ja) and `components/kitchen-sink-rtl` (English tree, `dir="rtl"`).
- **Live sample trees:** `blog/`, `news/`, `authors/` and the posts in `docs/_posts`. `qa/docs/structure.rb` treats them as sample sites.
- **Records:** `recipes/records/` and its five record pages.

**Inbound links from other docs pages.** English sources only; the translations mirror them.

- `layouts/demo/*`: from `layouts/shells`, `components/index`, `recipes/search`, `recipes/csp`, `guides/customize` and `guides/performance`.
- The kitchen sink: from the home page in 21 languages, `components/index` and `reference/roadmap`.
- `layouts/directory/*`: from `layouts/shells` and `recipes/generated-pages`.
- `layouts/blog-news/*`: from `blog/index` and `guides/configuration`.
- `README.md`: links the components page.
- The docs config: holds one hero module setting that only `layouts/demo/orbit` uses.

**Dependants in QA and tests:**

| Suite | File | Demo pages it names |
|---|---|---|
| Visual regression | `qa/visual/visual.mjs` `PAGES` | `components/kitchen-sink/`, `layouts/demo/orbit/`. Baselines are not committed: the workflow renders the base commit and compares. |
| Lighthouse | `qa/lighthouse/lighthouse.sh` | `components/kitchen-sink/` (en, ko), `layouts/demo/orbit/` |
| Docs audit, all pages | `qa/audit/config.mjs` `PAGES` | every layout-group demo and index above, plus `layouts/demo/` minimal, wide, home, error, search, code-github, orbit, filter |
| Page-type budgets | `PAGE_TYPES` | landing: `layouts/demo/home/`, `layouts/marketing/`; showcase: kitchen sink, `layouts/demo/csp/`; visual: orbit; filter: `layouts/demo/filter/` |
| CSP audit | `CSP_PAGES` | `layouts/demo/` csp, search, code-github, orbit, filter |
| Contrast | `CONTRAST_PAGES` | `layouts/demo/code-github/` |
| RTL and English-only | `RTL_PAGES`, `EN_ONLY` | `components/kitchen-sink-rtl/`, `layouts/demo/error-rtl/` |
| Header and anchor offsets | `qa/audit/pages.mjs` | `HEADER_PAGES` has `layouts/marketing/pricing/`; `ANCHOR_PAGES` has `layouts/documents/legal/`; a code-wrap check runs on `layouts/blog-news/post/` |
| Layout checks | `qa/audit/layout/` | column-align: `layouts/demo/wide/`; table-reflow: `layouts/detail/`, `layouts/blog-news/` (indexes) |
| Mobile, keyboard, parts | `qa/audit/mobile.mjs`, `keyboard.mjs`, `parts.mjs` | the kitchen sink and its RTL twin |
| Coverage | `qa/docs/coverage.rb` | every alert type and status value must appear in `components/kitchen-sink*.md` |
| Structure | `qa/docs/structure.rb` | sample trees are exempt; demo pages must carry `nav_order` or `nav_exclude` |
| Unit tests | `test/layouts/features/lists_test.rb` | reads the kitchen-sink sources in three languages |

### 2. Starters and deployment today

- **Manifest:** `example/starters.yml` lists three starters:

  | Starter | Repository | Languages | Stacks | Check flags |
  |---|---|---|---|---|
  | docs | `modootoday/jekyll-theme-modootoday-docs-starter` | en, ko, ja | github-pages, jekyll4 | `--twins --byte-exact=api` |
  | blog | `modootoday/jekyll-theme-modootoday-blog-starter` | en | github-pages, jekyll4 | `--twins` |
  | landing | `modootoday/jekyll-theme-modootoday-landing-starter` | en | github-pages, jekyll4 | `--twins` |

- **Rake tasks:**
  - `rake starters:render[dir]` writes each starter per stack to `pkg/starters/<stack>/<name>/`, adding the remote_theme pin or Gemfile, the README, the Pages workflow and stubs.
  - `starters:check` fails on drift from a fresh render.
  - `starters:build[name]` builds the jekyll4 tree with this checkout and runs `modootoday-check` with the manifest flags.
- **The Starters workflow** builds a 3 × 2 matrix:
  - render, drift check, build and check, and a `url:` overlay for structured data;
  - for the classic tree, a `remote_theme` at the pushed commit, diffed against the gem build (CSS excluded);
  - a `pages-action` job that runs the real `actions/jekyll-build-pages` on each classic tree.
- **Nothing is published yet.** `gh repo view` answers "Could not resolve to a Repository" for all three repositories, and `gh api repos/<repo>/pages` answers 404.
- **The docs site** is classic GitHub Pages (`build_type: legacy`, source `main` `/docs`) at `https://modootoday.github.io/jekyll-theme-modootoday/`, with `remote_theme: modootoday/jekyll-theme-modootoday@main` and `csp: strict`.
  - The latest Pages build, for commit a1a13d0, reported `errored` ("Page build failed.") at 2026-11-04 15:18 UTC.
  - The site map plans a move to `https://theme.modoo.today` at the docs rebuild.

### 3. Market patterns

| Source | Preview form | Bar sticky | Trigger | Survives navigation | Dismissal | Link back | SEO on the demo | Notes |
|---|---|---|---|---|---|---|---|---|
| Bootstrap Themes (themes.getbootstrap.com, archived 2024-05) | iframe under a top bar (`navbar-preview fixed-top`, `iframe-preview`) | yes, fixed | separate URL `/preview/?theme_id=N` framing the author's demo (for example a GitHub Pages site) | yes, inside the frame | a close icon that goes to the bare demo URL | "View theme info", license picker, "Add to cart" | the preview page's canonical is `/preview/` without the query, so every preview collapses to one URL; the framed demos are the authors' own sites | desktop and phone width toggles. The marketplace is closing: store pages say "Bootstrap Themes is shutting down. Checkout is disabled." |
| ThemeForest (Envato) | iframe under a top bar on a separate host (`preview.themeforest.net/item/<slug>/full_screen_preview/<id>`) | yes | separate domain | yes, inside the frame | "Remove Frame" (the X at the top right) | item name, "Buy now" | the fetched response carried `robots: noindex,nofollow` | most pages answer 403 to non-browser clients, so the structure is from the fetched fragment and buyer comments |
| WrapBootstrap | unverified (403 to non-browser clients) | – | – | – | – | – | – | – |
| Tailwind Plus templates (tailwindcss.com/plus/templates) | real site on its own host, for example `salient.tailwindui.com`, `spotlight.tailwindui.com`; no bar | – | separate subdomain | – | – | none on the demo | `robots: index, follow`, no canonical | the template page links out to the demo |
| jekyllthemes.io | links out | – | "Live Demo" button, `target="_blank"` | – | – | none on the demo | the author's | a directory, not a host |
| Minimal Mistakes | real site; the docs site is the demo; starter `mm-github-pages-starter` is a template repo whose homepage is its own Pages site | – | – | – | – | – | self canonical, indexed | the same shape as the decided hosting |
| Just the Docs | real site; template repo `just-the-docs-template` with its own Pages site | – | – | – | – | – | self canonical | the same shape |
| Chirpy | `cotes2020/chirpy-starter` is a template repo; its homepage is the theme's demo `chirpy.cotes.page` | – | – | – | – | – | self canonical | the demo is the theme's own site, not the starter's build |
| Hugo themes (themes.gohugo.io) | "Demo" button links to the author's site, `rel="nofollow"`, same tab | – | – | – | – | – | the author's | PaperMod's demo is self canonical |
| Astro themes (astro.build/themes) | "Live demo" links out to the author's site | – | – | – | – | – | the author's | – |
| Shopify theme preview | the real storefront with a platform-injected preview bar | yes | a query parameter (`preview_theme_id`) with session persistence | yes | a hide control | to the theme editor | – | the query-parameter pattern [[adr:modootoday/20261104170401]] rejected |

What the survey shows:

- **Framed previews are the marketplace pattern.** They suit sellers who need a buy button beside a demo they do not host. They break the demo's own sticky header, focus order and full-screen behaviour, and the frame host marks itself `noindex` or collapses previews to one canonical.
- **Theme authors link to a real site.** Template repositories with their own Pages sites (Minimal Mistakes, Just the Docs) are exactly the decided hosting. Directories open the demo in a new tab (jekyllthemes.io) or in the same tab (Hugo).
- **No surveyed author puts a bar on the real demo.** A real-site bar with a link back is what platform previews do (Shopify). The decided showcase brings that to a static site without a query parameter.

Sources:

- Bootstrap Themes: [themes.getbootstrap.com](https://themes.getbootstrap.com/), [archived preview](https://web.archive.org/web/20240516173123/https://themes.getbootstrap.com/preview/?theme_id=19799), [sunset FAQ](https://glow-limpet-524.notion.site/Sunsetting-Bootstrap-Themes-Customer-FAQ-1c54f54098ac804e9d69d4b2d7c14bd5)
- ThemeForest: [preview host](https://preview.themeforest.net/item/avone-multipurpose-shopify-theme/full_screen_preview/24276567), ["Remove Frame" comment](https://themeforest.net/comments/484485)
- Tailwind: [Tailwind Plus templates](https://tailwindcss.com/plus/templates), [Salient demo](https://salient.tailwindui.com/)
- Jekyll themes:
  - [jekyllthemes.io theme page](https://jekyllthemes.io/theme/hexdump-jekyll-theme)
  - [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) and [its starter](https://mmistakes.github.io/mm-github-pages-starter/)
  - [Just the Docs](https://just-the-docs.github.io/just-the-docs/) and [its template](https://just-the-docs.github.io/just-the-docs-template/)
  - [Chirpy starter](https://github.com/cotes2020/chirpy-starter) and [Chirpy demo](https://chirpy.cotes.page/)
- Hugo and Astro: [Hugo PaperMod listing](https://themes.gohugo.io/themes/hugo-papermod/), [Astro theme listing](https://astro.build/themes/details/astrovault/)
- Shopify: [preview bar thread](https://community.shopify.com/t/how-can-i-remove-the-preview-bar-from-my-themes/9690)

### 4. Implementation risks found while reading the decided design

These do not change the decisions. They are what the implementation has to handle.

- **The classic builder has no config list.**
  - `actions/jekyll-build-pages` takes only `source`, `destination`, `future`, `build_revision`, `verbose` and `token`. There is no `--config`.
  - A github-pages-stack demo therefore cannot layer `_config.demo.yml` the way the decision words it.
  - Two ways out:
    - a workflow step merges the demo file into `_config.yml` inside the runner before the build action. The Starters workflow already edits a classic tree's config this way, with `ruby -ryaml`;
    - the demo deploy uses the jekyll4 stack, which runs `jekyll build --config`.
  - Pick the first: the demo should be what the published template builds.
- **A generated site copies the workflow too.**
  - "Use this template" copies `.github/workflows/pages.yml` and `_config.demo.yml`, so a generated site would layer the demo file and show the showcase.
  - The layering step needs a guard: `if: github.repository == 'modootoday/jekyll-theme-modootoday-<name>-starter'`. The renderer derives the name from the manifest.
  - Forks and generated repositories then build without the showcase. A test on the rendered workflow pins the guard.
- **Dismissal across pages and layout shift.**
  - The bar is server-rendered on every page. After a dismissal, the next page paints the bar and a deferred module then hides it, which moves the page up after first paint.
  - A pre-paint line in `<head>` that reads the session flag and sets an attribute on `<html>` prevents this. The theme already does this for the colour scheme (`theme-init.js`, loaded blocking under `csp: strict`).
  - Measured: today's `theme-init.js` with the extra line is 214 B gzip, against its 256 B cap.
  - Today that script loads only when the theme toggle is on, so the head condition must also include "showcase enabled".
- **Sheet size.** A draft sheet with both styles measured 797 B gzip, against 627 B for the bar alone and 686 B for the pill alone. Splitting saves about 110–170 B on a page but duplicates the shared rules and adds a registry row. One sheet, as the decision says, is right.
- **Small viewports.**
  - At 360 px landscape or 200% zoom, the 44 px bar plus the 64 px header take more than a third of the height.
  - A height query (for example `max-height: 30rem`) that drops the bar to `position: static` and resets the header offset keeps WCAG 1.4.10 reflow comfortable.
- **The canonical host will change.** `docs_url` will move to `https://theme.modoo.today` at the docs cutover. It lives in each starter's `_config.demo.yml`, rendered from one manifest value, so the cutover edits one place and re-renders.
- **Coverage gap.**
  - The three starters render 7 of the 32 layout-group demos: integrations (docs plugins), pricing and legal (landing), and blog, post, news and news-article (blog). The landing home also renders the `home` shell, and the docs plugins render the records demo.
  - The shell and feature demos are not starter content at all.
  - Most demos cannot move until the 13-starter catalog exists.

## Recommendation

### Which demo pages move, and what stays

- **They move only when a published starter renders the same layout with real content,** and in the change that publishes that starter, as [[adr:modootoday/20261104170556]] requires.
  - The first wave, with today's three starters: `layouts/marketing/pricing`, `layouts/documents/legal`, `layouts/directory/integrations`, and `layouts/blog-news/{blog,news,article}`.
  - The rest move as the catalog's starters publish (saas, portfolio, company, conference, course, podcast, newsroom, help-center and oss cover the remaining directory, detail, docs-extra and documents layouts).
- **They stay in the docs:**
  - **Feature demos** (`orbit`, `filter`, `csp`, `code-github`) demonstrate features, not layouts. The site map already moves each to the page that documents its feature.
  - **Shell demos** (`home`, `minimal`, `wide`, `error`, `error-rtl`, `redirect`, `search`) render the theme's own shells. They are test fixtures for every audit, and a starter would hide them under starter content.
  - **The kitchen sink and the RTL kitchen sink** are component reference and the coverage gate (`qa/docs/coverage.rb`). The rebuild replaces them with component group pages.
  - **Inline examples on component and layout pages** stay. A layout page keeps its front matter and composition reference, gains a "Live demo" link to the starter (new tab), and loses only the embedded demo page.
  - **The live sample trees** (`blog/`, `news/`, `authors/`, posts) feed the docs' own blog and news. They are not demos.
- **The links from the docs** use the theme's existing new-window link attributes (`target="_blank"`, `rel="noopener noreferrer"`, the localized new-window hint through `aria-describedby`, and the arrow mark). No new markup is needed.

### Redirects

- **An old demo URL redirects to its layout's docs page** (`/layouts/<group>/<layout>/`), never straight to the starter host.
  - A visitor who followed an old link lands on the docs page that explains the layout and links the live demo.
  - The old URL's meaning (a page about this layout) is kept, and no cross-site jump happens without a word.
- **Use the theme's `redirect` layout:** a meta refresh, a canonical to the target, `noindex`, and a visible link; no script, so it works under `csp: strict`.
  - Write the redirect stubs through the moves table and the `moved` alias kind the site map plans (one owner, generated per language), not by hand.
  - Until that alias kind exists, a hand-written `redirect_to:` stub per page and language is the stopgap, listed in the same table.
- **jekyll-redirect-from is not needed.** Classic Pages whitelists it, but the theme's own layout already covers both builders and the strict CSP.

### noindex or canonical on demo sites

- **Recommend `noindex` (with links followed) on every page of a starter demo, and no cross-host canonical.**
  - The demo's content is placeholder text that every generated site starts with, so indexing it competes with users' sites and with the docs.
  - A canonical that points to a different, non-equivalent page (the docs) is a hint that search engines ignore. Their guidance reserves it for duplicates.
  - The framed marketplaces that host previews mark them `noindex` or collapse them to one canonical. The demo sites that are indexed (Minimal Mistakes, Just the Docs) are documentation with unique content, which the starters are not.
- **Mechanism:** enabling the showcase also emits `<meta name="robots" content="noindex">`, because the showcase is on only in a demo build.
  - Front matter `defaults:` in `_config.demo.yml` cannot do it: Jekyll replaces the whole `defaults` array when it layers config files, and every starter's `_config.yml` has its own `defaults`.
  - If the showcase should stay independent of indexing, a separate `modootoday.noindex: true` site key does the same. Either way the decision lands in the showcase ADR's config, not in the starters.
- References: [Consolidate duplicate URLs](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls), [Block indexing with noindex](https://developers.google.com/search/docs/crawling-indexing/block-indexing).

### Release placement

- **1.5.0** is closing (items 07–10 and their follow-ups). Neither the showcase nor the starter publishing is in the 1.5.0 plan, and [[adr:modootoday/20261104170556]] puts publishing after 1.5.0.
- **1.6.0** covers items 11–14: static diagrams, math, charts and widgets. They touch the Markdown renderers, not the page chrome.
  - The showcase touches `_layouts/default.html`, the asset registry, the i18n catalogs and the checker's chrome keys. It overlaps item 14 only in the registry and catalogs, which is a merge order, not a conflict.
- **The implementation design** plans no starter-publishing or showcase item.
  - Its product section only mentions a template-repository button in the install guide.
  - The starter catalog and the docs rebuild are a later expansion phase, with the domain cutover at the rebuild release.
- **Recommendation:**
  - **1.6.0, as an additional item after 14:** the showcase feature (config key and checker, Liquid include, the sheet and the dismiss module with their caps, the pre-paint line, catalog keys, docs in en/ko/ja). Then publishing the three starter repositories, the docs' "Live demo" links, and the first wave of demo moves with redirects.
  - **The expansion phase:** later waves of demo moves, one per published starter. The docs rebuild then applies the site map's moves table for the shell and feature demos.
  - This keeps demo URLs from moving twice: a layout demo moves once, to its starter; everything else moves once, in the rebuild.

### Audit migration

- **One owner for demo page lists.**
  - `example/starters.yml` gains, per starter, the paths the audits open (for example `qa: [/, /pricing/, /legal/]`).
  - The demo URL is derived from the name, as decided.
  - `qa/audit/config.mjs`, `qa/visual/visual.mjs` and `qa/lighthouse/lighthouse.sh` read those paths instead of hard-coding them, per the structure rule that QA, visual and Lighthouse lists have one owner.
- **Audits run on starter builds with the demo overlay.**
  - The Starters workflow already builds every starter; it adds a build with `_config.demo.yml` and runs the audits on it.
  - The audit scripts already take a site directory (`qa/site/server.mjs` serves any built site).
- **Moved checks follow their pages:**
  - `HEADER_PAGES` (pricing) and `ANCHOR_PAGES` (legal) run on the landing demo. These are the checks that matter most for the bar, because it changes the header's sticky top and `scroll-padding-top`. Add one bar page and one pill page to the anchor check.
  - The landing page type (`layouts/demo/home/`, `layouts/marketing/`) gains the landing starter's home and keeps the shell demo until the rebuild.
  - `CSP_PAGES` gains one starter demo page, since the showcase adds a module and a sheet.
  - Lighthouse gains one bar and one pill demo page, mobile and desktop, to confirm CLS 0 with the showcase and after a dismissal.
  - Visual regression gains the bar and the pill at 360 and 1440 px, light and dark. The baselines are rendered from the base commit, so no image is committed.
- **Unchanged until the rebuild:** the kitchen sink checks (coverage, mobile, keyboard, parts, unit test), RTL and English-only lists, the column-align and table-reflow lists, and the feature-demo entries.
- **A test** fails when a page list names a docs demo that no longer exists, or a starter path the starter does not render.

### Effort

About 9–11 commits for the 1.6.0 part, plus maintainer steps:

| # | Commit | Size |
|---|---|---|
| 1 | Config key, checker schema entry, upgrade and configuration docs (en/ko/ja) | S |
| 2 | Liquid include, the sheet and registry row, the head pre-paint line | M |
| 3 | Dismiss module and its cap; catalog keys | S |
| 4 | `noindex` with the showcase (or the separate key) | S |
| 5 | Renderer: `_config.demo.yml`, the guarded layering step, the template flag in the README; render and drift tests | M |
| 6 | Starter `qa:` paths in the manifest; audit lists derived from them; Starters workflow audit job | M |
| 7 | Visual and Lighthouse entries for bar and pill | S |
| – | Maintainer: create the three repositories, mark them as templates, turn on Pages, first publish | outward |
| 8 | Docs: "Live demo" links on layout pages (en/ko/ja) | S |
| 9 | First-wave demo moves with redirect stubs; page lists updated; `git grep` for every removed path | M |

Risks:

- the classic-builder layering and the template guard (section 4);
- publishing depends on a manual step until a publish task exists, so demos can lag the release;
- with the theme pinned to a tag, a demo shows the released theme, which is intended;
- 23 language catalogs need the new keys, with English fallback;
- the docs Pages build currently reports `errored`, which should be cleared before docs links point to new demos;
- the canonical host change at the cutover means one manifest edit and a re-render.

## Outcome

These recommendations were decided in [[adr:modootoday/20261104171141]], with the map in [[sot:modootoday/docs-demo-to-starter-map]] and the repository layout in [[adr:modootoday/20261104171142]]. The decision differs from this research in two places:

- **Every demo moves**, shell, feature and record demos included, each to its final starter in waves.
- **Moved shell, feature and record URLs redirect to the starter page**, not to a docs page. Layout demo URLs keep a reference page, so they need no redirect.

The recommendations as written before the decision:

1. **Which docs demo pages move.** Recommend: only layout-group demos, each in the change that publishes a starter rendering it. The first wave is pricing, legal, integrations, blog, news and news article. Shell demos, feature demos, the kitchen sinks and the sample trees stay until the rebuild.
2. **Redirects.** Recommend: an old demo URL goes to its layout's docs page through the theme's `redirect` layout, generated from the site map's moves table. It never jumps straight to the starter host.
3. **noindex or canonical.** Recommend: `noindex` on every demo page, emitted by the theme when the showcase is enabled, with no cross-host canonical. The alternative is a separate `modootoday.noindex` key.
4. **Release placement.** Recommend: an additional 1.6.0 item after item 14 for the showcase and the first publish, and later waves in the expansion phase.
5. **Audit migration.** Recommend: per-starter `qa:` paths in `example/starters.yml` as the one owner, audits on demo-overlay builds in the Starters workflow, and the header and anchor checks moved to the landing demo with one bar and one pill page.

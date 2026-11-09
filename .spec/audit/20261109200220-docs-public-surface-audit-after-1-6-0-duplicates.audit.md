---
id: audit:modootoday/20261109200220
title: "Docs public surface audit after 1.6.0: duplicates, inconsistencies and drift from the code"
status: active
created: 2026-11-09T20:02:20Z
updated: 2026-11-09T20:02:20Z
rel:
  governs: [docs]
---

# Docs public surface audit after 1.6.0: duplicates, inconsistencies and drift from the code

Read-only audit of the jekyll-theme-modootoday documentation site (`docs/`), README, RULES, AGENTS and CONTRIBUTING, at theme `main` 629e9f7 (2026-11-09), plus the live site at https://modootoday.github.io/jekyll-theme-modootoday/. Nothing was edited, built or committed.

Inputs read: adr:modootoday/20261030083000 (docs IA), sot documentation-site-map, adr:modootoday/20261109141344 (component order), research:modootoday/20261109150011 (governance and docs drift), `docs/_data/sections.yml`, `docs/_data/nav/*.yml`, `docs/_data/components.yml`, the checker schema (`lib/modootoday/check/config/keys*`), `exe/modootoday-check --help`, `exe/modootoday-stubs --help`, `_layouts/`, `_includes/` (keys read by Liquid), and every English page with its `.ko.md` / `.ja.md` sibling.

Method notes:

- Translation staleness was recomputed with the theme's own `Modootoday::I18n::SourceRev.of` against each English source (approximation of `modootoday-check --i18n-pages`; that command needs a built site).
- Config keys: the 36 keys the checker schema registers were compared with the keys Liquid reads as `site.modootoday.<key>` (49) and with the Configuration guide's key table.
- "Conflicts with component-order work" = touches `docs/components/*`, the kitchen sinks, `docs/_data/components.yml` or the recipes sidebar regroup (adr:modootoday/20261109141344, adr:modootoday/20261109124854). Those findings should be folded into that item or wait for it.

Severity: **blocker** = wrong or misleading for a reader today, or breaks an active rule; **major** = visible duplication or drift a reader will hit; **minor** = polish, consistency, agent/SEO readability. Effort: S (under 2 h), M (half a day to a day), L (more).

## Summary counts

| Category | blocker | major | minor | Total |
| --- | --- | --- | --- | --- |
| Duplicate / overlap | 0 | 6 | 3 | 9 |
| Inconsistency: terminology | 0 | 2 | 4 | 6 |
| Inconsistency: formatting | 0 | 0 | 5 | 5 |
| Inconsistency: navigation | 0 | 3 | 5 | 8 |
| Inconsistency: en/ko/ja parity | 0 | 1 | 2 | 3 |
| Inconsistency: version mentions | 2 | 1 | 2 | 5 |
| Outdated vs code | 1 | 3 | 3 | 7 |
| Optimization | 0 | 3 | 6 | 9 |
| **Total** | **3** | **19** | **30** | **52** |

## 1. Duplicate or overlapping pages

| Id | Category | Evidence | Sev | Proposed fix | Effort | Conflicts with component-order work |
| --- | --- | --- | --- | --- | --- | --- |
| D1 | Duplicate | `docs/components/index.md` (502 lines, 21 KB) and `docs/components/kitchen-sink.md` (493 lines, 15 KB) cover the same components; 17 paragraphs over 80 characters are byte-identical (about 3.4 KB). Example: the `## Subscribe` paragraph "`status:available` A `c: subscribe` section prints its text and an email form…" is in both (index l.387, kitchen sink l.459). | major | Canonical: Components index (prose + example per component). Kitchen sink becomes a pure visual-review page: headings and examples only, no explanatory prose, with a one-line link back to the index entry. A test can assert that no paragraph over N characters appears in both. | M | **Yes**: do it inside the component-order item |
| D2 | Duplicate | The same component under different headings in the two pages: index "Cards" / sink "Cards in two columns"; "Badges" / "Status badges"; "Code blocks" / "Code"; "Steps" / "Steps as a list"; "Buttons" (index) / "Call to action" (sink) for `c: cta`. | major | Headings follow one rule: the component's display name from the canonical list, then an optional variant ("Cards, three columns"). Generate both pages' heading lists from the component-group data file. | S | **Yes** |
| D3 | Duplicate | Install snippets in three places with different shapes: README "Install" (block-list `plugins:`), `docs/index.md` "Quick start" (flow list, adds `permalink: pretty`), `docs/guides/install.md` "Choose a method" plus "Minimal configuration" (adds `lang`, `markdown`, `kramdown`, `sass`, `defaults`). README "Quick start" uses yet another `_config.yml` with no `permalink:`. | major | Canonical: Install guide. Home keeps only the two pin lines (already version-tested) and links to Install; README keeps its pin block (version-tested) and links. Use one YAML shape everywhere (flow list `plugins: [jekyll-remote-theme]`). | S | No |
| D4 | Duplicate | Markdown twins are explained in six places: `guides/agents.md` "Markdown twins" (l.15-51), `RULES.md` §5a (l.89-133), `guides/upgrade.md` "## Markdown twins" (l.31-39, the three ways), `guides/install.md` "Verify the build" (l.66, stubs and llms files), README "AI agents" and "Concepts > Twins: three ways", `recipes/system/index.md` (twins for error pages). | major | Canonical: Agents guide (user-facing) with the "three ways" table moved there from upgrade.md; RULES §5a keeps only the normative contract and links the guide; upgrade and install keep one sentence plus a link. | M | No |
| D5 | Overlap | Token bridge in two pages with different examples: `guides/customize.md` "## Token bridge" (l.57-82) and `recipes/brand-tokens.md` "## The token bridge" (l.14-43). Brand tokens never links Customize; Customize links Brand tokens. | major | Canonical reference: Customize "Token bridge" (maps, allowed tokens, CJK font stacks). Brand tokens stays a task recipe (a full palette, a font, contrast, CSP) and opens with "the maps are described in Customize > Token bridge". | S | No |
| D6 | Overlap | Six one-paragraph "site type" recipes (`recipes/{marketing,company,docs,personal,community,system}/index.md`, 10 lines each) restate their Layouts group pages. Example: `recipes/system/index.md` ("Add `404.md` with `layout: error`, use `redirect`…") repeats `layouts/shells.md` "Error", "Redirect", "Search"; `recipes/docs/index.md` repeats `layouts/docs-extra/index.md`. Each is a group directory with only an index and no child pages. | major | Merge the six into one "Site types" recipe page (one `##` per site type, each linking its layout group), or move each paragraph to the top of its Layouts group page as "Building a … site". Keep every published URL with a redirect stub. This also brings the recipes sidebar from 13 to 8 entries. | M | **Yes**: this is the recipes regroup |
| D7 | Overlap | Contributor translation rules in two places: `TRANSLATING.md` (checklist, register line, `source_rev`) and `docs/guides/translation.md` (register table, glossary, rules). TRANSLATING repeats the register ("Korean docs: 합니다체 … Japanese: です・ます"). | minor | Keep the split (TRANSLATING = contributor checklist, guide = canonical rules) but remove the register line from TRANSLATING and link the guide's "Register" heading. | S | No |
| D8 | Overlap | `docs/reference/api.md` "## Markdown rules" is one sentence about the name `md-components v1`; `guides/first-page.md` "The rules in one minute" is a 4-row summary; the full rules live only in `RULES.md` on GitHub (not on the docs site). | minor | Canonical: RULES.md. Publish it (or a generated copy) on the docs site under Reference so readers and llms.txt reach it; api.md and first-page link there. | M | No |
| D9 | Redirect stubs | `docs/recipes/records/{index,compass,ledger,lantern,relay,stamp}.md` are clean redirect stubs (front matter only, `nav_exclude`, `sitemap: false`, `twin: false`) to the docs starter's `/plugins/…`. They carry no content: OK. But they occupy a group directory with no real page, and their titles ("Compass", "Records list") say nothing. | minor | Keep as stubs; set `title:` to "Moved: …" for clarity and keep them excluded from llms.txt. When the recipes regroup lands, move them under one `recipes/moved/` folder or a `_redirects` data file if the regroup adds one. | S | **Yes** (recipes regroup) |

## 2. Inconsistencies

### 2a. Terminology

| Id | Category | Evidence | Sev | Proposed fix | Effort | Conflicts |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | Terminology | Component id vs display name: `c: features` is shown as "Cards", `c: cta` as "Buttons" (index) and "Call to action" (sink), `c: params` as "Parameter table", `alert` renders as `.mt-callout` and the components key list uses `callout` (`components: [callout, badge, cta, card, tabs]`, configuration.md l.22) while the page heading is "Alerts". | major | One glossary row per component: id, display name, CSS block. Headings use the display name and show the id in the first line ("`c: features`"). The component-group data file holds the display name. | M | **Yes** |
| T2 | Terminology | The agents guide has four names: front matter `title: For agents`, `nav_title: Agents`, H1 "Agent-readable Markdown", and links elsewhere say "For agents" (install.md l.66), "Agents" (roadmap, upgrade), "Agents guide" (README). | major | Pick one title ("AI agents" or "Agent-readable Markdown"), use it as `title`, H1 and link text; drop `nav_title` unless the label is genuinely shorter. | S | No |
| T3 | Terminology | Spelling mixes British and American: "colour(s)" 59 times (customize "Code colours", charts "Colours", demo "GitHub code colours") vs "color(s)" in prose (customize `description:` "Change colors, radius and fonts", marketing index "each color", brand demo). RULES.md uses "Localisation". | minor | Choose one variety (the majority is British for prose; keys stay as they are) and add it to the glossary; a cheap regex test flags the other spelling outside code. | S | Partly (kitchen sink text) |
| T4 | Terminology | Optional CSS bundles have five names: "optional stylesheet" (7), "optional sheet" (5), "pages bundle", "optional bundle", and AGENTS.md "module sheet". | minor | Glossary term "optional stylesheet" (with the file name); replace the others. | S | No |
| T5 | Terminology | Product name: site title and translation guide say "modoo.today theme"; README H1, README prose and docs home body say "jekyll-theme-modootoday"; docs home H2 "Why modoo.today theme". Starter wording mixes "starter site", "starter", "template repository". Moved records point at `/plugins/` while the docs call them "records". | minor | Glossary: product name = "modoo.today theme", package name = `jekyll-theme-modootoday` (code only); "starter site" (a template repository) as one defined term; "record set" vs the starter's "plugins" example named as such. | S | No |
| T6 | Terminology | "Migrate" vs "upgrade": URL `/guides/upgrade/`, title "Migrate and upgrade", nav label "Migrate" (ko "이전", which also reads as "previous"). The upgrade table and changelog page say "upgrade". | minor | Nav label = title ("Migrate and upgrade"), or rename the page "Upgrade and migrate" to match the URL; ko label "마이그레이션과 업그레이드" or "이전과 업그레이드". | S | No |

### 2b. Formatting

| Id | Category | Evidence | Sev | Proposed fix | Effort | Conflicts |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | Formatting | Link style: 42 links hard-code the base URL (`](/jekyll-theme-modootoday/layouts/directory/)`) in 13 files, all under `docs/layouts/*` plus `404.md`; the other 166 internal links are relative (`../configuration/`). A fork or a base URL change breaks the absolute ones. | minor | Relative links only in page bodies (TRANSLATING already requires URL-relative links in translations); a regex test rejects `](/jekyll-theme-modootoday/`. | S | No |
| F2 | Formatting | Front matter key order and quoting vary: guides put `nav_order` first, sections put `title` first; layout demo titles are quoted in 15 files (`title: "Jobs demo"`) and unquoted in the rest. | minor | Front matter contract (rule R3) with a fixed key order: `title, description, nav_order|nav_exclude, nav_title, layout, …`; quote only when YAML needs it. A formatter or test can enforce it. | S | No |
| F3 | Formatting | Duplicate heading inside one page: `guides/first-page.md` has two `## Next` headings (l.41 inside the example, l.60 real). The first is inside a fenced example, but the outline and anchors (`#next`, `#next-1`) still suffer in some renderers and in llms-full. | minor | Rename the real one "What to read next". | S | No |
| F4 | Formatting | Hand-written "Back to …" links on 9 pages only (`layouts/directory/{team,jobs,sponsors,portfolio,events}.md`, `layouts/demo/minimal.md`, `reference/changelog.md` "[Back to home](../../)"), while breadcrumbs and previous/next exist on every doc page. | minor | Remove the manual back links, or add them consistently via the layout. | S | No |
| F5 | Formatting | Callouts: 26 GitHub alerts in en docs, used for very different weights (`[!IMPORTANT]` on the frozen changelog page for "The rules are final…"; most guides have none). No guidance on when to use which type. | minor | Callout rule in the docs style section: NOTE = side info, TIP = shortcut, IMPORTANT = required step, WARNING = data loss or breakage, CAUTION = security; at most two per page. | S | No |

Code-fence info strings were consistent: every opening fence in en docs carries a language word (yaml 83, sh 27, markdown 11, …). Headings: ko/ja pages mirror the English heading structure exactly on all 196 translations (same count and levels).

### 2c. Navigation

| Id | Category | Evidence | Sev | Proposed fix | Effort | Conflicts |
| --- | --- | --- | --- | --- | --- | --- |
| N1 | Navigation | Recipes sidebar has 13 entries (`docs/_data/nav/main.yml`), over the 12 cap of adr:modootoday/20261030083000; `test/system/docs/structure.rb` carries `ENTRY_LIMITS = { "recipes" => 14 }`. | major | Regroup to 12 or fewer (see D6) and delete the exception, as adr:modootoday/20261109141344 already decides. | M | **Yes** (that item) |
| N2 | Navigation | The Components sidebar has one entry ("Kitchen sink"); the 40+ components live as `##` sections of a 502-line page, so the sidebar and llms.txt do not expose any component by name. | major | Covered by the component-order item; longer term, the purpose groups of adr:modootoday/20261109141344 can become sidebar groups (7 groups, each ≤12). | L | **Yes** |
| N3 | Navigation | Layout pages mix two kinds under "demo" groups: 5 reference pages using `layout: layout-reference` (Blog layout, Post layout, Integrations layout, Legal layout, Pricing layout) and 30+ live demos ("Feature demo", "Team demo"). Most layouts are documented in their group index (`layouts/detail/index.md` documents all five detail layouts), but these five get their own page. | major | One pattern: the group index documents every layout's front matter; each child page is a live demo titled "<Name> demo". Or give every layout its own reference page. Pick one in the docs ADR. | M | No |
| N4 | Navigation | Tied `nav_order`: `layouts/blog-news/index.md` and `layouts/docs-extra/index.md` both 50, so order falls back to path. Recipes use ad-hoc steps (10, 15, 20, 25, 26, 27, 28, 30…). | minor | Unique orders in steps of 10 per section; a test rejects ties. | S | Partly (recipes) |
| N5 | Navigation | Titles vs nav labels vs H1: "First page" vs H1 "Write your first page"; "Content Security Policy" vs nav "CSP"; "For agents"/"Agents"/"Agent-readable Markdown" (T2); demo `title:` "Yearly archive", "News front page" vs nav "Archive demo", "News demo"; error-demo H1 empty. | minor | Rule: H1 = `title`; `nav_title` only for a shorter form of the same words. A test compares `title` with the first `# ` heading. | S | No |
| N6 | Navigation | Orphans: `layouts/demo/index.md` (nav_exclude, zero inbound links; its hand-written list omits `error-rtl`), `layouts/demo/error-rtl.md` (no inbound link), `layouts/demo/home.md` (a redirect reachable only from the orphan index). | minor | Link the demo index from Layouts and Page shells, or delete it and let each demo be linked from the page that documents its layout; generate its list. | S | No |
| N7 | Navigation | Reference section mixes docs with sample-site pages: "Tags" and "Categories" (archive pages of the sample blog, `nav_section: reference`) sit between "Public API" and "Changelog". | minor | Move Tags/Categories out of the docs nav (they belong to the sample blog), or list them last under a "Sample site" label. | S | No |
| N8 | Navigation | `guides/index.md` says "Start here, in order." but the list ends with contributor material ("Translation rules") and deep topics (Structured data, Performance). | minor | Split Guides into "Getting started" (Install, First page, Configuration, Customize) and "Topics"; move Translation rules to a Contributing area or Reference. | S | No |

### 2d. en/ko/ja parity

| Id | Category | Evidence | Sev | Proposed fix | Effort | Conflicts |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | Parity | `source_rev` recomputation: 166 current, 30 stale, 0 unstamped. Stale ko+ja: `guides/accessibility`, `guides/customize`, `guides/structured-data`, `guides/upgrade`, `index` (10 files); plus all 20 `docs/home/index.<lang>.md`. Install pins drive part of it (research G3). | major | Bring the 10 ko/ja files up to date and stamp; land B10 (normalize version pins in the hash) so releases stop marking home pages stale; run `--i18n-pages` in push CI as a report (research B11). | M | No |
| P2 | Parity | English-only pages with no ko/ja: `404.md`, `components/kitchen-sink-rtl.md`, `layouts/demo/error-rtl.md` (intentional), and the 6 records redirect stubs. Fine, but there is no declared list of intentional exceptions, so a checker cannot tell "intentional" from "forgotten". | minor | Front matter `translate: false` (or reuse `twin: false` semantics) on intentional English-only pages; the parity test requires ko/ja for every other page. | S | Partly (RTL kitchen sink) |
| P3 | Parity | README has en and ko (`README.ko.md`) but no ja, while docs are en/ko/ja and TRANSLATING lists README.ko only. | minor | Decide in the docs ADR: either README is en+ko by design (state it) or add README.ja.md under the same readme test. | S | No |

### 2e. Version mentions

| Id | Category | Evidence | Sev | Proposed fix | Effort | Conflicts |
| --- | --- | --- | --- | --- | --- | --- |
| V1 | Version | `docs/reference/changelog.md` (en/ko/ja, live) still holds only "## 1.0.0 (first release)" six releases later, with `[!IMPORTANT] The rules are final as md-components v1`. Research G4. | blocker | Generate the page from CHANGELOG.md (research B5), or reduce it to a link plus the latest release summary generated at release-prep. | M | No |
| V2 | Version | `docs/reference/roadmap.md` opens "## Supported in 1.0" with a 1.0-era component list (no charts, widgets, static figures, records, 40 layouts); "## Next" is one generic bullet. Research G4. | blocker | Rewrite as "Supported now" (no version in headings) generated or tested against components.yml and the layouts list; "Next" names the next minor's themes from its scope ADR (research B6). | S | No |
| V3 | Version | Stack floor stated three ways: roadmap "Jekyll 3.9 is the oldest supported version", README "Jekyll 3.9 is the tested floor", AGENTS.md "github-pages 232, Jekyll 3.10 … and Jekyll 4" (no floor). | major | One sentence in one place (Install guide "Requirements"), reused by README via the version include or a generated block; a test pins the three. | S | No |
| V4 | Version | Hand-kept per-release rows: `guides/upgrade.md` table "1.5 \| 1.6 \| Pin `~> 1.6` (… `@v1.6.0`)" and "What each one adds" bullets (1.1 has none). Each release adds a row by hand. | minor | Generate the table from CHANGELOG headings or from fragments with `migration:` (research C6). | M | No |
| V5 | Version | "Since 1.5"/"Since 1.6" in running text: `guides/customize.md` l.153 "Since 1.5 the core sheet holds only…", `guides/structured-data.md` l.94 "Since 1.6 what it breaks…". Not banned (the ban is on future versions), but they age into noise. | minor | Version rule: past versions only in Upgrade and Changelog; elsewhere describe current behaviour. | S | No |

## 3. Outdated content against the code

| Id | Category | Evidence | Sev | Proposed fix | Effort | Conflicts |
| --- | --- | --- | --- | --- | --- | --- |
| O1 | Outdated | `docs/reference/api.md` "Stable names > Layouts" lists only `default, doc, page, post, archive, twin, llms, llms-full`, while `_layouts/` ships 46 layouts and the Layouts section documents about 38 of them (home, blog, news, team, pricing, legal, resume, reference, …) as public. Readers cannot tell whether `layout: pricing` is stable. | blocker | List every documented layout as stable (or state which are experimental), generated from `_layouts/` minus an internal list (`detail`, `directory` bases); a test compares the list with `_layouts/`. | S | No |
| O2 | Outdated | 13 keys the theme reads as `site.modootoday.<key>` are not in the checker schema (36 keys): `authors`, `external_links`, `favicon`, `language_switcher`, `logo`, `og_image`, `theme_color`, `viewport_fit` (not validated anywhere) and `blog`, `news`, `math`, `mermaid`, `subscribe` (validated ad hoc in `check/layouts/blog.rb`, `check/config/renderers.rb`, `check/page/component_rules.rb`). The research's "26/26 keys documented" understates the surface. | major | Register every key in `config/keys/` (even type-only) so one list drives validation, the Configuration table and the doctest (research B7/B8). | M | No |
| O3 | Outdated | `modootoday.authors` (`false` hides bylines; `_includes/modootoday/blog/config.html` l.8) is documented nowhere in docs; `tokens_dark` has no row in the Configuration key table (only prose). | major | Add both rows; the doctest of O2 keeps it complete. | S | No |
| O4 | Outdated | No docs page for the checker CLI: its 13 options appear only in README (generated) and scattered across 19 pages; `--github-pages`, `--gh`, `--json` (stubs) appear in no docs page. Public API says "Checker: modootoday-check options" without linking a list. | major | Add `reference/cli.md` generated from `--help=markdown` (the README generator already exists), en/ko/ja sharing the table; README and api.md link it. | S | No |
| O5 | Outdated | `RULES.md` §5 heading signature `modootoday-check SRC SITE [--twins] [--github-pages[=VER]] [--strict] [--gh]` lists 4 of 13 options. | minor | Drop the option list from the heading and link the CLI reference. | S | No |
| O6 | Outdated | `layouts/docs-extra/index.md` description "Reference, changelog, roadmap, glossary, hub, course and book pages" omits the API reference demo in the same group; two demos (`api.md`, `reference.md`) show the same `reference` layout. README says "About 40 layouts". | minor | Description from the child list; name the second demo "Reference with packages demo". Replace "about 40" with the generated count. | S | No |
| O7 | Outdated | `layouts/shells.md` (en/ko/ja) examples link `url: /install/` and `/components/`, the pre-IA root URLs. They are sample values for a user's site, but readers copy them into this site's context. | minor | Use neutral paths (`/docs/start/`) in examples. | S | No |

## 4. Optimization opportunities

| Id | Category | Evidence | Sev | Proposed fix | Effort | Conflicts |
| --- | --- | --- | --- | --- | --- | --- |
| X1 | Too long | `recipes/math-diagrams.md` 281 lines, 4 levels of headings (`####` "Where the browser runs"), covering static diagrams, image figures, static math, built-in loaders and own loaders. | major | Split into "Static figures" (diagrams, images, math) and "Diagram and math loaders"; keep the anchors via short pointers. | M | Partly (recipes regroup) |
| X2 | Too long | `components/index.md` 502 lines with a 54-line `sections:` front matter; `guides/configuration.md` 231 lines whose "Starter demo showcase" section (l.127-172, 45 lines) documents a demo-only feature. | major | Components: per-group pages after the order item. Configuration: move "Starter demo showcase" to its own page under Reference or Recipes and keep one row in the key table. | M | Components part: **Yes** |
| X3 | Too thin | Six 10-line site-type recipes (D6), `reference/changelog.md` (26 lines, see V1), `reference/index.md` ("Look things up here."), `layouts/docs-extra/{changelog,course,glossary,hub,reference,roadmap}.md` demos with one-line bodies but separate nav entries (8 entries in the group). | minor | Merge per D6; reference index gets one line per page; docs-extra demos can stay (they are live demos) but the group index should say so. | S | Partly |
| X4 | Sidebar cap | Recipes 13 (over, N1); Guides 10 and Layouts > Docs extras 8 are the nearest after; Layouts top level 8 entries with 41 descendants. Components 1 entry (N2). | major | After N1, add a structure test warning at 11 so growth is seen before it fails. | S | **Yes** (recipes) |
| X5 | Weak titles/descriptions | Generic descriptions in llms.txt and meta: "Releases of jekyll-theme-modootoday." (Changelog), "Public names, changes and plans." (Reference), "Short how-tos for one task each." (Recipes), "Every post on this site, grouped by tag." (Tags, a sample page); the author page has no description in llms.txt at all; Translations entries are "ar pages", "de pages". | minor | Description rule (R3): 70-160 characters, says what the reader can do or find, no repetition of the title. A test enforces length and non-empty. | S | No |
| X6 | llms.txt structure | Live `/llms.txt` lists pages alphabetically by path in one "Docs" list, mixing sample-site pages (Blog, News, "modoo.today theme team", Tags, Categories) with docs, and includes only 3 of 35 layout demos (Event demo, Events demo, API reference demo have twins; the others are `twin: false`). | minor | Group llms.txt by `sections.yml` (Guides, Components, Layouts, Recipes, Reference) in nav order; move sample sites to an "Optional" section per the llms.txt convention; set `twin:` consistently on demos (all false, or all true). | M | No |
| X7 | Missing cross-links | `guides/agents.md` links no other docs page (only llms files and llmstxt.org); `recipes/brand-tokens.md` does not link Customize; `guides/translation.md` links no docs page; `recipes/search.md` does not link the `search` key in Configuration; `guides/accessibility.md` links only Configuration. | minor | "See also" rule: every guide and recipe links its canonical neighbours (the overlap pairs of section 1). A test can require at least one internal link per guide/recipe. | S | No |
| X8 | Twin flag inconsistency | Layout demos: 35 set `twin: false`, 8 inherit the default twin (blog, post, event, events, integrations, api, legal, pricing). | minor | Rule: reference pages have twins, pure demos do not; fix the three demos (event, events, api) to match. | S | No |
| X9 | README guide list | README "Guides" line lists 21 links but omits Agents, Search, Brand tokens, Layouts groups other than Blog and news, and links Changelog to CHANGELOG.md while the site has a Changelog page. | minor | Generate the README guide line from `sections.yml` (section links only), like `readme-commands`. | S | No |

## 5. Top 10 findings (by reader impact, then effort)

1. **V1** Changelog page frozen at 1.0.0 on the live site (blocker).
2. **V2** Roadmap "Supported in 1.0" with a 1.0 component list (blocker).
3. **O1** Public API lists 8 stable layouts while ~38 are documented and shipped (blocker).
4. **D1/D2** Components index and kitchen sink duplicate 17 paragraphs and name the same components differently (major, in-flight item).
5. **N1/D6** Recipes sidebar over the cap, caused by six thin site-type recipes that duplicate Layouts groups (major, in-flight item).
6. **O2/O3** 13 config keys outside the checker schema; `authors` undocumented, `tokens_dark` missing from the key table (major).
7. **D4** Markdown twins explained in six places (major).
8. **P1** 10 stale ko/ja guides and home pages, plus 20 stale home translations (major).
9. **O4** No CLI reference page on the docs site (major).
10. **T1/T2** Component ids vs display names, and four names for the agents guide (major).

## 6. Proposed docs consistency rules (for one ADR)

| # | Rule | How to check it automatically |
| --- | --- | --- |
| R1 | **One canonical page per topic.** A topic map (`docs/_data/topics.yml`: topic → canonical page, plus pages allowed to summarize it in at most one paragraph with a link). | Test: no paragraph over 200 characters appears byte-identical in two pages (catches D1); each non-canonical page that mentions a mapped topic's key phrase links the canonical URL. |
| R2 | **Glossary of terms.** `docs/_data/glossary.yml` (or extend `i18n/glossary.yml` with an `en` "avoid" column): product name, starter site, Markdown twin, optional stylesheet, component id vs display name, spelling variety. | Regex lint over en docs outside code: fail on "avoid" terms (e.g. "pages bundle", "colour" or "color", whichever loses); same mechanism the i18n lint already uses for ko/ja. |
| R3 | **Front matter contract.** Required `title` (= the H1 text), `description` (70-160 chars, not the title repeated), integer unique `nav_order` or `nav_exclude`, `nav_title` only as a shorter form; fixed key order; demos declare `twin:` explicitly. | Extend `structure.rb`: length bounds, H1 = title, unique `nav_order` per group, `nav_title` words ⊂ title words, explicit `twin:` under `layouts/`. Run it on push (research B1). |
| R4 | **en/ko/ja parity.** Every page has ko and ja siblings unless it sets `translate: false`; translations mirror the English heading tree; `source_rev` stale is a warning on push and a failure at release for ko/ja. | Already have `source_rev` and heading parity is cheap: compare heading level sequences; `--i18n-pages --strict` limited to ko/ja in release-prep; normalize version pins in the hash (research B10). |
| R5 | **Version-mention rule.** User docs name no future version (exists) and no past version outside Upgrade and Changelog; headings never carry a version; Changelog and Roadmap pages are generated or tested against the current version. | Extend `BANNED` with `/\b(since|in) 1\.\d+\b/i` and `/^#+ .*\b1\.\d+/` outside `guides/upgrade` and `reference/changelog`; generated changelog data with `--check` (research B5/B6). |
| R6 | **Docs follow the code registries.** Every config key, layout, component and CLI flag in the code appears in its reference table, and every documented one exists. | Doctests: schema keys ↔ Configuration table (after registering all keys, O2); `_layouts/` ↔ Public API layout list; `components.yml` ↔ component headings; `--help=markdown` ↔ generated CLI page. |
| R7 | **Navigation shape.** Sidebar groups ≤12 with a warning at 11; no group directory with only an index; no orphan page (every `nav_exclude` page has an inbound link or is a redirect); sample-site pages stay out of docs nav and llms.txt "Docs". | `structure.rb` plus a link-graph pass over the source (no build needed: resolve relative links from front matter URLs). |
| R8 | **Link style.** Internal links relative to the page URL; no hard-coded base URL; guides and recipes have at least one link to a related docs page. | Regex on `](/jekyll-theme-modootoday/`; count internal links per guide/recipe. |

## Scope notes

- Not checked: rendered output and anchors (need a build), external links, the 20 home-page languages' content beyond staleness, and the starter repositories.
- The component-order and recipes-regroup items should absorb D1, D2, D6, D9, T1, N1, N2, X2 (components part) and X4, so that cleanup does not race them.

## Status after the 1.7.0 cleanup

Findings stay as written above; this table records what the 1.7.0 docs cleanup did with each. Checks are those of [[adr:modootoday/20261109212622]].

| Id | Status | Note |
| --- | --- | --- |
| D1 | fixed | Kitchen-sink leads are short sample lines; R1 blocks a repeated paragraph |
| D2 | fixed | Kitchen-sink headings use the Components page names |
| D3 | fixed | README uses the flow-list `plugins:` line and links Install; Home keeps its pinned tabs |
| D4 | fixed | AI agents is canonical with the three-ways list; Upgrade and README link it; RULES §5a stays the contract and links the guide |
| D5 | fixed | Customize holds the map table; Brand tokens links it |
| D6 | resolved | One Site types recipe with a section per site type; the six old URLs redirect through `moved_from` ([[adr:modootoday/20261109225554]]); R7 reports no index-only group |
| D7 | deferred | Minor; TRANSLATING.md not on the cleaned pages |
| D8 | resolved | reference/rules is generated from RULES.md by script/docs-index, with --check; api, first-page and agents link it ([[adr:modootoday/20261109225554]]) |
| D9 | deferred | Records stubs are generated; their titles change with the generator |
| T1 | fixed | Headings use display names, first lines show the id, glossary rows for callout, cta, features, params |
| T2 | fixed | "AI agents" in title, H1, nav and links |
| T3 | fixed | "color" in English pages; avoid.en lint |
| T4 | fixed | "optional stylesheet"; avoid.en lint |
| T5 | deferred | Product name wording left as is; glossary already names it |
| T6 | fixed | Nav label is the title; ko "마이그레이션과 업그레이드" |
| F1 | fixed | Relative links; R8 blocks the base URL (error pages exempt) |
| F2 | deferred | Key order reported by R3, about 190 pages differ |
| F3 | fixed | "What to read next" |
| F4 | deferred | Manual back links left |
| F5 | deferred | A callout-weight rule needs a style decision |
| N1 | fixed | On main ([[adr:modootoday/20261109192542]]) |
| N2 | deferred | Component sidebar groups need a decision (L) |
| N3 | resolved | Each group index holds the front matter table and links each demo; the five reference pages are demo pages at the same URLs ([[adr:modootoday/20261109225554]]) |
| N4 | fixed | Unique orders; R3 blocks ties |
| N5 | fixed | H1 equals title outside demos; nav_title only as a shorter form |
| N6 | partly fixed | The demo index is linked from the CSP demo; error demos are exempt as error pages |
| N7 | fixed | Tags and Categories left the Reference sidebar; R7 blocks sample pages in docs nav |
| N8 | resolved | Guides keep their URLs; Install, Configuration and Migrate and upgrade come first in the sidebar, topic guides after ([[adr:modootoday/20261109225554]]) |
| P1 | fixed | All ko/ja stamps current after review |
| P2 | deferred | A `translate: false` flag is a new contract |
| P3 | deferred | README.ja.md needs a decision |
| V1 | fixed | Generated release list ([[adr:modootoday/20261109204422]]) |
| V2 | fixed | "Supported now" and themes planned next |
| V3 | fixed | Install > Requirements is the one place |
| V4 | deferred | Generated upgrade table belongs to the 1.8 fragment work |
| V5 | fixed | R5 blocks past versions outside Upgrade and Changelog |
| O1 | fixed | Layouts table, `detail` internal ([[adr:modootoday/20261109204423]]); R6 doctest |
| O2 | fixed | Every key registered; R6 doctest |
| O3 | fixed | `authors` and `tokens_dark` rows |
| O4 | fixed | reference/cli generated by script/readme-commands |
| O5 | fixed | RULES §5 links the Command line page |
| O6 | partly fixed | README count replaced by a link; docs-extra description left |
| O7 | fixed | Neutral example paths |
| X1 | fixed | recipes/figures/loaders |
| X2 | partly fixed | Showcase moved to reference/showcase; components half waits for N2 |
| X3 | fixed | Reference index rewritten; site-type recipes merged per D6 |
| X4 | fixed | R7 reports groups from 11 entries |
| X5 | partly fixed | Reference index; R3 reports about 200 short descriptions |
| X6 | deferred | llms.txt grouping changes the llms layouts (M) |
| X7 | fixed | Guides and recipes link a related page; R8 blocks |
| X8 | fixed | Demos set `twin:`; R3 blocks |
| X9 | fixed | README guide line lists the missing pages (not generated) |

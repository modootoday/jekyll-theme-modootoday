---
id: sot:modootoday/documentation-site-map
title: Documentation site map
status: active
created: 2026-11-03T18:40:55Z
updated: 2026-11-03T19:03:12Z
verify: [manual]
rel:
  governs: [docs]
---

# Documentation site map

The site map of the rebuilt documentation site: its sections, every page or page family with its URL, source and languages, the navigation, the URL continuity plan, the custom-domain cutover, the generators that own pages and the checks that keep it whole.

The rebuilt site is the showcase of the `base` preset. It is built only from theme components: every page is a layout plus a `sections:` list rendered through the component registry, with no site HTML, Liquid includes, layouts or stylesheets. Component, layout, preset, configuration and starter pages are generated from their registries. Every page exists in English, Korean and Japanese, every page has a Markdown twin, and the site passes the visual and accessibility matrix.

## Rule

### 1. Top-level information architecture

Eighteen top-level sections, in four bands. The header shows the bands, not the sections.

| Band | Section | URL | Diataxis mode | Owner of the content |
|---|---|---|---|---|
| Site | Home | `/` | none (marketing, itself a showcase) | hand-written |
| Learn | Getting started | `/getting-started/` | tutorial | hand-written |
| Learn | Guides | `/guides/` | how-to | hand-written |
| Learn | Internationalization | `/i18n/` | how-to and explanation | hand-written, one generated page |
| Learn | Accessibility and performance | `/quality/` | explanation and reference | hand-written, three generated pages |
| Learn | SEO and machine-readable surfaces | `/seo/` | explanation and reference | hand-written, one generated page |
| Learn | Expressive layer | `/expressive/` | explanation | hand-written, layer pages generated |
| Learn | Upgrade and migration | `/upgrade/` | how-to | hand-written, one generated page |
| Build | Configuration | `/configuration/` | reference | generated from the config schema |
| Build | Components | `/components/` | reference | generated from the component registry |
| Build | Layouts | `/layouts/` | reference | generated from the layout registry |
| Build | Page recipes | `/recipes/` | how-to | hybrid: intro hand-written, front matter extracted from starters |
| Build | Reference | `/reference/` | reference | mostly generated |
| Gallery | Presets | `/presets/` | reference (visual) | generated from the preset registry |
| Gallery | Starters | `/starters/` | reference (visual) | generated from the starters manifest |
| Updates | Changelog, roadmap, news, blog | `/changelog/`, `/roadmap/`, `/news/`, `/blog/` | none | changelog generated, the rest hand-written |
| Updates | Community | `/community/` | none | hand-written |
| Hidden | Demos | `/demos/` | none (fixtures) | hand-written fixtures, out of nav |

Why this set:

- Diataxis keeps tutorials, how-to guides, reference and explanation apart ([diataxis.fr](https://diataxis.fr/)). The site keeps the split but names sections after the product, as Vercel and Next.js do (Getting started, Guides, API reference as separate trees: [nextjs.org/docs](https://nextjs.org/docs), [vercel.com/docs](https://vercel.com/docs)).
- Configuration, Components and Layouts are three reference sections, not one, because each has its own registry and its own generator. Tailwind splits its docs the same way by what a reader looks up ([tailwindcss.com/docs](https://tailwindcss.com/docs)).
- Presets and Starters are galleries, as shadcn/ui separates Components from Blocks and Themes ([ui.shadcn.com/docs](https://ui.shadcn.com/docs)).
- Internationalization, Accessibility and performance, and SEO and machine-readable surfaces are top-level because they are what sets this theme apart; buried under Guides they would be hard to find.
- Demos are a hidden fixture tree. Live layout demos must render in their own layout, outside the docs chrome, so they cannot be the reference page itself.
- Folded or dropped: a separate "Concepts" section (its two pages live in Getting started and Configuration); a top-level "Tokens" section (a Reference page, generated); "Examples" (each component page carries its examples, as MDN reference pages do: [developer.mozilla.org](https://developer.mozilla.org/en-US/docs/MDN/Writing_guidelines/Page_structures/Page_types)).

### 2. Tree

URLs use the pretty permalink style with a trailing slash, as today (`permalink: pretty`). Depth is at most section/group/page (`test/system/docs/structure.rb`). Korean and Japanese pages are the same path under `/ko/` and `/ja/`.

```text
/                                   Home
/search/                            Search
/404.html                           Not found
/getting-started/                   install, first-site, how-pages-work, deploy
/guides/
  jekyll/                           Jekyll fundamentals (9 pages)
  pages/                            Build pages (6 pages)
  customize/                        Customize (5 pages)
  publish/                          Publish (3 pages)
/configuration/                     12 key-group pages (generated)
/presets/                           base, editorial, product, studio, stage, terminal
/components/
  <group>/                          13 groups, embeds included (generated)
  <group>/<component>/              one page per registry component (generated)
  embeds/<provider>/                one page per embed provider (generated)
  <group>/rtl/                      RTL fixture per group (generated, lang ar)
/layouts/
  <group>/                          8 groups (generated)
  <group>/<layout>/                 48 layout pages (generated)
/recipes/
  <group>/                          11 groups
  <group>/<recipe>/                 60 page recipes
/starters/                          13 starter pages + coverage
/expressive/                        contract, motion, 5 preset layers, recipes
/i18n/                              languages, modes, CJK, RTL, rules, strings
/quality/                           accessibility, contrast, performance, budgets, CSP, matrix
/seo/                               metadata, JSON-LD, twins, llms.txt, feeds, agents
/upgrade/                           migration, deprecations, from-other-themes set
/reference/                         public API, CLIs, rake tasks, tokens, hooks, icons, strings
/changelog/  /roadmap/  /news/  /blog/  /tags/  /categories/  /authors/modootoday/
/community/                         contributing, translating, conduct, security, support
/demos/<group>/<name>/              live layout demos (hidden)
/previews/<preset>/                 preset preview builds (separate builds, hidden)
/<lang>/                            home page in the 20 home-only languages
```

### 3. Pages

Columns: URL (English; `/ko` and `/ja` mirror it), title, purpose, layout, composition (`sections:` items in order, or the generator), source (H = hand-written, G = generated, X = hybrid), languages (F = en/ko/ja, E = English only).

#### 3.1 Site

| URL | Title | Purpose | Layout | Composition | Src | Lang |
|---|---|---|---|---|---|---|
| `/` | modoo.today theme | Pitch the theme and prove it: the page is built from components only | `home` | hero split with `visual: code`, logos (starters), features bento, stats (counts from registries), preset strip (linkcards to presets), testimonials-free proof block (checks list), steps (install in three steps), cta | H, counts G | F + 20 home-only |
| `/search/` | Search | Full-text search with section scopes | `search` | search hero, results | H | F |
| `/404.html` | Page not found | Recover from a bad link | `error` | lead, linkcards to section indexes | H | F (one file per language) |

#### 3.2 Getting started (tutorial, linear prev/next)

| URL | Title | Purpose | Layout | Composition | Src | Lang |
|---|---|---|---|---|---|---|
| `/getting-started/` | Getting started | What the theme is and the path through this section | `doc` | lead, linkcards (4 steps), callout | H | F |
| `/getting-started/install/` | Install | Install through `remote_theme`, the gem or a starter | `doc` | tabs (remote_theme / gem / starter), filetree, steps, callout | H | F |
| `/getting-started/first-site/` | Your first site | Build a two-page site with a hero and sections | `doc` | steps, code with titles, split (source and result) | H | F |
| `/getting-started/how-pages-work/` | How pages work | The composition model: layout, `sections:`, `##` slots, `data:`, the override layers | `doc` | lead, steps, params (layers), split, callout | H | F |
| `/getting-started/deploy/` | Deploy | Classic GitHub Pages, the Actions workflow, Jekyll 4 hosts, custom domains | `doc` | tabs (classic / Actions / other), steps, details | H | F |

#### 3.3 Guides (how-to)

| URL | Title | Purpose | Layout | Composition | Src | Lang |
|---|---|---|---|---|---|---|
| `/guides/` | Guides | Index of the four groups | `doc` | linkcards per group (generated list) | H | F |
| `/guides/jekyll/` | Jekyll fundamentals | How the theme fits an ordinary Jekyll site | `doc` | lead, linkcards (generated list) | H | F |
| `/guides/jekyll/posts-and-drafts/` | Posts and drafts | `_posts`, `_drafts`, post front matter, the post layouts | `doc` | steps, filetree, params | H | F |
| `/guides/jekyll/pages/` | Pages and `_pages` | Pages anywhere or in `_pages`, URLs and titles | `doc` | filetree, params, callout | H | F |
| `/guides/jekyll/collections/` | Collections | Custom collections with theme layouts, nav and search | `doc` | steps, code, params | H | F |
| `/guides/jekyll/data-files/` | Data files | `_data` the theme reads (nav, footer, authors, components, i18n) and site data for `data:` | `doc` | params, filetree | H | F |
| `/guides/jekyll/front-matter-defaults/` | Front matter defaults | `defaults:` for layouts, languages, sections | `doc` | code, params | H | F |
| `/guides/jekyll/permalinks/` | Permalinks | Permalink styles and how twins, aliases and translations follow them | `doc` | params, details | H | F |
| `/guides/jekyll/pagination/` | Pagination | Blog and list pagination on classic Pages and Jekyll 4 | `doc` | tabs, code | H | F |
| `/guides/jekyll/plugins/` | Plugins on GitHub Pages | The whitelisted plugins the theme supports and what it needs none for | `doc` | compare (plugin, needed, why), callout | H | F |
| `/guides/jekyll/overriding-theme-files/` | Overriding theme files | Shadowing `_includes`, `_layouts`, `_sass`, and what is public API | `doc` | params, callout (warning), details | H | F |
| `/guides/pages/` | Build pages | Index | `doc` | linkcards | H | F |
| `/guides/pages/compose-a-page/` | Compose a page | Write `sections:`, slots, `data:`, `body: none` | `doc` | steps, split, params, callout | H | F |
| `/guides/pages/navigation/` | Navigation | Header nav, sidebars, footer columns, header CTA | `doc` | filetree, code, params | H | F |
| `/guides/pages/blog-and-news/` | Blog and news | Blog home, authors, series, archives, feeds | `doc` | steps, params | H | F |
| `/guides/pages/records/` | Pages from data | `modootoday.records`, filter, detail pages | `doc` | steps, code, linkcards (demo) | H | F |
| `/guides/pages/search/` | Search | Search options and the search page | `doc` | params, code | H | F |
| `/guides/pages/math-and-diagrams/` | Math and diagrams | Opt-in Mermaid and math | `doc` | steps, callout | H | F |
| `/guides/customize/` | Customize | Tokens, hooks and the override layers | `doc` | lead, params, linkcards | H | F |
| `/guides/customize/brand-tokens/` | Brand tokens | Colors, type and radius from config | `doc` | steps, code, split | H | F |
| `/guides/customize/site-presets/` | Your own preset | A site preset with `extends:` | `doc` | steps, filetree, code | H | F |
| `/guides/customize/site-components/` | Site components and variants | `x-` components and variants in the site registry | `doc` | steps, params | H | F |
| `/guides/customize/site-stylesheets/` | Site stylesheets | `site_css` as the escape hatch and the style contract | `doc` | params, callout | H | F |
| `/guides/customize/fonts/` | Fonts | System stacks, opt-in webfonts, preloads | `doc` | params, callout | H | F |
| `/guides/publish/` | Publish | Index | `doc` | linkcards | H | F |
| `/guides/publish/generated-pages/` | Stubs and generated pages | `modootoday-stubs` for twins, aliases and records | `doc` | steps, code | H | F |
| `/guides/publish/privacy-and-embeds/` | Privacy and embeds | Click-to-load facades, consent, CSP `frame-src`, the provider allowlist | `doc` | lead, steps, params (allowlist keys), compare (provider, facade, frame-src origin), callout | H, tables G | F |
| `/guides/publish/analytics/` | Analytics | The head hook, consent, CSP for analytics | `doc` | code, callout | H | F |

#### 3.4 Configuration (generated reference)

One page per key group. Each group page is generated from the config schema in the registry: key, type, default, values per preset, since, deprecation, the layer that may set it, and a minimal example. The index is hand-written.

| URL | Title | Keys it owns | Src | Lang |
|---|---|---|---|---|
| `/configuration/` | Configuration | The five layers (registry, preset, site, page, item) and the lookup order | H | F |
| `/configuration/site/` | Site identity | title, description, logo, favicon, og_image, theme_color, url keys | G | F |
| `/configuration/appearance/` | Appearance | preset, tokens, tokens_dark, color_scheme, code_theme, css, css_layers, asset_version | G | F |
| `/configuration/components/` | Components | the `components` map and each component's options | G | F |
| `/configuration/navigation/` | Navigation and chrome | nav, sidebar, footer, language_switcher, banner, back_to_top, page_actions, edit_url | G | F |
| `/configuration/content/` | Content | lists, external_links, archive, blog, feed, subscribe, records | G | F |
| `/configuration/i18n/` | Languages | lang, languages, full_languages, hreflang | G | F |
| `/configuration/machine-readable/` | Machine-readable output | twins, aliases, schema, feed, sitemap | G | F |
| `/configuration/assets-and-security/` | Assets and security | csp, scripts, preload, site_css, viewport_fit | G | F |
| `/configuration/expressive/` | Expressive layer | expressive.enabled, motion, layers, load | G | F |
| `/configuration/embeds/` | Embeds | embeds.allowlist, embeds.facade, embeds.consent, per-provider options, the CSP origins each provider adds | G | F |
| `/configuration/front-matter/` | Front matter | every page key the layouts read, by layout | G | F |
| `/configuration/data-files/` | Data files | the `_data` files the theme reads and their schema | G | F |

Composition of a generated group page: lead (from the schema group summary), params per key (one row per key), details (deprecated keys), code (example block). Generator: the registry generator.

#### 3.5 Presets (gallery)

| URL | Title | Purpose | Layout | Composition | Src | Lang |
|---|---|---|---|---|---|---|
| `/presets/` | Presets | Gallery of six presets, side by side | `doc` | lead, gallery (one poster per preset, light and dark), compare (tokens that differ) | G | F |
| `/presets/<name>/` (6) | the preset name | Tokens it changes, default variants, expressive layers, starters using it, contrast results | `doc` | hero with poster, params (tokens), params (variants), linkcards (starters, preview) | G | F |
| `/previews/<name>/` (6) | the preset name | The same short kitchen-sink page built with that preset | separate build | the shared fixture set | G | E |

The six names: `base`, `editorial`, `product`, `studio`, `stage`, `terminal`. A preview is a separate build of one fixture set with `modootoday.preset` set, because one build compiles one core stylesheet. Previews are out of nav, `noindex`, and have no twins.

#### 3.6 Components (generated from the registry)

| URL | Title | Purpose | Layout | Composition | Src | Lang |
|---|---|---|---|---|---|---|
| `/components/` | Components | Authoring kinds (section, inline, auto), groups, status legend | `doc` | lead, linkcards per group (generated), params (status) | X | F |
| `/components/<group>/` (13) | group title | Gallery of the group's components, each fixture rendered once | `doc` | lead, gallery of fixtures, linkcards to components | G | F |
| `/components/<group>/<component>/` | component title | One component: Markdown pattern, preview and source, variants, options, slots, parts, hooks, i18n keys, accessibility notes, examples, status and since | `doc` | hero (name, status badge, since), tabs (preview, Markdown), params (options), params (slots), params (hooks), callout (a11y), examples (one per variant fixture), details (parts and i18n) | G | F |
| `/components/embeds/<provider>/` | provider name | One embed provider: URL patterns, facade, consent text, CSP origin, privacy notes, example | `doc` | hero, tabs (preview, Markdown), params (options), callout (privacy) | G | F |
| `/components/<group>/rtl/` (13) | group title (RTL) | The group fixtures in Arabic for the RTL matrix | `doc` | the group fixtures | G | `ar` only, out of nav |
| `/components/rtl/` | RTL fixtures | Index of the RTL fixture pages | `doc` | linkcards | G | E, out of nav |

Groups follow the registry namespaces: `chrome`, `content`, `structure`, `showcase`, `marketing`, `data`, `media`, `forms`, `blog`, `directory`, `docs`, `commerce`, `embeds`. The registry decides which component sits in which group; the site never lists components by hand. A namespace that would pass 12 components is split by the registry, and the site follows it.

The Embeds group has nine components, each a provider family with per-provider pages:

| Component | Providers (one page each) |
|---|---|
| video | youtube, vimeo |
| social-post | x, instagram, threads, tiktok, bluesky, mastodon, facebook, linkedin |
| audio | spotify, apple-podcasts, soundcloud |
| code-embed | gist, codepen, stackblitz |
| map | openstreetmap, google-maps, kakao-map, naver-map |
| document | figma, slides, pdf |
| form | tally, typeform |
| scheduler | calendly, cal-com |
| iframe | generic iframe (no provider page) |

That is 9 component pages and 28 provider pages. Provider pages are listed on their component page and the group page, not in the sidebar, so the Embeds sidebar group keeps nine entries.

The component page template borrows from shadcn/ui (preview and code tabs, one page per component: [ui.shadcn.com/docs/components](https://ui.shadcn.com/docs/components)) and from MDN reference pages (values, examples, accessibility concerns in fixed order).

#### 3.7 Layouts (generated from the layout registry)

| URL | Title | Purpose | Layout | Composition | Src | Lang |
|---|---|---|---|---|---|---|
| `/layouts/` | Layouts | All layouts by group with a thumbnail each | `doc` | lead, gallery (generated) | X | F |
| `/layouts/<group>/` (8) | group title | The group and when to use each layout | `doc` | lead, linkcards | G | F |
| `/layouts/<group>/<layout>/` (48) | layout name | Front matter keys, default sections, JSON-LD type, stylesheets, budgets, the demo link | `doc` | hero, params (front matter), code (sections default), params (output), linkcards (demo, recipes using it) | G | F |

| Group | Layouts |
|---|---|
| shells | default, doc, minimal, wide, home, error, redirect, search |
| blog-news | blog, post, archive, author, news, news-article |
| directory | directory, portfolio, team, jobs, events, sponsors, integrations |
| detail | detail, project, case-study, job, event, episode |
| marketing | feature, pricing, download, brand, links, contact |
| docs-extra | reference, changelog, roadmap, glossary, hub, course, book |
| documents | legal, resume |
| machine | twin, llms, llms-full, feed, podcast-feed, records-json |

That is the 46 layouts of today plus the two planned machine layouts. The machine layouts have no demo page; their layout page links the real output (`/llms.txt`, `/feed.xml`, a twin).

#### 3.8 Demos (hidden fixtures)

| URL | Purpose | Layout | Src | Lang |
|---|---|---|---|---|
| `/demos/` | List of every demo, so none is an orphan | `doc` | G | F |
| `/demos/<group>/<layout>/` (42) | A live page in that layout | the layout itself | H (fixture content) | F |
| `/demos/shells/error-rtl/` | The error layout in Arabic | `error` | H | `ar` only |
| `/demos/records/` and `/demos/records/<key>/` (1 + 5) | The records feature: one page per record of a data file | `integrations`, `detail` | G by `modootoday-stubs --records` | E |
| `/demos/<group>/` (8) | Redirect to `/layouts/<group>/` | `redirect` | G | F |

Demos are `nav_exclude: true`, reachable from their layout page and from `/demos/`, indexed in search with scope "Layouts".

#### 3.9 Page recipes

A recipe is one page type from the starters: the layout, the full `sections:` list, the data files it reads, and a rendered example. The intro and the "when to use" text are hand-written; the front matter and the "used in" list are extracted from the starter sources by the starters generator, so a recipe cannot drift from the starter that proves it.

| URL | Title | Src | Lang |
|---|---|---|---|
| `/recipes/` | Page recipes | H, list G | F |
| `/recipes/<group>/` (11) | group title | H, list G | F |
| `/recipes/<group>/<recipe>/` (60) | recipe title | X | F |

Composition of a recipe page: lead (hand-written), split (front matter and rendered thumbnail), params (data files), linkcards (starters using it, layout page, components used).

| Group | Recipes |
|---|---|
| docs | docs-home, guide, reference, api-reference, changelog, roadmap |
| help | help-home, category-hub, help-article, faq, glossary |
| marketing | landing-home, product-home, feature, pricing, integrations, case-study, download, brand-kit, contact |
| editorial | blog-home, post, author, archive, newsletter, news-front, news-article |
| company | company-home, about, team, careers, job |
| personal | portfolio-home, project, resume, links |
| community | oss-home, install, sponsors, packages, code-of-conduct |
| catalogs | marketplace-home, catalog, catalog-item, submit |
| events-media | conference-home, schedule, session, speakers, venue, podcast-home, episode |
| learning | course-home, lesson, handbook |
| system | not-found, search, legal, thank-you, redirect |

The six group slugs of today (`docs`, `marketing`, `company`, `personal`, `community`, `system`) keep their URLs.

#### 3.10 Starters (generated from the starters manifest)

| URL | Title | Purpose | Layout | Composition | Src | Lang |
|---|---|---|---|---|---|---|
| `/starters/` | Starters | Gallery of 13 starters with preset, languages and stacks | `doc` | lead, gallery (poster per starter), compare | G | F |
| `/starters/<name>/` (13) | starter name | Who it is for, pages and their recipes, preset, features shown, live preview link, repository, "use this template" steps, check flags | `doc` | hero with poster and preview action, linkcards (recipes), params (features), steps | G | F |
| `/starters/coverage/` | Coverage | The layout, component, feature and preset matrix over all starters | `doc` | tables (compare) | G | F |

Starters: docs, blog, landing, saas, help-center, marketplace, portfolio, company, oss, conference, course, podcast, newsroom. The live preview link comes from a `preview:` field in the starters manifest. Each starter's preview is its own repository's GitHub Pages site, so the preview is exactly what a user gets from "use this template". Previews are not collected under this site.

#### 3.11 Expressive layer

| URL | Title | Purpose | Src | Lang |
|---|---|---|---|---|
| `/expressive/` | Expressive layer | The contract: poster first, reduced motion, save-data, budgets, LCP is the poster | H | F |
| `/expressive/script-visuals/` | Script visuals | `script:` and `poster:` on hero and sections, with a live visual | H | F |
| `/expressive/motion/` | Motion | reveal variants, the story section, view transitions | H | F |
| `/expressive/video/` | Video visuals | Video hero and section visuals with posters | H | F |
| `/expressive/<layer>/` (5) | product-scene, studio-stage, stage-poster, stage-wave, terminal-type | One preset layer: what it draws, budgets, fallbacks, the preset that owns it | G | F |
| `/expressive/write-a-layer/` | Write a layer | Site modules, the token reader, theme-change events, loading modes | H | F |
| `/expressive/webgl/` | WebGL libraries | Vendoring a library in a site, with the CSP and budget rules | H | F |

#### 3.12 Internationalization

| URL | Title | Purpose | Src | Lang |
|---|---|---|---|---|
| `/i18n/` | Internationalization | Overview: languages, modes, fallbacks | H | F |
| `/i18n/languages/` | Languages | The 23 interface languages, direction and status | G (language list) | F |
| `/i18n/translation-modes/` | Translation modes | Sibling files with `source_rev`, directory mode, home-only languages | H | F |
| `/i18n/cjk/` | CJK typography | Line breaking, line heights, fonts for ko, ja, zh | H | F |
| `/i18n/rtl/` | Right-to-left | Logical properties, `dir`, RTL fixtures | H | F |
| `/i18n/translation-rules/` | Translation rules | The style rules translators follow | H | F |
| `/i18n/interface-strings/` | Interface strings | Catalogs, overrides, `--i18n-init` | H | F |

#### 3.13 Accessibility and performance

| URL | Title | Purpose | Src | Lang |
|---|---|---|---|---|
| `/quality/` | Accessibility and performance | What the theme guarantees and how it is measured | H | F |
| `/quality/accessibility/` | Accessibility | Landmarks, focus, safe areas, forced colors, reduced motion | H | F |
| `/quality/keyboard-and-screen-readers/` | Keyboard and screen readers | The keyboard model and the authoring rules from the screen reader audit | H | F |
| `/quality/color-contrast/` | Color contrast | Contrast pairs per preset, light and dark | G (registry contrast pairs) | F |
| `/quality/performance/` | Performance | Asset loading, caching, asset versions | H | F |
| `/quality/budgets/` | Budgets | Size budgets per page type, preset and expressive layer | G (QA budget table) | F |
| `/quality/csp/` | Content Security Policy | Strict CSP, SRI for third parties, frame origins | H | F |
| `/quality/test-matrix/` | Test matrix | The visual and accessibility matrix and its last results | G (QA report) | F |

#### 3.14 SEO and machine-readable surfaces

| URL | Title | Purpose | Src | Lang |
|---|---|---|---|---|
| `/seo/` | SEO and machine-readable surfaces | Overview of every output meant for crawlers and agents | H | F |
| `/seo/head-metadata/` | Head metadata | Titles, canonical, Open Graph, hreflang, sitemap | H | F |
| `/seo/structured-data/` | Structured data | The one-graph JSON-LD model and how to extend it | H | F |
| `/seo/json-ld-types/` | JSON-LD types | Type per layout and required properties | G (layout registry) | F |
| `/seo/twins-and-aliases/` | Markdown twins and URL aliases | Twins, `.md` and `.html` aliases, moved-page redirects | H | F |
| `/seo/llms-txt/` | llms.txt | Per-language llms.txt and llms-full.txt | H | F |
| `/seo/feeds/` | Feeds | Atom per language, the podcast feed | H | F |
| `/seo/agents/` | For agents | How an agent should read this theme's sites | H | F |
| `/seo/agent-marketplace/` | Agent marketplace surfaces | Catalog JSON and item JSON from records | H | F |

#### 3.15 Upgrade and migration

| URL | Title | Purpose | Src | Lang |
|---|---|---|---|---|
| `/upgrade/` | Upgrade and migration | Upgrade between versions; links to the from-other-themes set | H | F |
| `/upgrade/configuration/` | Configuration changes | Old keys to new keys (components list to map, aliases kept) | H, table G | F |
| `/upgrade/deprecations/` | Deprecations | Every deprecated option and variant with replacement and removal version | G (registry) | F |
| `/upgrade/existing-site/` | Adopt in an existing site | Switch an existing Jekyll site without restructuring | H | F |
| `/upgrade/from-minima/` | From minima | Mapping of layouts, includes and config | H | F |
| `/upgrade/from-chirpy/` | From Chirpy | as above | H | F |
| `/upgrade/from-just-the-docs/` | From Just the Docs | as above | H | F |
| `/upgrade/from-minimal-mistakes/` | From Minimal Mistakes | as above | H | F |
| `/upgrade/from-jekyll-seo-tag/` | From jekyll-seo-tag | Head metadata without the plugin | H | F |

The from-X set follows Astro's "Migrate to Astro" pages, one page per source tool ([docs.astro.build](https://docs.astro.build/en/guides/migrate-to-astro/)).

#### 3.16 Reference

| URL | Title | Purpose | Src | Lang |
|---|---|---|---|---|
| `/reference/` | Reference | Index | H | F |
| `/reference/api/` | Public API | What is public and the deprecation policy | H | F |
| `/reference/check-cli/` | modootoday-check | Every option, from the CLI's own help | G (`--help=markdown`) | F |
| `/reference/stubs-cli/` | modootoday-stubs | as above | G (`--help=markdown`) | F |
| `/reference/rake-tasks/` | Rake tasks | Repository tasks for contributors | G (task descriptions) | F |
| `/reference/tokens/` | Design tokens | Every semantic token with default light and dark values and per-preset values | G (registry) | F |
| `/reference/hooks/` | Hooks | Component hook tokens and the include hooks | G (registry) | F |
| `/reference/icons/` | Icons | The icon set | G (registry) | F |
| `/reference/interface-strings/` | Interface string keys | Every catalog key with the English text | G (i18n build) | F |

#### 3.17 Updates and community

| URL | Title | Layout | Src | Lang |
|---|---|---|---|---|
| `/changelog/` | Changelog | `changelog` | G (CHANGELOG) | F |
| `/roadmap/` | Roadmap | `roadmap` | H | F |
| `/news/` | News | `news` (release news front page) | H | F |
| `/blog/` | Blog | `blog` | H | F (posts are per-language files) |
| posts | per post | `post`, `news-article` | H | per post |
| `/tags/`, `/categories/` | Tags, Categories | `archive` | G (Liquid) | F |
| `/authors/modootoday/` | modoo.today theme team | `author` | H | F |
| `/community/` | Community | `doc` | H | F |
| `/community/contributing/` | Contributing | `doc` | H | F |
| `/community/translating/` | Translating | `doc` | H | F |
| `/community/code-of-conduct/` | Code of conduct | `legal` | H | F |
| `/community/security/` | Security policy | `legal` | H | F |
| `/community/support/` | Support | `doc` | H | F |

### 4. Page counts

English pages; Korean and Japanese repeat every row marked F. C is the registry's component count outside Embeds when the site is built (counted by the generator, not by hand).

| Section | English pages | Generated |
|---|---|---|
| Site (home, search, 404) | 3 | 0 |
| Getting started | 5 | 0 |
| Guides | 28 | 0 |
| Configuration | 13 | 12 |
| Presets | 7 (+6 previews) | 7 |
| Components | 28 + C + 9 + 28 | all but the index |
| Layouts | 57 | 56 |
| Demos | 58 | 15 |
| Page recipes | 72 | 0 (60 hybrid) |
| Starters | 15 | 15 |
| Expressive layer | 11 | 5 |
| Internationalization | 7 | 1 |
| Accessibility and performance | 8 | 3 |
| SEO and machine-readable | 9 | 1 |
| Upgrade and migration | 9 | 1 |
| Reference | 9 | 6 |
| Updates (without posts) | 7 | 3 |
| Community | 6 | 0 |
| **Total** | **389 + C** | |

Components: index, RTL index, 13 group pages, 13 RTL pages (28), C component pages, 9 Embeds component pages, 28 provider pages. Demos include the 8 group redirects. With about 75 components outside Embeds, the site has about 465 English pages. Section index pages carry `<!-- spec:count -->` markers that the docs generator rewrites, so no count on the site is typed by hand.

### 5. URL continuity

The current site has 95 English pages, 86 Korean, 86 Japanese, 20 home-only pages and 10 posts. 38 English URLs change; 30 of them have Korean and Japanese twins, so 98 page URLs move. Every moved URL gets a redirect, and every moved page's old twin URL (`<old>/index.md`) keeps serving the new page's twin. No current URL returns 404.

#### 5.1 Unchanged URLs

`/`, `/404.html`, `/guides/`, `/guides/customize/` (now the group index; its content is the old page), `/components/`, `/layouts/`, `/layouts/shells/`, `/layouts/<group>/` for directory, detail, marketing, blog-news, docs-extra and documents, every `/layouts/<group>/<name>/` except the two below (the URL stays; the page is now the generated layout reference, with the live demo one link away), `/recipes/`, `/recipes/{docs,marketing,company,personal,community,system}/`, `/reference/`, `/reference/api/`, `/blog/`, `/news/`, `/tags/`, `/categories/`, `/authors/modootoday/`, every post, `/feed.xml`, `/search.json`, `/llms.txt`, `/llms-full.txt` and the per-language feeds and llms files, and the 20 home-only `/<lang>/` pages.

#### 5.2 Moved URLs

Each row holds for `/ko` and `/ja` too unless marked E.

| Current URL | New URL |
|---|---|
| `/guides/install/` | `/getting-started/install/` |
| `/guides/first-page/` | `/getting-started/first-site/` |
| `/guides/configuration/` | `/configuration/` |
| `/guides/agents/` | `/seo/agents/` |
| `/guides/upgrade/` | `/upgrade/` |
| `/guides/accessibility/` | `/quality/accessibility/` |
| `/guides/performance/` | `/quality/performance/` |
| `/guides/structured-data/` | `/seo/structured-data/` |
| `/guides/translation/` | `/i18n/translation-rules/` |
| `/components/kitchen-sink/` | `/components/` |
| `/components/kitchen-sink-rtl/` (E) | `/components/rtl/` |
| `/layouts/demo/` | `/layouts/shells/` |
| `/layouts/demo/home/` | `/demos/shells/home/` |
| `/layouts/demo/minimal/` | `/demos/shells/minimal/` |
| `/layouts/demo/wide/` | `/demos/shells/wide/` |
| `/layouts/demo/error/` | `/demos/shells/error/` |
| `/layouts/demo/error-rtl/` (E) | `/demos/shells/error-rtl/` |
| `/layouts/demo/redirect/` | `/demos/shells/redirect/` |
| `/layouts/demo/search/` | `/demos/shells/search/` |
| `/layouts/demo/orbit/` | `/expressive/script-visuals/` |
| `/layouts/demo/filter/` | `/components/data/filter/` |
| `/layouts/demo/csp/` | `/quality/csp/` |
| `/layouts/demo/code-github/` | `/components/content/code/` |
| `/layouts/blog-news/article/` | `/layouts/blog-news/news-article/` |
| `/layouts/docs-extra/api/` | `/recipes/docs/api-reference/` |
| `/recipes/math-diagrams/` | `/guides/pages/math-and-diagrams/` |
| `/recipes/brand-tokens/` | `/guides/customize/brand-tokens/` |
| `/recipes/csp/` | `/quality/csp/` |
| `/recipes/search/` | `/guides/pages/search/` |
| `/recipes/generated-pages/` | `/guides/publish/generated-pages/` |
| `/recipes/records/` (E) | `/demos/records/` |
| `/recipes/records/<key>/` (E, 5) | `/demos/records/<key>/` |
| `/reference/changelog/` | `/changelog/` |
| `/reference/roadmap/` | `/roadmap/` |

Two rows each merge two pages into one target (`/layouts/demo/csp/` and `/recipes/csp/`; the kitchen sink into the component index). The filter, code and component targets depend on the registry ids; the move table is checked against the built site, so a renamed id fails the build instead of leaving a dead link.

#### 5.3 Removed pages

No page is removed without a redirect. Retired as standalone content, each with the redirect above:

| Page | Reason |
|---|---|
| Kitchen sink (en, ko, ja) | 100+ components no longer fit one page within the per-page CSS budget; the group pages replace it |
| Kitchen sink RTL | Replaced by one RTL fixture per group |
| Layout demo index | The shells group page lists the demos |
| Orbit, filter, CSP and GitHub-code demos | They demonstrated features, not layouts; each moves to the page that documents the feature |
| API reference demo | It is a page recipe, not a layout |

The site-owned includes, layouts and stylesheets that served these demos (examples layout, section includes, the orbit script and its stylesheet, the demo stylesheets) are deleted, because the rebuilt site may hold no site HTML or CSS.

#### 5.4 Redirect mechanism

- The URL-alias feature writes `.md` and `.html` aliases of a page ([[adr:modootoday/20261103053014]]). The rebuilt site turns both on (`modootoday.aliases: {md: true, html: true}`) and drops `twins: source`, since every page now has front matter.
- Moved pages need a third alias kind, `moved`, in the same declaration: `modootoday.aliases.moved: true` reads a moves table in `_data`, and `modootoday-stubs --aliases` writes, per row and per language, a `redirect` stub at the old URL (meta refresh, canonical to the new URL, `noindex`, `sitemap: false`) and a twin stub at the old twin path. `modootoday-check --aliases` fails when an old URL is also a page, when a target is not a built page, or when a row's twin is not byte-identical. This is a theme work item; until it lands, the same stubs are written by the docs generator.
- `/demos/<group>/` redirects and `/components/rtl/` use the same stubs.

### 6. Navigation

Header (left to right): logo to `/`; Docs (`/getting-started/`); Components; Layouts; Presets; Starters; Blog; then search, language menu, theme toggle, GitHub link. On narrow screens the header collapses into one menu with the same order.

Sidebars, one per context (Starlight-style groups generated from the directory tree: [starlight.astro.build](https://starlight.astro.build/guides/sidebar/)):

| Context | Pages that use it | Groups (in order) |
|---|---|---|
| Docs | Getting started, Guides, Configuration, Internationalization, Accessibility and performance, SEO, Expressive layer, Upgrade, Reference | Getting started; Guides: Jekyll fundamentals, Build pages, Customize, Publish; Configuration; Internationalization; Accessibility and performance; SEO and machine-readable; Expressive layer; Upgrade and migration; Reference |
| Components | Components | the 13 groups, each listing its components |
| Layouts | Layouts, Demos | the 8 groups, each listing its layouts |
| Recipes | Page recipes | the 11 groups |
| Gallery | Presets, Starters | Presets (6), Starters (13), Coverage |
| None | Home, Updates, Community, Search | no sidebar; Community uses a short in-page TOC |

Each sidebar group holds at most 12 entries; a group that would pass 12 is split, never truncated. Per-context sidebars need the theme to select a nav file per page (a `nav:` front matter key set through `defaults:`), apart from the header nav. That is a theme work item.

Footer columns (`_data/nav/footer.yml`): Learn (Getting started, Guides, Configuration, Upgrade), Build (Components, Layouts, Recipes, Reference), Gallery (Presets, Starters, Coverage), Project (Changelog, Roadmap, Blog, Community, Security), and the language menu with the license line.

Breadcrumbs: section, group, page, from the URL path; provider pages add their component (Components, Embeds, Social post, Bluesky). Home has none.

Prev/next: within one sidebar context in sidebar order. Getting started is linear (install, first site, how pages work, deploy) and ends with next to Guides. Generated pages follow registry order. Demos, previews and RTL fixtures have no prev/next.

Search scopes: one index per language with a `section` field; the search page offers scope chips All, Docs, Components, Layouts, Recipes, Gallery, Blog. Previews, RTL fixtures and redirect stubs are excluded from the index.

Language menu: in the header on every page. On full pages it lists en, ko and ja; on the home page it lists all 23 languages. A missing translation falls back to the English page in menus and indexes, with a notice on the page.

There is no version switcher: the site documents the latest release, and the changelog and upgrade pages cover older versions.

### 7. Languages

- Full languages: en, ko, ja. Every page marked F exists in all three ([[adr:modootoday/20261029201227]] keeps English canonical; translations are localized, not literal).
- Home-only languages (20): zh-CN, zh-TW, tr, ru, vi, th, de, es, fr, uk, pl, pt-BR, ar, fa, id, it, el, ml, ur-Latn, ro. Only the home page and its llms files exist in these. The list comes from the language registry ([[adr:modootoday/20261103091952]]).
- English only: preset previews, the RTL index, records demos. Arabic only: the RTL fixtures and the RTL error demo.
- Mode: sibling files with `source_rev` ([[adr:modootoday/20261103071902]]); home-only languages keep their home page in the home folder. The docs site does not use directory mode; the docs starter shows it.
- Generated pages are generated in all three languages. Their prose comes from the registry's per-language summary fields; a missing summary falls back to English and marks the page `translation: pending`. Labels come from the interface catalogs. A generated translation carries the `source_rev` of its registry entry, so a changed entry flags its translations as stale.

### 8. Source layout

Every URL maps to one predictable file:

| URL | Hand-written source | Generated source |
|---|---|---|
| `/<section>/` | `docs/<section>/index.md` | `docs/generated/pages/<section>/index.md` |
| `/<section>/<page>/` | `docs/<section>/<page>.md` | `docs/generated/pages/<section>/<page>.md` |
| `/<section>/<group>/` | `docs/<section>/<group>/index.md` | `docs/generated/pages/<section>/<group>/index.md` |
| `/<section>/<group>/<page>/` | `docs/<section>/<group>/<page>.md` | `docs/generated/pages/<section>/<group>/<page>.md` |
| `/ko/...`, `/ja/...` | the same file with `.ko.md`, `.ja.md` beside it | the same, beside the generated English file |
| `/<lang>/` (home-only) | `index.<lang>.md` in the home folder | none |

Rules:

- One directory per top-level section, named as its URL segment. The `docs` root holds only the section directories, `_config.yml`, `_data`, `_posts`, `assets`, `generated`, the home folder, the root pages (index, 404, search, tags, categories) and the feed and search outputs.
- At most 12 authored pages per directory; a translation counts as its English page ([[adr:modootoday/20261103092701]], `test/system/docs/structure.rb`). Every directory in the tree above holds 12 or fewer by construction.
- Generated pages live only under `docs/generated/pages/`, twins under `docs/generated/twins/`, alias and moved stubs under `docs/generated/aliases/`, per-language llms files under `docs/generated/llms/`. Generated files carry `generated_by:` and an explicit permalink. A path is either hand-written or generated, never both; the check in section 10 fails on a collision.
- The "edit this page" link of a generated page points at its registry source, not at the generated file.
- `_data` is split per concern: `_data/nav/` (header, footer and per-context sidebars, all generated), `_data/i18n/` (catalog overrides), `_data/languages.yml` (generated), `_data/docs/` (sections, moves table), `_data/demo/` (records and sample data), and the files the theme reads by fixed name (`authors.yml`, `components.yml`).
- No `_includes`, `_layouts` or site stylesheets under `docs`, and no raw HTML in bodies; the same no-custom-markup check as the starters applies.

### 9. Generated surfaces

| Generator | Owns |
|---|---|
| Registry generator (`script/registry`, planned) | Configuration group pages; component, group, provider and RTL pages; layout and layout-group pages; preset pages and the preset gallery; expressive layer pages; Reference tokens, hooks and icons; JSON-LD types; color contrast; deprecations |
| Docs index (`script/docs-index`) | header, footer and sidebar nav files; section and group index lists; twins; llms stubs; count markers; moved and demo-group redirect stubs until the theme's moved aliases land; the `/demos/` list |
| Language build (`script/i18n-build`) | the language list, the languages page table, interface string keys |
| Starters generator (`script/starters`) | starter pages, the starter gallery, coverage, the extracted front matter and "used in" lists of recipes |
| Command help (`script/readme-commands`) | the two CLI pages and the rake task page |
| Release notes (`script/release-notes`) | the changelog page |
| QA report export | budgets and test matrix pages |
| `modootoday-stubs --records` | the records demos |
| `modootoday-stubs --aliases` | `.md` and `.html` aliases and, once it lands, moved stubs |

A hand-written page that needs a generated list includes it between docs-index markers instead of typing it.

### 10. Site checks

All run in CI on the built site; each fails the build.

| Check | Rule |
|---|---|
| Orphans | Every built HTML page is linked from a nav file, a section or group index, or the `/demos/` list; out-of-nav pages say so with `nav_exclude` |
| Nav coverage | Every page with a nav entry exists; every page under a section is in its sidebar unless excluded; no sidebar group passes 12 entries |
| Alias coverage | Every row of the moves table, in each language, resolves to a redirect whose target is a built page; every old twin URL serves a byte-identical twin; `.md` and `.html` aliases pass `modootoday-check --aliases` |
| Count markers | Every `<!-- spec:count -->` marker equals the generator's count |
| Links | Internal links and anchors resolve in the built site; external links are checked on a schedule and reported, not blocking |
| Registry coverage | Every registry component, embed provider, layout, preset, config key and token has its page; every generated page has its registry row |
| Starters coverage | Every starter has a page, a preview link that answers, and recipes for its pages |
| Translations | `modootoday-check --i18n-pages --strict`: every F page exists in ko and ja with a current `source_rev`, or is marked pending |
| Twins and llms | `modootoday-check --twins` over the whole site |
| Source layout | The URL-to-file rule of section 8, the 12-page limit, no hand-written and generated file for one URL, no custom markup |
| Absolute URLs | No built file and no repository document links the old project-site host |
| Visual and accessibility matrix | Every section index, one page per generated template, the six previews, light and dark, 360 and 1280 wide, axe clean |

### 11. Custom domain

The rebuilt site is served at `https://theme.modoo.today`, a CNAME to GitHub Pages, replacing `https://modootoday.github.io/jekyll-theme-modootoday/`.

Configuration: `url: https://theme.modoo.today` and `baseurl: ""` in `docs/_config.yml`. Every canonical URL is at the root.

Old URLs:

- GitHub documents that Pages "will automatically create redirects between the domains" when a custom domain is set, in the context of apex and `www` hosts ([Managing a custom domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)). The redirect from the project path on the account host to the custom domain is widely observed but not stated in GitHub's documentation, so it is verified at cutover, not assumed.
- Limits: the redirect lives only while this repository keeps its custom domain; if the account's own user site ever gets a custom domain, GitHub applies it to project sites that have none ([About custom domains](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages)), so this repository must keep its own; a moved page served through the host redirect takes two hops (host redirect, then meta refresh), and agents that do not follow a meta refresh land on the stub, which carries the canonical link and the new twin; HTTPS for the new host can take up to 24 hours to be enforceable.

Absolute URLs that change with the host:

| Surface | Change |
|---|---|
| llms.txt, llms-full.txt (all languages) | built from `url` and `baseurl`; regenerate, check no old host remains |
| Atom feeds | entry links and ids are absolute and change with the host, so feed readers may show old entries again once; the move is announced in a post |
| JSON-LD, canonical, Open Graph, hreflang, og:image | built from `url`; checked by the JSON-LD and head checks |
| sitemap.xml | built from `url`; resubmit to search consoles |
| search.json | page paths without host or base URL; with `baseurl: ""` they are already right; the absolute-URL check covers it |
| `subscribe.action` and other absolute keys in `docs/_config.yml` | edit to the new host |
| README (both languages), SECURITY, issue template config, pull request template and the README test | replace the old docs links |
| gemspec | keep `homepage` on the repository; add a `documentation_uri` with the new host |
| Starter READMEs and starter configs | link the docs at the new host; re-render the starters |

Cutover checklist (a plan only; DNS and Pages settings are changed by the maintainer):

1. DNS: a CNAME record `theme` in the `modoo.today` zone pointing to `modootoday.github.io`; if the zone has CAA records, one must allow `letsencrypt.org`.
2. Verify `modoo.today` for the organization in GitHub Pages settings before adding the domain, to prevent takeover.
3. One commit: `url` and `baseurl` in `docs/_config.yml`, a `docs/CNAME` file holding `theme.modoo.today`, the absolute-URL edits above.
4. In the repository's Pages settings, set the custom domain to `theme.modoo.today`. The classic branch builder reads `docs/CNAME`; a custom Actions workflow ignores the file and uses the setting ([Managing a custom domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)). The site keeps the classic builder ([[adr:modootoday/20261029201122]]); `docs/CNAME` and the setting must hold the same host, and a CI check compares the file with the `url` key.
5. When the certificate is issued, turn on Enforce HTTPS.
6. Verify: the new host serves `/`, a moved page, a twin, `/llms.txt`, `/feed.xml`, `/sitemap.xml` over HTTPS; an old project-path URL answers 301 to the same path on the new host; a moved old URL ends on its new page; the absolute-URL check passes on the deployed site.
7. Resubmit the sitemap to search consoles and publish a news post about the move.

## Why

- One map that every generator, check and contributor reads keeps a site of about 465 pages per language from drifting. The theme already generates its nav and indexes from front matter ([[adr:modootoday/20261030083000]]); this extends the same ownership to every reference page.
- Product-shaped sections over Diataxis modes: readers look up a component, a preset or a starter by name. Each section still holds one Diataxis mode, which keeps pages focused.
- Generated reference pages remove the largest source of drift: lists of components, options, layouts and keys typed into Markdown.
- Demos separate from reference pages: a layout demo must render in its own layout, and a reference page must render in the docs chrome.
- Embeds as nine components with provider pages: one component per provider would put 28 entries in a sidebar group and break the 12-entry rule.
- Unchanged URLs where the content stays (layouts, recipe groups, reference API, blog, news, feeds, llms files); moved URLs only where the old home no longer describes the page.
- Trailing-slash pretty URLs because every current URL uses them and the alias rules are built on them.

## Verification

Phases:

| Phase | When | What is built |
|---|---|---|
| A | During the registry work | The section tree and source layout; per-context sidebars; the moves table, redirect and old-twin stubs; Getting started, Guides (Jekyll fundamentals included), Internationalization, Accessibility and performance, SEO, Upgrade (migration set included), Reference, Community; generated Configuration, Components, Layouts and Reference pages as each registry lands; demos; all site checks except starters coverage and the full matrix |
| B | After presets, starters, embeds and the expressive layer land | Presets and previews, Starters and coverage, Page recipes, Expressive layer pages, the Embeds group and the privacy guide, the home page, the Korean and Japanese pass over hand-written pages, the full visual and accessibility matrix |
| Cutover | With the publication of phase A | The custom-domain checklist of section 11, so absolute URLs change once and the moves and the host change reach search engines together |

Done when every check in section 10 passes on the deployed site at the new host, `modootoday-check --twins --aliases --i18n-pages --strict` passes on the docs build, and every current URL listed in section 5 answers with its page or a redirect to it.

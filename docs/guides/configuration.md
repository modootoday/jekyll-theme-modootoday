---
nav_order: 20
title: Configuration
description: Every site-wide setting under the modootoday key in _config.yml, with its default value, what it changes and the page that explains it in full.
sections:
  - keys
  - new-window
  - head
  - i18n
  - registry
---
# Configuration

Everything is optional. Settings live under one `modootoday:` key so they never clash with other plugins.

## Keys

```yaml
modootoday:
  color_scheme: auto  # auto | auto-dark | auto-light | light | dark
  components: [callout, badge, cta, card, tabs]
  tokens: {primary: "#4f46e5", radius: "0.5rem"}
  nav: main
```

| Key | Default | What it does |
|---|---|---|
| `badges` | `true` | Shows status code spans as badges. `false` keeps them as code. |
| `code_theme` | `theme` | Code block colors: the theme's (`theme`) or GitHub's (`github`). See [Code colors](../customize/#code-colors). |
| `color_scheme` | `auto` | Light or dark mode. `auto` follows the device; `auto-dark` and `auto-light` pick a start; `light` and `dark` fix one. |
| `components` | all | Limits which component CSS and JS the site ships. |
| `css_layers` | `false` | Wraps the theme CSS in `@layer mt.*`. |
| `nav` | `main` | The menu file in `_data/nav/`. An entry with `items:` becomes a group. |
| `sidebar` | `auto` | Side menu on `doc` pages: `auto` when the menu has groups, `true` always, `false` never. |
| `page_actions` | `true` | A menu to copy the page or view it as Markdown. `false` turns it off. |
| `tokens` | theme values | Changes theme colors and other design tokens. On a strict CSP site, use the [token bridge](../customize/#token-bridge). |
| `tokens_dark` | theme values | The same for dark mode only. |
| `site_css` | none | Your own stylesheets, such as `[/assets/css/site.css]`, loaded after the theme's. See [Brand tokens](../../recipes/brand-tokens/). |
| `preload` | none | Files the browser should fetch early, such as fonts: a list of `{href, as, type}`. |
| `scripts` | none | Your own JavaScript modules, loaded only on pages that name them with `script:` or contain their `element` (a widget). See [Module scripts and posters](../customize/#module-scripts-and-posters) and [Widgets](../../recipes/figures/widgets/). |
| `search` | none | Header search settings: how much text is indexed and how queries match. See [Search](../../recipes/search/). |
| `twins` | stubs | How each page's Markdown copy is published; `source` uses pages without front matter. See [AI agents](../agents/). |
| `aliases` | none | Extra URLs for agents: `md: true` adds `/<page>.md`, `html: true` redirects `/<page>.html`. See [URL aliases](../agents/#url-aliases). |
| `records` | none | One page for each entry of a `_data` file. See [Generated pages](../../recipes/generated-pages/). |
| `seo` | `true` | `false` removes the built-in canonical, `hreflang` and Open Graph tags. |
| `hreflang` | follows `seo` | `true` keeps the `hreflang` links when `seo: false`, for sites that use `jekyll-seo-tag`. |
| `schema` | on when `url` is set | Adds schema.org structured data. `false` turns it off. See [Structured data](../structured-data/). |
| `languages` | none | The site's language codes, such as `[en, ko]`, used for `hreflang` and the language menu. |
| `full_languages` | none | Languages that translate every page, such as `[ko, ja]`. `modootoday-check --i18n-pages` warns about missing pages. |
| `lists` | none | `{link_chips: true, titled_items: true}` turns link-only lists into chips and `**Title**:` items into titled items. |
| `heading_anchors` | `false` | `true` ends each `##` and `###` heading of a doc or post with a link to itself, shown on hover and focus and always on touch screens. |
| `language_switcher` | none | A language menu in the `header` (globe button) or the `footer` (list of names). |
| `og_image` | none | Default image for link previews. A page's `image:` wins. |
| `feed` | `false` | `true` links `/feed.xml`. Add `jekyll-feed` to `plugins`. |
| `logo` | none | `brand` shows the theme's mark before the site title; a path shows your own image. |
| `favicon` | none | `brand` uses the theme's mark as the site icon; a path uses your own icon. |
| `pwa` | off | `enabled: true` links a web app manifest built from the site title, `theme_color` and the brand mark, so browsers can install the site, and registers a service worker for offline reading; `precache:` lists more site paths to keep (a page can add itself with front matter `pwa: precache`); `shortcuts:` and `screenshots:` add the app icon's menu and the install dialog's pictures. `enabled: kill` ships a worker that removes itself. See [Installable site](../../recipes/pwa/). |
| `header` | `{compact_title: true}` | `compact_title: false` keeps the site name beside the logo on phones. |
| `csp` | none | `strict` loads the early theme script from a file instead of inline. |
| `asset_version` | `theme` | What `?v=` adds to theme file URLs: `theme` the version, `build` also the commit, `false` nothing. See [Performance](../performance/#versioned-asset-urls). |
| `viewport_fit` | `cover` | `auto` keeps the page clear of a phone's notch. See [Accessibility](../accessibility/#settings). |
| `theme_color` | page background | Browser bar color: one `"#hex"`, `{light: "#hex", dark: "#hex"}`, or `false` for none. |
| `edit_url` | none | Start of the "Edit this page" link URL, ending in `/`; or `auto`: the repository, branch and folder GitHub Pages builds from (below). |
| `feedback` | off | A row under the page: `issues` (`auto`, a repository's issues URL, or `false`) adds Report an issue, `helpful: true` adds Was this page helpful? with two answers, `discuss` adds a Discuss link, `labels` labels the prefilled issues. Front matter `feedback: false` hides it on one page. |
| `build_link` | `false` | `true` adds "Built from" and the commit the site was built from, linked to it on GitHub. |
| `archive` | none | Tag and category page URLs, such as `{tags: /tags/, categories: /categories/}`. Post footers link there; see [Posts and archives](../../reference/api/#posts-and-archives). |
| `mermaid` | off | Draws diagrams from ```` ```mermaid ```` blocks. See [Diagram and math loaders](../../recipes/figures/loaders/#built-in-loaders). |
| `diagrams` | `{dir: /assets/diagrams/, dark: true, source: details}` | Where the SVGs of [static diagrams](../../recipes/figures/math-diagrams/#static-diagrams) live, whether each has a dark twin, and whether the Mermaid source stays on the page. |
| `math` | off | Renders ```` ```math ```` and `$$` blocks with KaTeX in the browser, or with `mode: static` shows the MathML committed in `_data/math`. See [Math and diagrams](../../recipes/figures/math-diagrams/#static-math). |
| `external_links` | none | `new_window: true` opens links to other sites in a new window. See [Links that open a new window](#links-that-open-a-new-window). |
| `blog` | none | Blog settings, such as `per_page`. See [Blog and news](../../layouts/blog-news/#settings). |
| `authors` | `true` | `false` hides the bylines on posts and post cards; author data stays in `_data/authors.yml`. |
| `news` | none | News settings, such as `sections:` for the front page. See [Blog and news](../../layouts/blog-news/#settings). |
| `css` | `split` | `split` loads only the CSS a page uses; `bundle` loads one sheet with everything. |
| `banner` | none | `{text: "…", url: /path/, link: "Read more"}` shows an announcement bar on every page. |
| `back_to_top` | `false` | `true` adds a Back to top link at the end of every page. |
| `loading` | `false` | `true` loads the spinner and skeleton styles on every page, for your own scripts. |
| `showcase` | off | `{enabled: true, style: bar, starter:, docs_url:, use_url:}`: on a starter's demo build, a bar (or with `style: pill` a floating pill) that links back to the theme's documentation. Set it in a demo-only config file. See [Starter demo showcase](../../reference/showcase/). |
| `chart` | off | `{enabled: true, src:, integrity:}`: a line holding only `chart:<type>` right before a table makes the table a chart figure, which your Chart.js (`src`) draws. See [Charts](../../recipes/figures/charts/). |
| `subscribe` | none | `{action: https://…}`: where the `c: subscribe` email form sends sign-ups. |

`modootoday-check` validates every key. The full list of stable names is in [Public API](../../reference/api/).

### More about some keys

- `color_scheme`: `auto-dark` and `auto-light` keep the toggle and remember the reader's choice; `light` and `dark` have no toggle. The starting scheme is printed in the HTML, so nothing flashes.
- `components`: `lists`, `bleed`, `terminal`, `visual`, `filter`, `table`, `table-stack` and `showcase` are always included. Their sheets reach only pages that turn them on with `lists:` or `hero: {checks: true}`, `bleed:`, `chrome: terminal`, `script:` or `poster:`, `filter:` or `filter_text:`, or `modootoday.showcase`, or have a table in the body. With a shorter list, add `figure-svg` next to `figure` to keep the SVG figure styles (dark tone, horizontal scroll, also the region around static math), and `diagram` to keep the light and dark swap of static diagrams.
- `nav`: previous and next links walk the file in order: a group's own page, then its items. Without that file the header reads `main` in `_data/navigation.yml`, then `header_pages` (a list of page paths, as in minima), then, on sites of up to 100 HTML pages, lists every top-level page (such as `/about/`) with a `title` (`nav_order` first, then by title; `nav: false` or `nav_exclude: true` leaves a page out). `nav: false` turns that last list off.
- `sidebar`: below 64rem it folds into a menu above the page. `sidebar: false` in front matter hides it on one page.
- `page_actions`: the menu appears on pages with a Markdown twin and offers View as Markdown, Copy page and Copy for AI (the source URL, then the Markdown). `page_actions: false` in front matter turns it off on one page; leave `page-actions` out of `components` to drop it entirely.
- `tokens`, `tokens_dark`: the values go into an inline `<style>`.
- `site_css`, `preload`: `site_css` sheets get the same `?v=` query as the theme sheets. A `preload` `href` is a site path and `as` is one of `font`, `image`, `style`, `script`, `fetch`; fonts and fetches add `crossorigin`, and no `?v=` query is added. Front matter `site_css:` and `preload:` add more on one page.
- `scripts`: each entry is `{src, css, preload, element}` with site paths: `src` a `.js` file, `css` a sheet, `preload` the modules to `modulepreload`, `element` the custom element it defines (lowercase with a hyphen, not `mt-`, one entry per element), which `c: widget` and `widget:` place.
- `aliases`: `modootoday-stubs --aliases` writes the stub files and `modootoday-check --aliases` checks them. `md` is not available with `twins: source`.
- `records`: each set takes `{data, key, dir, permalink, layout, title, description, facts, labels, body, lang}`. `modootoday-stubs --records` writes the pages and `modootoday-check` checks them.
- `schema`: the graph takes `publisher`, `search_url`, `layouts` and `faq`.
- `languages`: the header site title links to the page language's home (`/<lang>/`) when it exists.
- `lists`: on plain sections and pages, a list of links only becomes `ul.mt-chips` and an item starting with `**Title**:` gets `strong.mt-item-title`. The optional `lists` sheet styles them (and `hero: {checks: true}`) and is linked only where used.
- `heading_anchors`: the link is `a.mt-anchor` at the end of the heading, after its text, named "Link to section: [heading]" in the page language; it needs no script. Headings in component sections (`c:`) stay as they are, and the table of contents, search and the Markdown twins do not change. A `components` list keeps it only when it names `anchor`. The optional `anchor` sheet styles it and is linked only where used.
- `language_switcher`: each link goes to this page's translation, or that language's home page. The header menu keeps the same width however many languages there are, and nothing renders with fewer than two. The menu opens without JavaScript; `menu.js` adds Esc, arrow keys and closing on an outside click.
- `logo`, `favicon`: the `brand` mark is drawn in `currentColor` (the `brand` token, so it follows light and dark); your own logo image is decorative (`alt=""`). Override `modootoday/brand/logo.html` to draw something else. The `brand` favicon links an SVG, a 32 px PNG and an Apple touch icon.
- `header`: on screens narrower than 30rem (480 px), a site with a `logo` shows only the logo in the header. Screen readers still read the site name. Without a `logo` the name always shows.
- `diagrams`: a page lists its diagrams in front matter `diagrams:`, one entry per ```` ```mermaid ```` fence. `dir` is a site path; `dark: false` uses one SVG per diagram, darkened like other `.svg` figures; `source: none` drops the fence from the HTML.
- `mermaid`, `math`: the settings are `{enabled: true, src:, integrity:, theme: auto}` and `{enabled: true, engine: katex, src:, css:, integrity: {js:, css:}, auto_render_src:, auto_render_integrity:, inline: false}`, and they load only on pages with a block. `src` is a version-pinned https URL with an SRI `integrity` hash, or a path on your site. `inline: true` also renders `$…$`. `base: /assets/vendor/katex/` stands for `src`, `css` and `auto_render_src` of a self-hosted copy of KaTeX's `dist/` folder. `mode: static` (default `client`) loads no script: each block is replaced by the n-th entry of `_data/math/<key>.yml`, which `modootoday-check SRC --math` lists and `script/figures/math.mjs` writes; it needs no `enabled`, `src` or `integrity`, and `enabled: false` turns it off. A CDN adds its origin to `script-src` (math also to `style-src` and `font-src`) and sends visitors' IP addresses to it.
- `chart`: `src` is Chart.js 4 (`dist/chart.umd.min.js`) with the same URL and `integrity` rules; it and the theme's chart module load only on pages with a chart. Without `src` charts stay tables.
- `banner`: the bar sits under the skip link.
- `loading`: pages that use the spinner or skeleton in Markdown load the sheet on their own.

## Links that open a new window

Opening a new window is opt-in. Set it per link or for every external link (a link that does not start with the site's `url:`).

```yaml
# _config.yml: every external link
modootoday:
  external_links:
    new_window: true
    icon: true        # false hides the arrow
```

```yaml
# per link: nav items, cards, buttons, link cards, directory items, pricing cta, footer links
- {title: "Status page", url: "https://status.example.com", new_window: true}
- {title: "Forum", url: "https://forum.example.com", target: _blank}
```

```markdown
[Release notes](https://github.com/modootoday/jekyll-theme-modootoday/releases "new-window")
```

Each such link gets `target="_blank"`, `rel="noopener noreferrer"`, a small arrow drawn in CSS, and a hidden hint ("opens in a new window", translated into the page language) that screen readers read through `aria-describedby`. There is no script, so a strict Content Security Policy keeps working. `new_window: false` on a link turns it off even when the site setting is on.

## Head and SEO

With `url:` set, every page gets a canonical link and Open Graph tags; no plugin is needed. With `languages:` set, pages that exist in several languages link each other with `hreflang`. Sitemaps and feeds are opt-in plugins that GitHub Pages allows:

```yaml
url: https://example.github.io
modootoday:
  languages: [en, ko]
  edit_url: https://github.com/OWNER/REPO/edit/main/docs/
plugins: [jekyll-remote-theme, jekyll-sitemap, jekyll-feed]
```

Each feedback link opens a prefilled GitHub form: the issue title is the page title ("Helpful: " or "Not helpful: " before it for the two answers), and the body is the page URL. The theme adds no script and sends nothing: a reader's browser makes no request until they click, and GitHub asks them to sign in before anything is filed. Labels apply only when the reader may label issues in that repository, and a label that does not exist is ignored.

`edit_url: auto`, `build_link: true` and `feedback.issues: auto` read `site.github`, which GitHub Pages fills in from the repository it builds; the link is left out when the repository or commit is unknown. Elsewhere add the `jekyll-github-metadata` plugin, or set a `github:` map in `_config.yml` with `repository_url`, `source: {branch, path}` and `build_revision`, which stands in for it; `modootoday-check` warns when none of these is there. An explicit `edit_url` URL always wins over `auto`. When GitHub Pages cannot read the repository's Pages settings (a build outside GitHub, or without a token), `source` falls back to the `gh-pages` or `master` branch at the root, so set the URL by hand there.

To use `jekyll-seo-tag` instead, set `seo: false` and put the jekyll-seo-tag `seo` tag in `_includes/head-custom.html`. A page can show its date with `last_modified_at:` in front matter. The first breadcrumb shows the home page `short_title:` (front matter) when set, otherwise its `title`. Strict Content Security Policy: see [CSP](../../recipes/csp/).

## Languages

Put interface strings in `_data/i18n/<lang>.yml`; translated pages sit beside their source or in `<lang>/` (see below):

```yaml
language: 한국어
site_title: 모두의오늘 테마   # header, <title>, og:site_name and JSON-LD name; falls back to site.title
callout: {note: 참고, tip: 팁, important: 중요, warning: 경고, caution: 주의}
tabs: {label: 설치 방법}
status: {available: 사용 가능, partial: 일부 구현, planned: 계획}
skip: 본문으로 건너뛰기
```

Set `lang:` and the theme's own labels (skip link, navigation, callouts, status badges, table of contents, pagination, code copy, search, language menu) are already localized for 23 languages: en, zh-CN, zh-TW, ja, ko, tr, ru, vi, th, de, es, fr, uk, pl, pt-BR, ar, fa, id, it, el, ml, ur-Latn, ro. Nothing needs to be copied, on GitHub Pages or with Jekyll 4. A code with a region the theme does not ship uses its base language (`pt` → pt-BR, `zh` → zh-CN); any other language shows English.

Each label is resolved in this order:

1. your `_data/i18n/<lang>.yml`, key by key
2. the theme's catalog for that language
3. English

So a site catalog only needs the keys you want to change, plus anything your own components read. Use the `.yml` extension; the checker rejects `.yaml`. To start from the theme's wording, copy a catalog and check it:

```sh
modootoday-check . _site --i18n-init=ko   # optional: copy the theme's ko.yml to edit
modootoday-check . _site --i18n           # unknown keys and placeholder mismatches
```

For a language the theme does not ship, add `_data/i18n/<code>.yml` with the keys of the English catalog and list the code in `languages`. Pages get `dir="rtl"` for Arabic, Persian, Hebrew, Urdu and other right-to-left languages (`ur-Latn` stays left-to-right); `direction: rtl` or `ltr` in a catalog or in front matter overrides it. Page content is translated as Markdown, not in the catalogs, in one of two layouts. Beside the source: `guides/start.ko.md` next to `guides/start.md`, with `lang: ko` and `permalink: /ko/guides/start/` in front matter, because Jekyll cannot derive that URL from the file name. Or in a folder: `ko/guides/start.md`, with a `defaults` scope (`path: ko`, `lang: ko`). A language that translates only the home page can keep it as `home/index.<lang>.md` (`permalink: /<lang>/`).

Pages that translate each other under different paths share a `ref:` in front matter, such as `ref: guide` on `guides/start.md` and `ko/guides/sijak.md`. `hreflang` links and the language switcher then use that page; a page with `ref:` and no translation is left out of `hreflang`, and the switcher sends that language to its home page. In includes and layouts, `modootoday/link.html` with `ref="guide"` gives the URL of the `ref: guide` page in the current language, or in the default language when there is none (add `exact=true` for no fallback, `absolute=true` for a full URL); `modootoday-check` reports a `ref=` that no page defines. With `full_languages` set, `modootoday-check . _site --i18n-pages` lists default-language pages that have no translation in those languages (same `ref:`, `<name>.<lang>.md` beside the page, or the same path under `<lang>/`); they are warnings, and `--strict` makes them fail. Posts, record pages, lists of records and pages at a file URL such as `/404.html` are not translated page by page and are left out. The same option reads each translation's `source_rev:`, the revision of the source it was translated from (`sha256:` and 12 hex digits of the source's `title`, `description`, `nav_title` and body). A translation without one, or whose source changed since, is a warning that prints the current value. A translation beside its source whose `permalink` is not the source's URL under `/<lang>` is an error.

Some labels are your site's, not the theme's: `tabs.label` names the tab list on pages that use tabs (for example `tabs: {label: Install method}`), so screen readers announce what the tabs choose between. Put it in each language's catalog.

In your own includes, `modootoday/t.html` with `key="nav.label"` prints a label with the same resolution.

## Component registry

An optional `_data/components.yml` lets the checker validate `sections:` parameters:

```yaml
features: {params: {cols: {allowed: [2, 3, 4], required: false}, badge: {allowed: [bottom], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```

md-components v1

# md-components rules

Goal: page bodies (`*.md`, `<lang>/*.md`) use only standard GitHub Flavored Markdown (plus GitHub's alert extension) that renders unchanged on github.com. Design comes from layouts, includes, CSS and optional JS. Targets: the GitHub Pages build (`github-pages` gem 232, Jekyll 3.10, kramdown GFM, allowed plugins only, no build scripts) and Jekyll 4.

Status: **final** (v1, approved 2026-10-30). `md-components v1` is the name of this Markdown rules standard; changes are listed in `CHANGELOG.md`.

## 0. Front matter
Every content page starts with front matter; an empty block (`---` then `---`) is enough. Reason: on GitHub Pages, `jekyll-optional-front-matter` renders a file without front matter and the raw file is also copied to `_site/<name>.md`. Checker error, except in the opt-in front-matter-less twin mode (`modootoday.twins: source`, §5a), which uses exactly that copy as the twin.

## 1. Core components
| Component | Markdown | Transformation | Fallback (no JS / GitHub viewer / twin) |
|---|---|---|---|
| Alerts (5) | top-level quote whose first line is exactly `> [!NOTE]` (TIP/IMPORTANT/WARNING/CAUTION; any case), body on the following `>` lines. The body may start with a paragraph, a blank `>` line, a list, a code block or a `###` heading. Alerts are a **GitHub extension outside the GFM spec**; other parsers show a plain quote | `_includes/modootoday/markdown/components.html` converts kramdown's `<p>[!TYPE]` + body, standalone `<p>[!TYPE]</p>` and `[!TYPE]<br />` (trailing spaces) into `blockquote.mt-callout.mt-callout-<type>[role=note]` with a localised title | quote / GitHub alert / source |
| Sections | `# Title`, lead paragraph, link-only paragraph (CTA), then `## Section`; front matter `sections:` | `doc` layout → `_includes/modootoday/markdown/sections.html`: with `sections:` the part before the first `##` is `section.mt-hero` and item *i* wraps the *i*-th **top-level** `##` in `section.mt-section` (an `h2` nested in a quote, list or alert never splits); without it, one `div.mt-prose` | plain document |
| Section decor | front matter `decor: <include>` on `hero:` or a section item | the include inside `div.mt-section-decor[aria-hidden=true]` at the end of the section, which gets `.mt-has-decor` | not shown |
| List styles (optional) | `modootoday.lists: {link_chips, titled_items}`; `hero: {checks: true}` | plain sections and pages: link-only list → `ul.mt-chips`, `- **Title**: text` → `strong.mt-item-title` + `span.mt-item-sep`; hero: `.mt-hero-checks`; first `p` after the `h1` → `p.mt-hero-lead` | plain lists |
| Split hero | front matter `hero: {c: split, visual: <name>, side: start\|end, ratio: "1:1"\|"5:7"}` | `section.mt-hero.mt-c-split` > `.mt-section-in` > `.mt-section-body` (h1, lead, checks, actions) + `.mt-section-visual`; split sheet | other `c`, a missing `visual:`, other side/ratio values are checker errors |
| Split code | `visual: code` on `c: split` or a split hero (optional `chrome: terminal`) | the first code block moves into `div.mt-section-visual.mt-split-code` (`.mt-split-terminal` + `div.mt-split-bar[aria-hidden]`); split sheet, plus the terminal sheet only with `chrome: terminal` | no fence in that item, or `chrome:` without split + `visual: code`, are checker errors |
| Scroll reveal | front matter `reveal: true` on `hero:` or a section item | `.mt-reveal` on the section; CSS-only fade-in on scroll inside `@supports (animation-timeline: view())` and `prefers-reduced-motion: no-preference` | shown as is |
| Full-width band | front matter `bleed: true` or `bleed: wide` on `hero:` or a section item | `.mt-bleed` (plus `.mt-bleed-wide`) on the section, no wrapper; the optional `bleed` sheet paints `--mt-bleed-bg` to the viewport edges, `wide` widens the content up to the container | other values are checker errors |
| Card badge at the bottom | `badge: bottom` on a `c: features` item | `.mt-badge-bottom` on the section; a `.mt-badge` that is a direct child of a card sits at its bottom edge | badge after the text |
| Section mapping | each `sections:` item is a string `name` or `{c: component, name: key, ...params}`. No implicit mapping. Item count ≠ top-level `## ` count is a checker error; setext `---` headings, `##` in quotes/alerts/list items, `##` indented 1–3 spaces and `##` inside HTML comments are checker errors | `data-section`=name, `data-c`=c, class `mt-c-<c>` | none |
| Card grid | under `##`, list items `- **Title** — text` or `- **Title**: text` | CSS only | list |
| CTA buttons | every link-only paragraph in `section.mt-hero` and in `c: cta` sections; the first link is primary. Separator text such as `·` between links is a text node, so the paragraph still counts as link-only | CSS `p:has(> a):not(:has(> :not(a)))` | links |
| Install tabs | in a `c: tabs` section, repeated `### name` + fenced code block (info string = one language word) | `data-tabs` + i18n `tabs.label`; `assets/js/modootoday/tabs.js` builds WAI-ARIA tabs (arrows, Home, End) | all blocks in order |
| Diagrams, math | ```` ```mermaid ```` / ```` ```math ````, a `$$` block on its own lines; inline `$…$` only with `modootoday.math.inline: true` (otherwise a checker warning) | off by default. `modootoday.mermaid` / `modootoday.math` load a version-pinned renderer with SRI `integrity` (or a self-hosted path) plus `assets/js/modootoday-{mermaid,math}.js`, only on pages with a block; front matter `mermaid: false` / `math: false` skips a page. A CDN adds its origin to `script-src` (math also `style-src`, `font-src`) and receives visitors' IP addresses; Mermaid needs `style-src 'unsafe-inline'`. Any other third-party script or stylesheet, or one without matching `integrity` and `crossorigin="anonymous"`, is a checker error (docs: Math and diagrams) | code / GitHub mermaid, math |
| Tables | GFM tables | CSS horizontal scroll | table |
| Decoration | front matter or layout | read by layouts, never in bodies | none |

## 2. Optional components
| Component | Markdown | Transformation | Notes |
|---|---|---|---|
| Status badge | code span `` `status:available` `` / `partial` / `planned` (fixed set) | with badges on (default; `badges: false` per page or `modootoday.badges: false` site-wide): `span.mt-badge.mt-badge-<value>` = symbol (●◐○, `aria-hidden`) + i18n `status.<value>` | unknown values and leftover `<code>status:` in the build are checker errors |
| Tag badge | `` `tag:beta` `` (one token `[A-Za-z0-9._-]+`) | `span.mt-badge.mt-badge-tag` | needs the `badge` component; bad values are checker errors. `since:` is not part of 1.0 and is a checker error |
| Accordion | `c: accordion` section, each `###` is a question | JS turns `###` into `button[aria-expanded]` + panel; content stays visible without JS | — |
| Steps | `c: steps` section with an `ol` or `###` items | CSS counters | — |
| Figure | an image-only paragraph followed by an `*emphasis*`-only paragraph | `figure` + `figcaption`; an `.svg` image gets `figure.mt-figure-svg` with a focusable `div.mt-figure-scroll[role=region]` named by the alt text, and the optional `figure.css` sheet (dark tone `--mt-diagram-filter-dark`, `#light` keeps one image as drawn; `--mt-figure-min-width` then horizontal scroll) | images without alt (`![](...)`) are checker errors |
| Breadcrumb / TOC / theme toggle | automatic (`breadcrumb: false`, `toc: false` per page; TOC shows with 2+ `##`/`###`; toggle only with `color_scheme: auto`) | `nav.mt-breadcrumb`, `nav.mt-toc`, header button (i18n `theme.toggle`, `breadcrumb.label`, `toc.label`) | — |
| Timeline | `c: timeline` section; each `###` is a date or milestone, content follows | CSS line and dots | — |
| Keyboard keys | `` `kbd:Ctrl+K` `` (keys joined by `+`, no spaces) | `kbd.mt-kbd > kbd` per key | bad values are checker errors |
| Search | add `search.json` with `layout: null` and `{% include modootoday/search.json %}` | header `div.mt-search[role=search]` (i18n `search.label`) + `search.js` (under 1 KB compressed); pages with `search: false` are left out | rendered only when `/search.json` exists |
| Post layout | `layout: post` (`date`, optional `author`, `tags`) | `p.mt-post-meta` (date with i18n `post.date_format`, author, tag badges), then the doc pipeline | — |
| Code title | a line holding only `` `file:path` `` right before a fenced block | `div.mt-code` > `p.mt-code-title` + block | a lone `file:` line not followed by a fence is a checker error |
| Progress | `` `progress:60` `` (whole number 0–100) | `span.mt-progress` > `progress` + value text (i18n `progress.label`) | out of range is a checker error |
| Embed | a paragraph holding only `` `embed:https://… Title` `` | `div.mt-embed` > lazy `iframe[title]` (16:9 reserved) | non-https is a checker error |
| Loading / skeleton | `` `loading:spinner` ``, `` `loading:bar` ``, `` `skeleton:text` `` / `card` / `image` / `avatar` / `row` | `span.mt-spinner`, `span.mt-topbar`, `span.mt-skeleton` with `role=status`, `aria-busy` and i18n `loading.label`; optional `loading` sheet; reduced motion, forced colors and RTL | unknown variants are checker errors |
| File tree / Details / FAQ / Params / Link cards / Quote / Gallery / Pricing / Subscribe / Split | `c: filetree` (nested list), `c: details` and `c: faq` (`###` per item), `c: params` (table), `c: linkcards` (link-first list), `c: quote` (quote ending in `— name`), `c: gallery` (tight image list), `c: pricing` (`###` per plan, param `recommended`), `c: subscribe` (text; form posts to `modootoday.subscribe.action`), `c: split` (text beside its `visual:`, params `side`, `ratio`; the only section with inner wrappers) | per-component markup listed in docs api.md; each has its own sheet | gallery images need alt; `recommended` must be in range; subscribe action must be https; split needs `visual:` |
| Component registry | optional `_data/components.yml`: `name: {params: {key: {allowed: [...], required: bool}}, i18n: [keys...]}` | when present the checker validates `c`, params and i18n keys | — |

## 3. Localisation
- Chrome strings use `_data/i18n/<lang>.yml`: `callout.<type>`, `tabs.label`, `status.<value>`, `skip`. Missing keys fall back to English.
- The same rules apply to `<lang>/*.md`.

## 3a. Writing direction
RTL languages (`ar fa he ur yi ps sd ug dv ckb`, by the first subtag of `lang`) get `<html dir="rtl">`; front matter `direction: rtl|ltr` or i18n `direction:` overrides. Theme CSS uses logical properties for inline-start/end; code blocks, inline code and `kbd` stay LTR/isolated. Write the Markdown in logical order; never use bidi control characters to fake layout.

## 4. Forbidden (outside code blocks and code spans)
The bans are about **portability**: the same source must look the same on github.com, in kramdown (which passes raw HTML through and adds its own extensions) and in the plain-text twin.

| Forbidden | Why | Check |
|---|---|---|
| raw HTML (`<div>`, `<details>`, `<kbd>` …) | not portable: GitHub renders some tags (`details`, `kbd`) and strips or escapes others (`script`, `iframe`), kramdown passes everything through; keeps twins readable | checker |
| HTML comments `<!-- -->` | hidden on GitHub but emitted by kramdown; a `##` inside one shifts section counts. Exceptions: a tool region marker alone on its line, `<!-- tool:name:begin -->` / `<!-- tool:name:end -->` (lowercase, ends in `:begin` or `:end`); a one-line specfold value marker, own-line or inline, `<!-- spec:name -->` / `<!-- /spec:name -->` (lowercase letters, digits, `.`, `_`, `-`, `:`-separated), for example `<!-- spec:count -->12<!-- /spec:count -->`; arguments may follow the name after a space, `<!-- spec:count rows="All commands" -->12<!-- /spec:count -->`, on the same line and without `>`, `--` or `##` | checker |
| Liquid `{% %}` `{{ }}` | breaks on GitHub and in twins | checker |
| kramdown IAL/ALD `{: .x}`, `{:toc}` | kramdown-only | checker |
| header ids `{#id}` | kramdown-only (literal text on GitHub) | checker |
| definition lists `: text` | kramdown-only | checker |
| abbreviations `*[HTML]: …` | kramdown-only (literal text on GitHub) | checker |
| bare URL / `www.` / e-mail autolinks | GFM autolink extension; kramdown leaves them as text. Use `<https://…>` or `[text](url)` | checker |
| alerts inside lists, tables or quotes | GitHub: "alerts cannot be nested"; not converted | checker (source + leftover `[!TYPE]` in the build, outside `<pre>`/`<code>`) |
| unregistered alert types `> [!FOO]` | plain quote everywhere | checker error |
| text after the marker `> [!NOTE] Title` | GitHub shows a plain quote (no custom titles) | checker error |
| empty alert (marker only) | GitHub shows a plain quote | checker error |
| formatted marker `> **[!NOTE]**`, tab after `>` | not an alert / kramdown code block | checker error |
| `##` that is not a top-level ATX heading (setext `---`, in quote/alert/list, indented 1–3 spaces, in a comment) | parsers disagree; sections would split inside other blocks | checker error |
| code fence info-string attributes (```` ```sh {title=x} ````, `~~~sh {.x}`, ```` ```sh title=x ````) | kramdown 2.4 turns the block into inline code | checker error: info string must be a single language word |

Allowed and portable: footnotes `[^1]` (markup differs slightly), task lists, strikethrough, GFM tables, `<url>` autolinks, hard breaks. Note: `> [! NOTE]` (space inside) is not an alert; the checker warns, `--strict` makes it an error.

## 5. Checker (`modootoday-check SRC SITE [--twins] [--github-pages[=VER]] [--strict] [--gh]`)
1. front matter present 2. forbidden syntax, alert form, fence info strings 3. `status:` vocabulary 4. `sections:` count = top-level `## ` count, nested/setext/indented `##` 5. `_data/components.yml` if present 6. no `[!TYPE]` (any case, outside `<pre>`/`<code>`) / `<code>status:` in built HTML 7. `--github-pages`: `Gemfile.lock` pins github-pages VER (default 232, or `$MODOOTODAY_GITHUB_PAGES`) 8. `--twins`: rules below 8a. Sass sources (`_sass/`, `assets/**/*.scss`) and built CSS: no `@use`/`@forward`/`@supports selector()`, no `--x: $var` literals, every `var(--mt-*)` defined 8b. `_config.yml` `modootoday:`: `twins` is `true`, `false` or `source`, known `color_scheme`/`components`, boolean `css_layers`/`badges`, `tokens`/`tokens_dark` values are plain CSS values (no `; { } < >`, valid hex), unknown token names warn 9. `--gh` (optional, network + `gh` auth): render with `gh api markdown`.

## 5a. Markdown twins
Three ways to publish a page's raw Markdown next to its HTML. Pick one per site (stubs may be mixed with the others for single pages).

| Mode | How | Twin URL | Use when | Limits |
|---|---|---|---|---|
| Stub (default) | `<name>.md.txt` with `layout: twin`, `twin_of`, `permalink` | `/<name>/index.md` | classic GitHub Pages, pages need front matter (`sections:`, `title`, `lang`) | one extra file per page |
| Generator | `plugins: [jekyll-theme-modootoday]` | `/<name>/index.md` | Jekyll 4 or a GitHub Actions build | not run by classic GitHub Pages |
| Source (front-matter-less) | `modootoday.twins: source`; pages have **no** front matter | the source path: `/<name>.md`, `/<dir>/index.md` | classic GitHub Pages without stubs; simple doc trees | see below |

Source mode relies on `jekyll-optional-front-matter`, a GitHub Pages default plugin: a `.md` file without front matter is rendered to HTML **and** copied verbatim to its own path, so the twin is the whole source file (byte-identical, no front matter to strip). Limits:
- No per-page front matter: layout, `lang`, `permalink` and other settings come from path-based `defaults:` in `_config.yml`; the title comes from the first `# ` heading (`jekyll-titles-from-headings`). Per-page `sections:` is not available (use a `defaults:` scope for a single file if needed).
- Links to `other.md` in bodies are not rewritten to the HTML page in this mode; they reach the raw twin. Link to `other/` instead.
- Local and Actions builds must list `plugins: [jekyll-optional-front-matter, jekyll-titles-from-headings]` (Jekyll 4: add both gems); the classic GitHub Pages build enables them by default.
- `optional_front_matter.remove_originals: true` or `require_front_matter: true` disables the raw copy; the checker reports both.
- Pages that keep front matter in source mode still need a stub or the generator; a stub next to a front-matter-less page is redundant (checker error).
- The `default` layout and `llms.txt` link to the raw copy (`/<path>.md`) when it exists.
- Observed on classic GitHub Pages (legacy build, `remote_theme`; one sample site, checked once on 2026-10-30): the raw copy at `/<name>.md` and `/<dir>/index.md` was served as `Content-Type: text/markdown; charset=utf-8` and was byte-identical to the source; `llms.txt` was served as `text/plain; charset=utf-8`; the HTML page carried the `rel="alternate" type="text/markdown"` and `rel="describedby"` links. `remote_theme` of this public theme also worked from a private repository (a Pages site built from a private repository is still public unless access control is set). Not verified: cache/CDN behaviour, other file extensions, non-English pages.

Stub and generator details:
- Source `<name>.md`. The twin comes from either
  - the opt-in generator `plugins: [jekyll-theme-modootoday]` (Jekyll 4 or an Actions build; not run by the classic GitHub Pages build, which allows only whitelisted plugins), or
  - a stub `<name>.md.txt` next to it with only `layout: twin`, `twin_of`, `permalink` and no body (works everywhere). `twin_of` is relative to the stub: `twin_of: install.md` in `guides/install.md.txt`; a path from the site root such as `guides/install.md` fails with "Could not locate the included file". Liquid cannot create output files, so on classic GitHub Pages a stub per page is unavoidable.
  Both produce the same page; a stub wins over the generator. `twin: false` opts a page out.
- Output: `index.md` → `/index.md`, others → `/<dir>/<name>/index.md`; other languages under `/<lang>/`.
- Twin body is **byte-identical** to the source minus front matter (no added headers; put extra information in `llms.txt`).
- `llms.txt` and `llms-full.txt` exist at `/` and under each `/<lang>/`. `llms.txt` follows llmstxt.org: `# Title`, a `>` summary, then `## Section` lists of `- [Name](url): note`. `llms-full.txt` is a common convention, not part of llmstxt.org. Layouts `llms` and `llms-full` generate both from a front-matter-only stub (or the generator adds them); `llms-full.txt` is every page body of that language, byte-identical, separated by a blank line.
- The `default` layout adds `<link rel="alternate" type="text/markdown" href=".../index.md">` when the twin exists and `<link rel="describedby" type="text/plain">` to the nearest `/<lang>/llms.txt` or `/llms.txt`.
- With `--twins` and `modootoday.twins: source`: a front-matter-less page needs a rendered page (`<name>.html` or `<name>/index.html`) and a byte-identical raw copy at its source path.
- With `--twins`: a missing or non-identical twin is an error (`README.md` and `twin: false` excepted), a stub must use `layout: twin` with an empty body, `llms.txt` must start with `# `, and `llms-full.txt` must contain every page body of its language.
- Twins and the checker assume directory URLs (`permalink: pretty` or `/<name>/`); with `.html` permalinks the generator writes `/<name>.md` but the checker still expects `/<name>/index.md`.
- Twin bodies go through Liquid (`include_relative`); bodies must not contain Liquid (already forbidden in §4).

## 6. Known limitations
- `##` inside an alert, quote or list item stays a checker error rather than a supported form: GitHub would render an `h2` inside the box, but sections split only on column-0 `## `. Use `###` or bold text there. Alerts nested in lists, tables or quotes are errors because GitHub renders only top-level alerts.
- Alert conversion depends on kramdown's output string (`<blockquote>` followed by `  <p>[!TYPE]`) and section splitting on top-level `<h2` starting a line. Tested with kramdown 2.4 (github-pages 232) and Jekyll 4; leftovers are detected by the checker.
- kramdown differences that the checker does not flag: smart quotes and dashes (`"a" -- b` → “a” – b; GitHub leaves them), `#` headings indented one space are paragraphs, and `\|` inside a code span in a table cell keeps the backslash in kramdown (GitHub shows `|`). Avoid `|` in table code spans.
- Liquid inside code (`{{ }}`) is still processed by Jekyll before kramdown; such pages need `{% raw %}` on the Jekyll side, which itself shows on GitHub.
- The stylesheet uses Sass `@import` so it compiles with both Ruby Sass (GitHub Pages) and Dart Sass (Jekyll 4); Dart Sass prints deprecation warnings unless the site sets `sass: {silence_deprecations: [import, global-builtin]}` (jekyll-sass-converter ≥ 3.1). Custom properties holding Sass values must interpolate (`--x: #{$v}`); Ruby Sass prints `$v` literally.
- Component classes are `mt-*`.
- Lists without a class get `margin-top: .3em` between items (`:where(:not([class])) > li + li`). A layout or include that turns an unclassed Markdown list into a grid or flex row (for example `.c-body > ul`) puts `mt-flat-list` on an ancestor to drop that gap; a list with any class of its own is already exempt.
- CTA buttons need `:has()`; without it they stay links.

## 7. Design tokens artifact
CI generates a DTCG `tokens.json` from the Sass token maps (`script/tokens-json`) and uploads it as a build artifact. It is read-only: edit the Sass maps, never the JSON. A test keeps it consistent with the built CSS.

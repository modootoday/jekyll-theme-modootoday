md-components v1 (draft)

# md-components rules

Goal: page bodies (`*.md`, `<lang>/*.md`) use only standard GitHub Flavored Markdown (plus GitHub's alert extension) that renders unchanged on github.com. Design comes from layouts, includes, CSS and optional JS. Targets: the GitHub Pages build (`github-pages` gem 232, Jekyll 3.10, kramdown GFM, allowed plugins only, no build scripts) and Jekyll 4.

Status: **draft**. v1 has not been declared final.

## 0. Front matter
Every content page starts with front matter; an empty block (`---` then `---`) is enough. Reason: on GitHub Pages, `jekyll-optional-front-matter` renders a file without front matter and the raw file is also copied to `_site/<name>.md`. Checker error.

## 1. Core components
| Component | Markdown | Transformation | Fallback (no JS / GitHub viewer / twin) |
|---|---|---|---|
| Alerts (5) | top-level quote whose first line is exactly `> [!NOTE]` (TIP/IMPORTANT/WARNING/CAUTION; any case), body on the following `>` lines. The body may start with a paragraph, a blank `>` line, a list, a code block or a `###` heading. Alerts are a **GitHub extension outside the GFM spec**; other parsers show a plain quote | `_includes/md-components.html` converts kramdown's `<p>[!TYPE]` + body, standalone `<p>[!TYPE]</p>` and `[!TYPE]<br />` (trailing spaces) into `blockquote.md-callout.md-callout-<type>[role=note]` with a localised title | quote / GitHub alert / source |
| Sections | `# Title`, lead paragraph, link-only paragraph (CTA), then `## Section`; front matter `sections:` | `doc` layout → `_includes/md-sections.html`: with `sections:` the part before the first `##` is `section.md-hero` and item *i* wraps the *i*-th **top-level** `##` in `section.md-section` (an `h2` nested in a quote, list or alert never splits); without it, one `div.md-prose` | plain document |
| Section mapping | each `sections:` item is a string `name` or `{c: component, name: key, ...params}`. No implicit mapping. Item count ≠ top-level `## ` count is a checker error; setext `---` headings, `##` in quotes/alerts/list items, `##` indented 1–3 spaces and `##` inside HTML comments are checker errors | `data-section`=name, `data-c`=c, class `md-c-<c>` | none |
| Card grid | under `##`, list items `- **Title** — text` or `- **Title**: text` | CSS only | list |
| CTA buttons | every link-only paragraph in `section.md-hero` and in `c: cta` sections; the first link is primary. Separator text such as `·` between links is a text node, so the paragraph still counts as link-only | CSS `p:has(> a):not(:has(> :not(a)))` | links |
| Install tabs | in a `c: tabs` section, repeated `### name` + fenced code block (info string = one language word) | `data-tabs` + i18n `tabs.label`; `assets/js/md-tabs.js` builds WAI-ARIA tabs (arrows, Home, End) | all blocks in order |
| Diagrams | ```` ```mermaid ```` | site-provided lazy renderer (not part of the theme) | code / GitHub mermaid |
| Tables | GFM tables | CSS horizontal scroll | table |
| Decoration | front matter or layout | read by layouts, never in bodies | none |

## 2. Optional components
| Component | Markdown | Transformation | Notes |
|---|---|---|---|
| Status badge | code span `` `status:available` `` / `partial` / `planned` (fixed set) | with badges on (default; `badges: false` per page or `modootoday.badges: false` site-wide): `span.md-badge.md-badge-<value>` = symbol (●◐○, `aria-hidden`) + i18n `status.<value>` | unknown values and leftover `<code>status:` in the build are checker errors |
| Component registry | optional `_data/components.yml`: `name: {params: {key: {allowed: [...], required: bool}}, i18n: [keys...]}` | when present the checker validates `c`, params and i18n keys | — |

## 3. Localisation
- Chrome strings use `_data/i18n/<lang>.yml`: `callout.<type>`, `tabs.label`, `status.<value>`, `skip`. Missing keys fall back to English.
- The same rules apply to `<lang>/*.md`.

## 4. Forbidden (outside code blocks and code spans)
The bans are about **portability**: the same source must look the same on github.com, in kramdown (which passes raw HTML through and adds its own extensions) and in the plain-text twin.

| Forbidden | Why | Check |
|---|---|---|
| raw HTML (`<div>`, `<details>`, `<kbd>` …) | not portable: GitHub renders some tags (`details`, `kbd`) and strips or escapes others (`script`, `iframe`), kramdown passes everything through; keeps twins readable | checker |
| HTML comments `<!-- -->` | hidden on GitHub but emitted by kramdown; a `##` inside one shifts section counts | checker |
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
1. front matter present 2. forbidden syntax, alert form, fence info strings 3. `status:` vocabulary 4. `sections:` count = top-level `## ` count, nested/setext/indented `##` 5. `_data/components.yml` if present 6. no `[!TYPE]` (any case, outside `<pre>`/`<code>`) / `<code>status:` in built HTML 7. `--github-pages`: `Gemfile.lock` pins github-pages VER (default 232, or `$MODOOTODAY_GITHUB_PAGES`) 8. `--twins`: rules below 8a. Sass sources (`_sass/`, `assets/**/*.scss`) and built CSS: no `@use`/`@forward`/`@supports selector()`, no `--x: $var` literals, every `var(--mt-*)` defined 8b. `_config.yml` `modootoday:`: known `color_scheme`/`components`, boolean `css_layers`/`badges`, `tokens`/`tokens_dark` values are plain CSS values (no `; { } < >`, valid hex), unknown token names warn 9. `--gh` (optional, network + `gh` auth): render with `gh api markdown`.

## 5a. Markdown twins
- Source `<name>.md`. The twin comes from either
  - the opt-in generator `plugins: [jekyll-theme-modootoday]` (Jekyll 4 or an Actions build; not run by the classic GitHub Pages build, which allows only whitelisted plugins), or
  - a stub `<name>.md.txt` next to it with only `layout: twin`, `twin_of`, `permalink` and no body (works everywhere). Liquid cannot create output files, so on classic GitHub Pages a stub per page is unavoidable.
  Both produce the same page; a stub wins over the generator. `twin: false` opts a page out.
- Output: `index.md` → `/index.md`, others → `/<dir>/<name>/index.md`; other languages under `/<lang>/`.
- Twin body is **byte-identical** to the source minus front matter (no added headers; put extra information in `llms.txt`).
- `llms.txt` and `llms-full.txt` exist at `/` and under each `/<lang>/`. `llms.txt` follows llmstxt.org: `# Title`, a `>` summary, then `## Section` lists of `- [Name](url): note`. `llms-full.txt` is a common convention, not part of llmstxt.org. Layouts `llms` and `llms-full` generate both from a front-matter-only stub (or the generator adds them); `llms-full.txt` is every page body of that language, byte-identical, separated by a blank line.
- The `default` layout adds `<link rel="alternate" type="text/markdown" href=".../index.md">` when the twin exists and `<link rel="describedby" type="text/plain">` to the nearest `/<lang>/llms.txt` or `/llms.txt`.
- With `--twins`: a missing or non-identical twin is an error (`README.md` and `twin: false` excepted), a stub must use `layout: twin` with an empty body, `llms.txt` must start with `# `, and `llms-full.txt` must contain every page body of its language.
- Twins and the checker assume directory URLs (`permalink: pretty` or `/<name>/`); with `.html` permalinks the generator writes `/<name>.md` but the checker still expects `/<name>/index.md`.
- Twin bodies go through Liquid (`include_relative`); bodies must not contain Liquid (already forbidden in §4).

## 6. Known limitations
- `##` inside an alert, quote or list item stays a checker error rather than a supported form: GitHub would render an `h2` inside the box, but sections split only on column-0 `## `. Use `###` or bold text there. Alerts nested in lists, tables or quotes are errors because GitHub renders only top-level alerts.
- Alert conversion depends on kramdown's output string (`<blockquote>` followed by `  <p>[!TYPE]`) and section splitting on top-level `<h2` starting a line. Tested with kramdown 2.4 (github-pages 232) and Jekyll 4; leftovers are detected by the checker.
- kramdown differences that the checker does not flag: smart quotes and dashes (`"a" -- b` → “a” – b; GitHub leaves them), `#` headings indented one space are paragraphs, and `\|` inside a code span in a table cell keeps the backslash in kramdown (GitHub shows `|`). Avoid `|` in table code spans.
- Liquid inside code (`{{ }}`) is still processed by Jekyll before kramdown; such pages need `{% raw %}` on the Jekyll side, which itself shows on GitHub.
- The stylesheet uses Sass `@import` so it compiles with both Ruby Sass (GitHub Pages) and Dart Sass (Jekyll 4); Dart Sass prints deprecation warnings unless the site sets `sass: {silence_deprecations: [import, global-builtin]}` (jekyll-sass-converter ≥ 3.1). Custom properties holding Sass values must interpolate (`--x: #{$v}`); Ruby Sass prints `$v` literally.
- Component classes are `mt-*` (with the deprecated `md-*` kept alongside until v0.3).
- CTA buttons need `:has()`; without it they stay links.

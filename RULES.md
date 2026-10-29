md-components v1 (draft)

# md-components rules

Goal: page bodies (`*.md`, `<lang>/*.md`) use only standard GitHub Flavored Markdown that renders unchanged on github.com. Design comes from layouts, includes, CSS and optional JS. Targets: the GitHub Pages build (`github-pages` gem 232, Jekyll 3.10, kramdown GFM, allowed plugins only, no build scripts) and Jekyll 4.

Status: **draft**. v1 has not been declared final.

## 0. Front matter
Every content page starts with front matter; an empty block (`---` then `---`) is enough. Reason: on GitHub Pages, `jekyll-optional-front-matter` renders a file without front matter and the raw file is also copied to `_site/<name>.md`. Checker error.

## 1. Core components
| Component | Markdown | Transformation | Fallback (no JS / GitHub viewer / twin) |
|---|---|---|---|
| Alerts (5) | top-level quote whose first line is `> [!NOTE]` (TIP/IMPORTANT/WARNING/CAUTION), body on the following `>` lines | `_includes/md-components.html` replaces `<blockquote>\n  <p>[!TYPE]` with `blockquote.md-callout.md-callout-<type>[role=note]` and a localised title | quote / GitHub alert / source |
| Sections | `# Title`, lead paragraph, link-only paragraph (CTA), then `## Section`; front matter `sections:` | `doc` layout → `_includes/md-sections.html`: with `sections:` the part before the first `##` is `section.md-hero` and item *i* wraps the *i*-th `##` in `section.md-section`; without it, one `div.md-prose` | plain document |
| Section mapping | each `sections:` item is a string `name` or `{c: component, name: key, ...params}`. No implicit mapping. Item count ≠ `##` count is a checker error | `data-section`=name, `data-c`=c, class `md-c-<c>` | none |
| Card grid | under `##`, list items `- **Title** — text` or `- **Title**: text` | CSS only | list |
| CTA buttons | every link-only paragraph in `section.md-hero` and in `c: cta` sections; the first link is primary | CSS `p:has(> a):not(:has(> :not(a)))` | links |
| Install tabs | in a `c: tabs` section, repeated `### name` + code block | `data-tabs` + i18n `tabs.label`; `assets/js/md-tabs.js` builds WAI-ARIA tabs (arrows, Home, End) | all blocks in order |
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
| Forbidden | Why | Check |
|---|---|---|
| raw HTML (`<div>`, `<details>` …) | purity; GitHub sanitising | checker |
| Liquid `{% %}` `{{ }}` | breaks on GitHub and in twins | checker |
| kramdown IAL/ALD `{: .x}` | non-standard | checker |
| header ids `{#id}` | non-standard | checker |
| definition lists `: text` | broken on GitHub | checker |
| alerts inside lists, tables or quotes | not converted | checker (source pattern + leftover `[!TYPE]` in the build) |
| unknown alert types `> [!FOO]` | rendered as a plain quote | checker warning (`--strict`: error) |
| code fence info-string attributes (```` ```sh {title=…} ````) | kramdown GFM behaviour unverified | none (open) |

## 5. Checker (`modootoday-check SRC SITE [--twins] [--github-pages[=VER]] [--strict] [--gh]`)
1. front matter present 2. forbidden syntax 3. `status:` vocabulary 4. `sections:` count = `##` count 5. `_data/components.yml` if present 6. no `[!TYPE]` / `<code>status:` in built HTML 7. `--github-pages`: `Gemfile.lock` pins github-pages VER (default 232, or `$MODOOTODAY_GITHUB_PAGES`) 8. `--twins`: rules below 9. `--gh` (optional, network + `gh` auth): render with `gh api markdown`.

## 5a. Markdown twins
- Source `<name>.md`; stub `<name>.md.txt` next to it with only `layout: twin`, `twin_of`, `permalink` and no body.
- Output: `index.md` → `/index.md`, others → `/<dir>/<name>/index.md`; other languages under `/<lang>/`.
- Twin body is **byte-identical** to the source minus front matter (no added headers; put extra information in `llms.txt`).
- `llms.txt` and `llms-full.txt` exist at `/` and under each `/<lang>/`.
- With `--twins`, a page without a stub is an error (`README.md` excepted).

## 6. Known limitations
- Alert conversion depends on kramdown's output string (`<blockquote>` followed by a line indented two spaces). Gem versions are pinned in CI and leftovers are detected by the checker.
- The stylesheet uses Sass `@import` so it compiles with both Ruby Sass (GitHub Pages) and Dart Sass (Jekyll 4); Dart Sass prints deprecation warnings.
- CTA buttons need `:has()`; without it they stay links.

---
lang: ko
permalink: /ko/reference/cli/
source_rev: sha256:08994607d983
nav_order: 20
title: 명령줄
description: 검사기 modootoday-check와 스텁 작성기 modootoday-stubs의 모든 옵션, 그리고 각 종료 코드의 뜻을 정리합니다.
---
# 명령줄

> [!NOTE]
> 이 페이지는 [영어 원문](../../../reference/cli/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다. 옵션 표는 명령의 도움말에서 만들어지므로 영어 그대로 보여 줍니다.

테마 gem에는 명령이 두 개 들어 있습니다. `modootoday-check`는 원본과 빌드한 사이트를 읽고, github.com에서 다르게 보이거나 규칙을 어기는 것을 알려 줍니다. `jekyll build` 다음에 실행합니다. 읽는 페이지는 Jekyll이 읽는 페이지와 같습니다. SITE 폴더와, `_site_ko`의 다른 빌드처럼 이름이 `_`로 시작하는 폴더는 읽지 않습니다. 단 `_posts`, `_drafts`, 컬렉션, `include:`에 적은 폴더는 읽습니다. `modootoday-stubs`는 기본 GitHub Pages가 Markdown 버전, URL 별칭, 레코드 페이지에 필요로 하는 스텁 페이지를 씁니다. 빌드 전에 실행합니다. gem이 있을 때와 없을 때 실행하는 법은 [설치 > 빌드 확인](../../guides/install/)에 있습니다.

## 옵션

표는 각 명령의 `--help=markdown`에서 만들어집니다.

<!-- spec:docs-index:begin -->
### modootoday-check

`modootoday-check SRC SITE [options]`

| Option | Checks |
|---|---|
| `SRC SITE` | always: front matter, forbidden syntax, alerts, fence info strings, status/tag/kbd values (since is rejected), `sections:` count, `feed:` (false, or a site path to an Atom feed page in the build), `_data/i18n/<lang>.yml` keys against the default language and translated pages against default-language pages, `_data/components.yml` (keys, slot contract counts per section, `parts` against `api.md` and the built HTML), Sass/CSS rules, the token hook `_sass/modootoday/_site.scss` (only the three override maps, known token names), `site_css`, `preload` and `scripts` files present in the build, `script:` and `poster:` on hero and section items (a registered script, a sized poster that exists), `filter:` on section items and pages (a list or table to filter, a `facet` column the table has), `chart:` lines and `c: chart` sections (a type and options, a table or a `_data/charts` file, number cells), `widget:` lines, `widget_props` and `c: widget` sections (an element a `modootoday.scripts` entry defines, plain prop values, a lead paragraph), `diagrams:` (an entry per Mermaid fence, `alt`, the SVG files, an SVG drawn from another fence), static math (an entry per math block in `_data/math`, entries rendered from other TeX, no inline math),`modootoday.search` keys and collections, `modootoday.showcase` (also in `_config.demo.yml`) and, while it is enabled, the robots `noindex` on every built page (warning), `search.json` over 1.5 MB (warning), unconverted markers in the build, schema.org JSON-LD in the build (valid JSON, vocabulary, required properties per type, absolute URLs, ISO 8601 dates, one graph per page, agreement with Open Graph, a `DefinedTerm` page's `term_set` glossary), `modootoday.schema.faq`, `modootoday.records` (a page per record and a record per page, as `modootoday-stubs --records --check` judges), `modootoday.pwa` (its keys and icons, the stub `modootoday-stubs --pwa` writes, the built manifest's fields, icon files and their PNG sizes, the manifest link on every page), `modootoday.banner.release: latest` with no release banner on the built home page (warning) |
| `--twins` | every page has a byte-identical Markdown twin, per-language `llms.txt` and `llms-full.txt` |
| `--links` | same-site links in the built HTML (`a`, `link`, `img`, `script`, `source srcset`) point at files that exist and `#` fragments match an `id` or `a[name]` on the target page; external URLs are not fetched. Warnings, failures with `--strict`; needs the nokogiri gem, and fails the run without it |
| `--aliases` | the URL aliases `modootoday.aliases` declares: `/<page>.md` byte-identical to the twin (`md`), `/<page>.html` redirecting to the page with the page URL as canonical (`html`); two pages with one alias, or an alias over another source file, fail |
| `--byte-exact=DIR,...` | files under these source folders (an API, downloads) are in the build with the same sha256; a folder under `_` or `.` or excluded, a file with front matter, or one Jekyll converts (Markdown, Sass) fails |
| `--github-pages[=VERSION]` | `Gemfile.lock` pins `github-pages` VERSION (default 232) |
| `--schema-recommended` | also warn about schema.org properties Google Search recommends (author, image, dates, ...) that a JSON-LD node lacks |
| `--strict` | warnings fail the run |
| `--i18n` | `_data/i18n/<lang>.yml` against the theme registry (`i18n/en.yml` in the gem): unknown keys, `%{name}` placeholder mismatches, and pages marked `translation: pending` |
| `--i18n-pages` | warn about default-language pages with no translation in a `modootoday.full_languages` language (the page with the same `ref:`, else `<name>.<lang>.md` beside it or the same path under `<lang>/`) and about translations without `source_rev` or whose source changed since it; with `--strict` they fail. A translation beside its source whose `permalink` is not the source's URL under `/<lang>` is an error |
| `--i18n-init=LANG,...` | copy the theme's catalogs (`i18n/<lang>.yml`, 23 languages) into `SRC/_data/i18n/` as a starting point for overrides (optional; the theme already uses them), and list keys an existing catalog lacks |
| `--diagrams` | instead of checking, print the static diagrams whose SVG is missing or stale as JSON (`page`, `name`, `line`, `fence`, `digest`, `files`, `reason`) and exit 1 when there is any; SITE may be omitted. A pre-commit hook or a render script reads it |
| `--math` | with `modootoday.math.mode: static`, instead of checking, print the `_data/math` files whose page has math blocks without an entry or with a stale one as JSON (`key`, `file`, `page`, `blocks` with `line`, `tex` and `digest`, `reason`) and exit 1 when there is any; SITE may be omitted. `script/figures/math.mjs` reads it |
| `--gh` | also render each page with `gh api markdown` (network, `gh` login) |
| `--help, -h` | print usage and options (`--help=markdown` prints the README table) |
| `--version` | print the rules version |

### modootoday-stubs

`modootoday-stubs SRC [options]`

| Option | Does |
|---|---|
| `SRC` | the site source; without `--write` or `--check` nothing is written and the planned creates, updates and deletes are listed |
| `--twins` | a stub `<name>.md.txt` per page (`layout: twin`) for its twin at `/<name>/index.md` |
| `--aliases` | the aliases `modootoday.aliases` turns on: `md` a stub `<name>.flat.md.txt` (`layout: twin`) at `/<name>.md`, `html` a stub `<name>.html.md.txt` (`layout: redirect`) at `/<name>.html` |
| `--records[=SET,...]` | a page `<dir>/<key>.md` per record of each set in `modootoday.records` (or only the named sets): front matter only, with the title, description, permalink and `record:` the layout reads |
| `--pwa` | the files `modootoday.pwa` needs (with `enabled: true` or `kill`): `manifest.webmanifest`, the service worker `sw.js` and the offline pages `offline.md` and `offline.<lang>.md` for each `full_languages` entry; never pruned, and a site file already at one of those paths is never overwritten |
| `--write` | write the planned stubs; files whose content is already right are not touched |
| `--check` | write nothing; exit 1 when a stub is missing, out of date or orphaned |
| `--no-prune` | keep orphan stubs (by default a twin stub whose page is gone, an alias stub no page wants, or a record page whose record is gone, is deleted) |
| `--json` | print the plan as JSON (`mode`, `kinds`, `changes` with `path`, `action`, `reason`) |
| `--quiet` | print only drift found by `--check` and errors |
| `--help, -h` | print usage and options (`--help=markdown` prints the README table) |
| `--version` | print the version |
<!-- spec:docs-index:end -->

## 종료 코드

| 코드 | `modootoday-check` | `modootoday-stubs` |
|---|---|---|
| 0 | 문제 없음 | 할 일 없음, 미리보기 또는 쓰기 완료 |
| 1 | 문제 발견(stderr에 출력) 또는 잘못된 사용법 | `--check`가 차이를 찾음 |
| 2 | — | 잘못된 사용법 또는 `_config.yml` 오류 |
| 3 | — | 데이터 오류: front matter, 안전하지 않은 permalink, 별칭 충돌, 키가 없거나 겹치는 레코드 |

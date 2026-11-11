# Contributing

English is the canonical language. `README.md`, `RULES.md` and the English pages in `docs/` are the source of truth; `README.ko.md`, `README.ja.md` and the pages beside each English page in `docs/` (`install.ko.md`, `install.ja.md`, and the home pages in `docs/home/`) are translations and start with a note saying so. Change the English text first, then update the translations in the same pull request when you can. When they differ, English wins.

Translations are localized, not literal: follow the tone, glossary and spacing rules in [TRANSLATING.md](TRANSLATING.md).

Coding agents start from [AGENTS.md](AGENTS.md), the short form of this file (`CLAUDE.md` imports it). Keep the two in step: a command or rule that changes here changes there in the same commit.


1. Fork and branch from `main`, and clone with `git clone --recurse-submodules` (the published starters in `example/` are git submodules; in an existing clone run `git submodule update --init`, and `git config submodule.recurse true` keeps them in step on pull and checkout). Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:` …).
2. Keep layouts and includes **Liquid only** — no custom Ruby plugins — so the theme keeps working with `remote_theme` on GitHub Pages.
3. `README.md`, `README.ko.md` and `README.ja.md` keep the same sections (checked by `test/project/readme_test.rb`). The Commands tables are generated from `exe/modootoday-check` and `exe/modootoday-stubs`: run `script/readme-commands` after changing an option.
4. Rule changes (`RULES.md`) need a matching change in the includes, the checker and the tests, plus a CHANGELOG line, written in the commit. The docs Markdown rules pages (`docs/reference/rules*.md`) carry its text: run `ruby script/docs-index` after editing it; `--check` fails while they differ.
5. Run the checks for both stacks before opening a PR:

```sh
BUNDLE_GEMFILE=gemfiles/github-pages.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/github-pages.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle exec rake
npm ci && npm test
gem build jekyll-theme-modootoday.gemspec
```

A shared pre-push hook runs the checks that need no build in a few seconds: the docs structure, the component order, the docs consistency rules, the docs-to-registry doctests, the CHANGELOG lint, the spec id resolution, `script/i18n-build --check`, `script/docs-index --check`, `script/readme-commands --check` and `script/commit-check` on the pushed commits. It is opt-in; turn it on once per clone with `git config core.hooksPath script/hooks`, or run `script/hooks/pre-push` by hand. Push CI runs the same checks, so `git push --no-verify` only moves a failure later.

Generators fix, checks verify (adr:modootoday/20261109225836): `bundle exec rake fix` runs `script/docs-index`, `script/readme-commands`, `script/i18n-build`, `script/version-include` and `script/changelog` in write mode and lists the files that changed, for you to review and commit; when a hook check fails on stale output, that is the fix. Stamping a translation (`ruby script/docs-index --stamp`) stays a deliberate step, because a stamp says someone compared the meaning. CI runs the `--check` forms.

### Commits and the changelog

The CHANGELOG's sections are generated from commit messages by [git-cliff](https://git-cliff.org/) (`cliff.toml`, the exact `git-cliff` version in `package.json`; adr:modootoday/20261109225758, adr:modootoday/20261109230955), so the commit is where a change note is written. A subject is a Conventional Commit, `type(scope): text`, and the text reads as a changelog line. `feat` goes to Added, `fix` to Fixed (`fix(security)` to Security), `perf` and `docs` (the docs site) to Changed, and `type!` to Changed with a "Breaking" mark; `chore`, `ci`, `test`, `build`, `style`, `refactor` and internal docs (`docs(spec)`, `docs(changelog)`, `docs(contributing)`, `docs(agents)`, `docs(releasing)`) are left out. Footers, in the last paragraph of the message, say what the subject cannot:

| Footer | Effect |
| --- | --- |
| `Changelog: <text>` | the line to show instead of the subject; on a type that is left out, it puts the commit in Changed |
| `Changelog: none` | leaves the commit out |
| `Refs: adr:modootoday/<id>` | the ids after the line, in parentheses (several are separated by commas) |
| `Visual: <text>` | joins the entry's `Visual:` line (the intended differences of the visual run) |
| `Migration: <text>` | follows the line as "Upgrade: …"; the Upgrade guide takes it from there |
| `Deprecated: <text>`, `Removed: <text>` | the line, in Deprecated or Removed |
| `BREAKING CHANGE: <text>` | the commit goes to Changed with the "Breaking" mark |

`script/commit-check [RANGE]` checks the rules the generator relies on: a commit that changes what the gem ships (`_layouts`, `_includes`, `_sass`, `assets`, `lib`, `exe`, `i18n`) has a Conventional subject, and one whose type is left out carries `Changelog: <text>` or `Changelog: none`; a footer is not empty and `Refs:` names spec ids. The pre-push hook runs it on the pushed commits and push CI on the pushed range or the pull request; fix a message with `git commit --amend` or a rebase before pushing.

`## [Unreleased]` is generated too: never edit it by hand. After a commit, `ruby script/changelog` (or `bundle exec rake fix`) rewrites it from the commits since the last tag; amend the commit with it, which renders the same text because only messages count. `test/project/changelog_test.rb` and the CI `js` job (`ruby script/changelog --check`) fail while it is stale. Released entries are never regenerated.

Changes to `docs/` or the theme's look: `test/system/site/build-docs.sh docs/_site && test/system/site/build-pwa.sh && npm run qa` takes screenshots (4 widths, light and dark, every language) and runs axe, token contrast, size budgets, the CSP audit and the PWA flows (PWA checks below); CI runs the same job and uploads `qa-out/`. Every theme CSS and JS file has a gzip cap on its row in `_includes/modootoday/assets/registry.html` (the measured size plus 10 %, rounded up to 128 bytes): a file over its cap, a row without a cap and a theme file without a row fail, and a file within 5 % of its cap warns; each message prints the cap to use, so the arithmetic is never done by hand. Per page type (`PAGE_TYPES` in `test/system/audit/config.mjs`) the limit is the sum of the caps of what one page loads; the `GUIDE` targets (8 KiB CSS, 6 KiB JavaScript, six theme sheets) only warn. The CSP audit serves `CSP_PAGES` with a strict `Content-Security-Policy` header and fails on any violation or console error; a new feature adds its demo page there. A demo that moved into a starter is checked in that starter's demo build instead (`STARTERS` in the same file).

### Visual regression

`npm run qa:visual` screenshots five pages (home, kitchen sink, configuration, Korean home, the hero module demo) at 360, 600, 720, 1024 and 1440 px in light and dark mode, with reduced motion (so a script visual shows its poster) and compares each shot with a PNG in `test/system/visual/baseline/` (git-ignored; baselines are never committed) using [pixelmatch](https://github.com/mapbox/pixelmatch). A shot fails when more than 0.1 % of its pixels differ by more than the colour threshold 0.1, or when its size changed; the failing shot and a diff image go to `qa-out/visual/`. Animations, the caret and the "Last updated" date are frozen.

```sh
test/system/site/build-docs.sh docs/_site
npm run qa:visual            # compare
npm run qa:visual:update     # accept the current look as the new baseline
node test/system/visual/visual.mjs docs/_site --baseline DIR --out DIR --threshold 0.1 --max-diff 0.001 --report
```

Fonts and anti-aliasing differ between operating systems, so a baseline is only comparable on the machine image that made it. Make and compare baselines on one machine; to compare two versions, run `--update` on the old build and compare the new build in the same place. The CI workflow `visual.yml` does exactly that: it builds `docs/` at the base commit and at the head commit on the same runner and compares them, listing differences in the job summary with the images in the `visual` artifact.

- **Pull requests:** blocking. If the change is intended, review the diff images and add the `visual-ok` label; the check re-runs and passes in report mode.
- **Release check:** a manual run (`gh workflow run visual.yml`) compares `main` with the latest release tag and reports the differences. Pushes to `main` do not run it.

### Lighthouse budget

`test/system/lighthouse/lighthouse.sh` runs Lighthouse on eight docs pages (among them the hero module demo, whose largest contentful paint is its poster), mobile and desktop, and `test/system/lighthouse/budget.mjs` checks the median of the runs against `test/system/lighthouse/budget.json`: accessibility, best practices and SEO must be 100, performance at least 90 (desktop) and 80 (mobile). The `lighthouse.yml` workflow runs it three times per page and blocks on a miss; it runs on pull requests and in the release check (`gh workflow run lighthouse.yml`), not on pushes to `main`.

```sh
test/system/site/build-docs.sh docs/_site
RUNS=3 CHROME_PATH=$(command -v google-chrome) test/system/lighthouse/lighthouse.sh   # needs network for npx lighthouse
node test/system/lighthouse/budget.mjs qa-out/lighthouse
```

### PWA checks

The service worker's flows (`modootoday.pwa`) run on a fixture site. The docs site has the PWA on as well (its stubs are under `docs/generated/`, written by `script/docs-index`), and `features/pwa/docs.mjs` checks it on the strict CSP demo: the manifest and installability as Chromium reports them, the worker's scope and cache names, the install section's hidden button, and the precache total, a warning over 150 KiB. `test/fixtures/sites/pwa/` holds three pages (English and Korean) and the stubs `modootoday-stubs --pwa --write` writes; `test/stubs/pwa_test.rb` runs `--check` on them. `test/system/site/build-pwa.sh [OUT]` builds it six times into `pkg/pwa/`: `v1`, `v2` (another `time:`, so `sw.js` changes), `next` (another theme version, so the theme files change too) and `kill` (`enabled: kill`) at `/a`, then `v1` at `/b` and at the origin root, the way project sites share `<user>.github.io` with the user site. `test/system/site/server.mjs` serves them on one origin under the strict CSP header; it can swap the build behind a base path (a deploy) and cut every socket (a lost network). `npm run qa` runs the four flows in `test/system/audit/features/pwa/`:

| Flow | What it checks |
| --- | --- |
| `offline.mjs` | the worker registers with the site's scope; with the sockets cut, a visited page comes from the cache, an unvisited one gets the offline page with the kept pages listed, a Korean path gets the Korean offline page, and no page breaks the CSP |
| `update.mjs` | a deploy from `v1` to `v2` (pages only) lets the new worker take over the open page with no notice and no reload, keeping the caches and the visited page; from `v2` to `next` (new theme files) the worker waits and the update notice shows as a status without taking focus, passes axe, closes with `Esc`, and its Reload hands over to the new worker and loads the new `?v=` files |
| `kill.mjs` | the `enabled: kill` deploy deletes the `mt:/a/:` caches, unregisters and reloads the open page; the next visit has no worker |
| `scope.mjs` | activating `/a` and the root, and the kill at `/a`, leave the other scopes' registrations and caches |

Cutting the sockets fails the worker's own fetches, which a browser's offline switch may not reach. The flows never read `navigator.onLine` (it can stay `true` while the worker is cut off), and each step waits for its completion state (a controlled page, a cache entry, a filled list) instead of a fixed time: a slower browser must not turn a race into a pass. CI's docs QA job builds the fixtures, runs the four flows in Chromium with `npm run qa`, then runs `offline.mjs` in WebKit as a smoke test. Safari on iOS, installing the site and storage eviction are not automated.

```sh
test/system/site/build-pwa.sh
node test/system/audit/features/pwa.mjs pkg/pwa
node test/system/audit/features/pwa.mjs pkg/pwa --browser=webkit --only=offline --smoke
```

With no browser on your machine, run the flows in a remote Chrome: start any HTTPS tunnel to a free local port, then pass the DevTools URL (`CDP_AUTHORIZATION` for its header, as for the figures), the tunnel's address and the port. The flows then reuse the browser's default context, the only one that reports installability, and start by removing every worker and `mt:` cache of the origin, because that context outlives one run. Behind a tunnel a cut origin answers 502 instead of failing, so the remote run cuts the network with the context's offline mode (Chromium applies it to the worker too).

```sh
node test/system/audit/features/pwa.mjs pkg/pwa --cdp=wss://browser.example/devtools/browser --origin=https://tunnel.example --port=8411
```

### Starter sites

`example/` holds three starter sites: `docs` (a guide, records with a byte-exact API folder, Korean and Japanese pages in `ko/` and `ja/`), `blog` (posts, a news article, an author page and the feed) and `landing` (a home hero, pricing and a legal page). All three are published: each folder is a git submodule (a gitlink) of its own template repository, which holds the rendered `github-pages` tree and deploys the live demo (adr:modootoday/20261104171142); `.gitmodules` follows the manifest (`test/starters/published_test.rb`). `example/starters.yml` lists them with the repository each one is published to and its one-line `description`, its languages, its stacks, its `modootoday-check` flags, its demo's `showcase: {style}` and the `qa:` pages of its demo build; `demo.docs_url` is the documentation address every demo links to. The repository's Pages site is the starter's live demo (`https://<owner>.github.io/<repo>/`), and its template link (`https://github.com/<repo>/generate`) is the demo's "Use this starter"; both are derived from `repo:` and written nowhere else. `rake starters:repos` prints each repository's description, website and topics as JSON. A starter that is not published yet is a plain folder holding only what a person writes. `bundle exec rake starters:render` writes each starter for each of its stacks to `pkg/starters/<stack>/<name>/` and adds what the theme owns (a published starter's `github-pages` tree is its work tree, copied as committed):

- `_config.yml`: on the `github-pages` stack, the `theme:` line becomes `remote_theme:` pinned to the gemspec version.
- `Gemfile` from the gem lines of `gemfiles/<stack>.gemfile`; `README.md` and `.github/workflows/pages.yml` from `script/starters/templates/`, shared by every starter.
- `.github/workflows/theme-update.yml`, on the `github-pages` stack only: the starter's pull-based update to each theme release (adr:modootoday/20261109225836). Daily, or by hand with `workflow_dispatch`, it compares the theme's latest release (public API, no token) with the `remote_theme` pin; when it is newer, it re-renders the starter with that release, commits `chore: theme vX.Y.Z` with the repository's own `GITHUB_TOKEN` and calls `pages.yml` (a reusable workflow too) to deploy, since that push starts no other workflow. Guarded by `if: github.repository == '<repo>'`, so a site made from the template skips it. In the theme, the `starter-gitlinks.yml` workflow moves the `example/` gitlinks to the starters' `main` daily (or `gh workflow run starter-gitlinks.yml`) and runs the starter checks in the same job; `rake starters:publish[NAME]` is the local fallback with your own git credentials (RELEASING.md, step 9).
- `_config.demo.yml`: the showcase settings of the live demo, and nothing else. The Pages workflow merges it into `_config.yml` before the build and restores `_config.yml` after it, in two steps guarded by `if: github.repository == '<repo>'`, so a fork or a repository created from the template builds without the showcase and without `noindex`. The GitHub Pages builder takes no list of config files, hence the merge; `test/starters/demo_overlay_test.rb` pins the guard and runs both steps.
- The twin, record and alias stubs `modootoday-stubs` writes. No interface catalog is copied: the theme ships every language a starter may list, and a starter's `_data/i18n/<lang>.yml` holds only the strings that site changes (a test fails on one that repeats the theme's).

Do not commit those files in a plain starter folder; the tests fail on a committed stub. A published starter holds them, and `rake starters:render[NAME]` rewrites them in its work tree, pinned to the gemspec version. `rake starters:check` fails when `pkg/starters/` differs from a fresh render, when a published starter differs from a render of its own content at the release its `remote_theme` pins, or when that pin is not a released version (a dated CHANGELOG heading); it warns when the pin is behind the gemspec version, and `rake starters:build[NAME]` builds the starters with the current bundle and runs the checker with their manifest flags (plain `rake` runs it after the tests). `rake starters:demo[NAME,OUT]` builds a starter as its demo deploys it (`_config.demo.yml` layered, at the repository's base path) into `OUT/<name>/` (default `pkg/demo/`), checks it and its `qa:` pages, and `node test/system/starters.mjs OUT` runs the starter audit on those builds: the showcase on the first two `qa:` pages, then shots, overflow and axe on every `qa:` page, the page types, header and anchor offsets and the CSP check that `STARTERS` in `test/system/audit/config.mjs` names for that starter. The `starters.yml` workflow renders, builds and checks every starter on github-pages 232, Jekyll 4 and the GitHub Pages builder image, then builds each demo and runs the starter audit on it; `visual.yml` and `lighthouse.yml` also run on the demo builds (`visual.mjs --demo`, `lighthouse.sh` with `BASE` and `PAGES`, SEO not scored because a demo is `noindex`). Sites that only tests use, such as the front-matter-less one, live in `test/fixtures/sites/`.

To change a published starter:

1. `cd example/<name>` and `git switch next` (or stay on `main` for a change that builds with the pinned release).
2. Edit, then run `bundle exec rake starters:render[<name>] starters:check starters:build[<name>]` from the theme root.
3. Commit and push in the starter's repository.
4. In the theme repository, stage `example/<name>` and commit `chore(starters): bump <name>`, or let the Starter gitlinks workflow move it (`gh workflow run starter-gitlinks.yml`).

When a starter is published, its demo pages move out of `docs/` as the docs demo to starter map (`.spec/sot/docs-demo-to-starter-map.sot.md`) lists them: the wave's status becomes `done`, and `ruby script/docs-index` writes the redirect stubs and `docs/_data/starters.yml`, which `docs/_includes/live-demo.html` reads for the static preview and "Live demo" link of each such demo page (its keys are in the layout group index) (`layout: layout-reference` places them after the lead, so the page body stays plain Markdown and matches its twin). Other pages link a moved demo with a plain Markdown link titled `new-window`. `test/project/docs_moves_test.rb` fails on a page list that names a moved URL, a starter page the starter lacks and a layout without a starter.

A page that moves inside `docs/` keeps its old URL: list the old source path in the English page's front matter (`moved_from: [recipes/charts.md]`) and `ruby script/docs-index` writes a redirect stub there, in English and in each language the page has (adr:modootoday/20261109192542). A sidebar group past 12 entries gets another group, never an exception.

### Rendering figures

The static diagrams in `docs/` are committed SVG pairs under `docs/assets/diagrams/`, each tied to its Mermaid fence by `data-mt-src` (see [Math and diagrams](docs/recipes/figures/math-diagrams.md)). After you change a fence, `ruby exe/modootoday-check docs --diagrams` lists what to render, and the full check fails on a stale SVG. `script/figures/diagrams.mjs` renders that list: it loads Mermaid from the pinned URL and hash in the script, renders each fence with the `default` and `dark` themes, sizes the SVG from its `viewBox` and writes `data-mt-src`; `script/figures/digest.mjs` is the digest rule in Node, kept equal to `lib/modootoday/figures.rb` by a shared fixture. Neither is in the gem. Pick one of three ways to run it; all three give the same files:

- **GitHub Actions.** The `figures.yml` workflow runs on pushes and pull requests that touch `docs/`: it fails on a missing or stale SVG and uploads the rendered files as the `diagrams` artifact, which you copy into `docs/assets/diagrams/`. Run it by hand (`gh workflow run figures.yml -f commit=true`) to have it commit them to the branch. You need no browser on your machine.
- **A remote browser.** Point the script at any Chrome that speaks the DevTools protocol (one started elsewhere with `--remote-debugging-port`, or a hosted browser service) with `--cdp=<websocket URL>`; set `CDP_AUTHORIZATION` to the `Authorization` header value if the service needs one. Nothing starts a browser locally.
- **A local browser.** Without `--cdp` the script launches Playwright's Chromium (`npx playwright install chromium` once).

```sh
npm ci
ruby exe/modootoday-check docs --diagrams | node script/figures/diagrams.mjs docs
ruby exe/modootoday-check docs --diagrams | node script/figures/diagrams.mjs docs --cdp=wss://browser.example/devtools/browser
```

To move to another Mermaid version, change the URL and the `sha384` hash of that version's `dist/mermaid.min.js` together, then render every diagram again: an SVG only goes stale when its fence changes.

The docs site uses static math (`modootoday.math.mode: static`): the MathML of each English page's math blocks is in `docs/_data/math/<key>.yml`, which its translations share. After you change a block, `ruby exe/modootoday-check docs --math` lists the files to write, and the full check fails on a stale entry. `script/figures/math.mjs` writes them with KaTeX in Node, from the exact `katex` version in `package.json`; it needs no browser:

```sh
ruby exe/modootoday-check docs --math | node script/figures/math.mjs docs
```

## Decisions

A decision lives in an ADR under `.spec/adr/`, not in a commit message, an issue comment or a chat. Write one when a change:

- sets or moves a rule, a limit or an exception: `RULES.md`, the docs and layout limits, the Lighthouse budget, the `GUIDE` targets, an allowlist entry whose reason is a choice;
- changes public behaviour or the [public API](https://modootoday.github.io/jekyll-theme-modootoday/reference/api/), or deprecates or removes something;
- changes how the project is built, tested or released (what CI runs and when, the release gate);
- picks one of several reasonable designs that a later contributor could undo without knowing why.

No ADR is needed for a registry cap moved by its rule (measured size plus 10 %), a fix that restores documented behaviour, or a wording change.

Use the spec CLI (the `@modootoday/specfold` npm package, command `spec`) so ids and file names stay consistent; never name a `.spec/` file by hand:

```sh
spec new adr --governs <path> --title "<the decision, as a sentence>" --write
spec set <id> status=active --write
spec check
```

Cite the decision by id (`adr:modootoday/<timestamp>`) in the CHANGELOG entry, and next to a constant it sets. Every cited `adr:`, `audit:` or `research:` id must name a committed document under `.spec/` (`test/project/spec_ids_test.rb`); drafts in the git-ignored local spec directory cannot be cited. Everything in `.spec/` is public: no private paths, names or notes.

## Definition of done

A change is done when the files its kind touches are updated in the same commit and its checks pass. Every change also passes `bundle exec rake test` on both stacks and the pre-push hook.

| Change | Files to touch | Checks |
| --- | --- | --- |
| Theme output (layout, include, Sass, script) | the theme files; the docs page that describes it in English, Korean and Japanese; a commit subject (or `Changelog:` footer) that reads as its CHANGELOG line | `npm test`; `npm run qa` on a docs build; the visual run of the release check |
| Theme CSS or JS file added or resized | its row and gzip cap in `_includes/modootoday/assets/registry.html`; component CSS in a module sheet, not core; a new demo page in `CSP_PAGES` | `npm run qa` (budgets, page types, CSP) |
| Component | `docs/_data/components.yml`, the settings and Sass import, the checker; its group in `docs/_data/component_groups.yml`; the kitchen sinks and the Components page in all three languages, in the group order with ids A-Z inside a group (adr:modootoday/20261109141344) | `rake test` (component names, kitchen-sink coverage, component order); `npm run qa` |
| Setting (`modootoday.*` key) | its key file under `lib/modootoday/check/config/keys/`; its row in the Configuration guide's key table in all three languages; its CHANGELOG line, from the commit | `rake test` (checker, message snapshot: `SNAPSHOT_UPDATE=1` on purpose; `test/system/docs/registries.rb` compares the table with the schema) |
| Checker or stub writer option | `lib/modootoday/check/cli.rb` or `lib/modootoday/stubs/cli.rb`; `ruby script/readme-commands` (README tables and the docs Command line pages) | `ruby script/readme-commands --check` |
| Interface string | `i18n/en.yml`, then every other catalog; `ruby script/i18n-build` | `ruby script/i18n-build --check` |
| Docs page | the English page, then its `.ko.md` and `.ja.md` pages; `ruby script/docs-index`, then `ruby script/docs-index --stamp` on the translations; `ruby script/docs-key-order` for the front matter key order; the rules of adr:modootoday/20261109200230 (link the topic's canonical page instead of repeating it, use the glossary terms of `i18n/glossary.yml`, add a topic to `docs/_data/topics.yml` when it gets a canonical page, and use at most three GitHub alerts on a page, each of the type whose glossary line fits) | `ruby script/docs-index --check`; the docs structure check; `test/system/docs/rules.rb` (blocking rules fail, the others are reported); a docs build with `modootoday-check --twins` |
| Rule, limit, budget target or exception | an ADR (see Decisions); `RULES.md` with the includes, checker and tests it governs; `ruby script/docs-index` (the docs Markdown rules pages); its CHANGELOG line, from the commit | `rake test`; `spec check`; `ruby script/docs-index --check` |
| Tooling, tests or CI | `CONTRIBUTING.md` and `AGENTS.md` when a command changes; a `Changelog:` footer only when users see it | `rake test` (`test/project/governance_test.rb` checks the commands in `AGENTS.md`) |
| Release | the steps in [RELEASING.md](RELEASING.md) | the release check in RELEASING.md step 3 |

## Project layout

These rules apply to everything in the repository: theme files, tools, tests, QA and new code. `test/project/layout_test.rb` enforces the measurable parts.

1. **Standards first.** Where Jekyll, RubyGems, Bundler, Rake, minitest or npm fix a place or a name, use it (`_layouts/`, `_includes/`, `_sass/`, `assets/`, `lib/`, `exe/`, `test/**/*_test.rb`, `package.json` scripts).
2. **One responsibility per file.** A file does one job. When it grows a second one, split it; do not append unrelated code.
3. **Assembling file next to its parts.** A file that only wires parts together sits beside a directory of the same name holding the parts: `lib/modootoday/check.rb` with `lib/modootoday/check/`, `test/system/audit.mjs` with `test/system/audit/`.
4. **Group by context, not flat.** A directory holds at most 12 tracked files; beyond that, group them in subdirectories named after what they are about (`test/checker/`, `test/theme/`, `test/system/lighthouse/`). Directories whose shape a standard fixes (Jekyll pages, the repository root), or that are pending a regroup, are listed with a reason in `FLAT_OK`.
5. **Short code files.** Code under `lib/`, `exe/`, `script/`, `assets/js/` and `test/` (system audits and helpers) stays at 150 lines or fewer; a test file at 300 or fewer. Data files there (`.json`, `.txt`) are not code and have no limit. Exceptions are listed with a reason in `LONG_OK`, and the test fails when an exception no longer applies.

Where things live:

| Path | Context |
| --- | --- |
| `lib/modootoday/check.rb`, `lib/modootoday/check/` | `modootoday-check`: `cli.rb` and `context.rb` at the top; rule groups in `config/` (`_config.yml` settings; one file per key group under `config/keys/`, in `appearance/`, `pages/` and `serving/`, report order = load order in `config/keys.rb`), `page/` (page sources), `build/` (the built site), `registry/` (`_data/components.yml`, i18n catalogs), `source/` (Sass, `Gemfile.lock`, `gh` rendering) and `layouts/` (layout front matter) |
| `lib/modootoday/markdown.rb` | Markdown source text (front matter, fences, code spans, comments): the one front matter parser for both executables, `script/` and `test/system/docs/` |
| `lib/modootoday/figures.rb` | static figures: the fences a page replaces and the one digest rule (`data-mt-src`) that ties a committed render to its fence; any tool that writes the attribute follows it |
| `script/figures/` | rendering the docs site's static figures (`diagrams.mjs`, `math.mjs`) and the digest rule in Node (`digest.mjs`); not in the gem, see Rendering figures above |
| `lib/modootoday/stubs.rb`, `lib/modootoday/stubs/` | `modootoday-stubs`: `page.rb` (a page and its URL, also used by `modootoday-check --aliases` and `script/docs`), `source.rb` (the pages), one generator per stub kind (`twins.rb`, `aliases.rb`, `records.rb`), `plan.rb`, `writer.rb`, `report.rb` and `cli.rb`; `script/docs-index` uses `Twins` (with `dir: "generated"`) for the docs site, and `modootoday-check` uses the records plan for its verdict |
| `test/stubs/` | `modootoday-stubs` plans, idempotence and the command line |
| `test/checker/` | `modootoday-check` rules, in the same context subdirectories; `messages_snapshot_test.rb` pins the full output (`SNAPSHOT_UPDATE=1` refreshes `test/fixtures/checker/`) |
| `test/theme/` | layouts, includes, Sass and tokens built with Jekyll |
| `test/layouts/` | layout families (`families/`) and page features (`features/`), built from a starter site plus extra pages |
| `test/support/` | helpers several test directories share (`starters.rb` renders each starter once per run; `layout_site.rb` builds one with extra pages) |
| `test/consumer/` | sites that use the gem: the starters with stubs or with the plugin, the docs starter's guides, the front-matter-less site |
| `test/starters/` | the starter manifest, the sources, rendering, drift, the published starters (gitlinks, pins) and the generated workflow |
| `example/` | the starters (`starters.yml` and one git submodule, or a plain folder before it is published, per starter); see Starter sites above |
| `script/starters/` | the starter renderer: `manifest.rb`, `theme.rb` (what it reads from the gemspec, `gemfiles/`, `i18n/` and the executables), `site.rb`, `published.rb` (a gitlinked starter's content and pin), `render.rb` and `templates/` |
| `test/project/` | README, version, community files, this layout, the docs generator (`script/docs-index`), and the docs structure and kitchen-sink checks of `test/system/docs/` that need no build |
| `test/js/` | browser scripts (`node --test`) |
| `test/fixtures/` | inputs shared by the tests |
| `docs/generated/` | tool output: the docs site's twin stubs and per-language `llms.txt` / `llms-full.txt` stubs, written by `ruby script/docs-index` (`--check` fails when they are stale). Do not edit by hand; each stub sets `path:` to where it would sit beside its page and `permalink:` to its URL |
| `test/system/site/` | building and serving the docs site and the PWA fixture builds (`build-pwa.sh`; `server.mjs` serves several sites on one origin), and waiting after a viewport change until the page's scripts have seen it (`viewport.mjs`) |
| `test/system/audit.mjs`, `test/system/audit/` | screenshots, axe, contrast, size budgets (`budgets/`: registry rows, per-file caps, page types in gzip), keyboard flows (`keyboard/`), registry parts, strict CSP, the PWA flows (`features/pwa/`, see PWA checks above) (`npm run qa`) |
| `test/system/visual/` | visual regression (`npm run qa:visual`) |
| `test/system/lighthouse/` | Lighthouse runs and budget |
| `test/system/docs/` | docs structure, link check, kitchen-sink coverage, component order, component examples, the docs consistency rules (`rules.rb`, one file per rule in `rules/`) and the docs-to-registry doctests (`registries.rb`); each script runs on its own |
| `test/system/css/` | per-partial CSS sizes |
| `test/system/bench/` | the records benchmark: a synthetic site of N records (`fixture.rb`) built with the GitHub Pages builder image (`records.rb`, Docker); CI fails over 300 s for 1,000 records |

## Conduct, security and releases

- This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
- Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md), not in public issues.
- Releases follow [RELEASING.md](RELEASING.md).
- Dependabot pull requests are squash-merged by a workflow once every run on their head commit has succeeded; no repository setting is needed (RELEASING.md, "Dependency updates").

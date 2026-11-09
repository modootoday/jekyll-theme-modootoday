---
id: research:modootoday/20261109150011
title: "Agent governance, docs drift and CHANGELOG automation for 1.7.0 and 1.8.0"
status: active
created: 2026-11-09T15:00:11Z
updated: 2026-11-09T15:00:11Z
rel:
  governs: [CHANGELOG.md]
---

# Agent governance, docs drift and CHANGELOG automation for 1.7.0 and 1.8.0

Status: research, 2026-11-09. Read-only survey of the theme's `main` (after 1.6.0, scope ADRs for 1.7 and 1.8 recorded) plus public sources. Public-safe: no local paths, account ids or internal names.

Three problems:

- **A. Agent governance.** How AI coding agents and human contributors are told what to do, held to it and checked when they change the theme.
- **B. Docs drift.** Docs fall behind the code: en/ko/ja pages, README, CONTRIBUTING, RELEASING, recipes, component examples and the 20 home-page languages.
- **C. CHANGELOG.** Format, sections, release notes, links, the `Visual:` note, ADR ids, migration notes and public API changes, all kept consistent and largely generated.

The repository is unusual in two ways that shape every recommendation:

1. **No PR step.** The maintainer and agents push straight to `main` (adr:modootoday/20261102203210). A push runs only the fast CI jobs. Tools built around pull requests (release-please, release-drafter, the changesets bot, `towncrier check` against a branch, required status checks) either do not apply or need adapting. With nothing between a commit and `main`, a local pre-push hook is the only check that runs *before* a change lands. Push CI is the backstop after landing, and the release is the hard gate.
2. **Its own tools, few dependencies.** The repository already writes its own small checkers instead of adding dependencies: `links.rb` stands in for html-proofer, `script/readme-commands` generates tables between markers, and `source_rev` handles translation staleness. A file may hold at most 150 lines of code. New checks should follow that style.

---

## 1. What already exists and is enforced

| Area | Mechanism | Where it runs | Notes |
| --- | --- | --- | --- |
| Version consistency | `test/project/version_test.rb`: gemspec version = `## [X.Y.Z]` heading and link; `version.html` include current; install pins in README (en/ko), install and home pages (en/ko/ja) match the version and minor; no 0.x wording; a "2.0" regex self-test | `rake test` (push CI, every push) | Pins are edited by hand at release; the test only fails afterwards |
| Release notes | `script/release-notes vX.Y.Z` prints the CHANGELOG entry; `release_notes_test.rb` checks every released tag has a non-empty entry with `###` sections and no link refs | `rake test`; `release.yml` uses it to create the GitHub Release | No lint on the entry's content |
| Release path | Tag-only publish through a protected environment and trusted publishing; tag = gem version check | `release.yml` on `v*` | Does not check that the three manual release checks passed on the tagged commit |
| Docs IA | `script/docs-index` generates nav, section indexes, twins, `llms.txt`/`llms-full.txt`; `--check` fails on stale output (`docs_index_test.rb`) | `rake test` (push) | Good: generated, drift fails on every push |
| Docs structure | `test/system/docs/structure.rb`: sections, depth, front matter, sidebar cap (12, recipes 14 by ADR), 12 files per directory, banned wording (`since:`, `deprecat`, bare `2.0`, `frozen`, private-dir names), ko/ja page must have an English page | **docs-qa job, skipped on push** (`if: github.event_name != 'push'`) | Needs no built site, but only runs on PRs and manual dispatch |
| Links and anchors | `test/system/docs/links.rb` on the built site (internal only) | docs-qa job (not on push) | External links are never checked |
| Component coverage | `coverage.rb` (every registered component in the kitchen sinks and the Components index), `examples.rb` (leaked Markdown/Liquid, empty or hidden sources, YAML = `sections:` entry) | docs-qa job (not on push) | |
| Browser audits | `npm run qa` (screenshots, axe, contrast, size caps per registry row, page types, strict CSP), Lighthouse budget, visual diff against the latest tag | PRs and manual dispatch | ~35 min; the release procedure starts them by hand |
| Figures freshness | `figures.yml`: stale or missing diagram SVGs (digest `data-mt-src`), path-filtered | **push** and PR | A precedent for a path-filtered push check |
| i18n catalogs | `script/i18n-build --check`: stale catalogs, key/placeholder drift, glossary, register, calques, untranslated English (`i18n_lint_test.rb`) | push CI | 23 interface catalogs |
| Translation staleness | `source_rev: sha256:…` per translated page (`--stamp`), `modootoday-check --i18n-pages` warns on missing or stale stamps | **not run in CI** (docs CI runs `--twins` only) | |
| README | `readme_test.rb`: en/ko same sections and fenced blocks; Commands tables generated from `--help=markdown` (`script/readme-commands --check`) | push | Good model for generated reference sections |
| Component names | `component_names_test.rb` pins config, Sass imports, checker, registry and `docs/_data/components.yml` to each other | push | |
| Project layout | `layout_test.rb`: ≤12 files per directory, ≤150 lines per code file, allowlists with reasons that must stay current | push | Structural enforcement of the written conventions |
| Community files | `governance_test.rb`: SECURITY, CoC, CONTRIBUTING, RELEASING, PR and issue templates exist; private reporting link; no e-mails; Dependabot ecosystems | push | No AGENTS.md or agent instructions at all |
| Decisions | `.spec/` (ADRs, audits, research, SoT), `spec.toml` with a public-surface guard (secrets, private paths) | the spec CLI, run locally only | Nothing in CI; CONTRIBUTING does not mention `.spec/` or ADRs (TRANSLATING does) |
| PR template | Checklist: tests on both stacks, CHANGELOG Unreleased, English first then stamps, public API in CHANGELOG | PRs only | The maintainer and agents do not open PRs, so they never see it |

## 2. Gaps, with evidence

**G1. Cheap docs checks run only at release.** `structure.rb` needs no build (seconds), yet it sits in the docs-qa job, which skips pushes. adr:modootoday/20261030083000 says it "runs in CI and fails". adr:modootoday/20261109124854 records that the 13th recipes entry "was found only on the 1.6.0 release check, because the docs QA job runs on manual dispatch". Broken cross-language anchors (commit "cross-page anchors point at headings that exist in each language") and "2.0" wording (commit "name 'the next major version' instead of a version number") were also fixed only after the 1.6.0 release commit.

**G2. No schedule.** No workflow has `schedule:`. Browser audits, Lighthouse and visual diffs run only when someone starts them. Every regression between releases piles up for the release check. The audit races (two dispatched audits on the same ref, or an audit racing a push) come from manual starts without a concurrency policy on the QA workflows.

**G3. Translation staleness is measured but nobody looks.** A read-only recomputation of `source_rev` against the current English sources found **164 current, 32 stale and 0 unstamped** translations (en→ko/ja guides and home, plus all 20 `docs/home/index.<lang>.md`). The checker's `--i18n-pages` output is authoritative; this is an approximation. Most of the stale set is install and home pages, whose bodies hold the **release version pins**. Every release therefore makes those translations "stale" with no real content change. That is noise, and it will make the 1.8 "translation may be outdated" notice (D1) fire on every release.

**G4. Reference pages frozen at 1.0.** The docs **Changelog page** (`reference/changelog`, en/ko/ja) still holds only the "1.0.0 (first release)" section, six releases later. The **Roadmap page** opens with "Supported in 1.0" and has a generic "Next". No test ties either page to the current version. These are the most visible examples of B, and they are user-facing.

**G5. Hand edits at release.** The `Visual:` note, the `## [X.Y.Z] - date` heading, the compare and tag links, the install pins in eight files and `version.html` are all edited or run by hand (RELEASING steps 1-2). Tests catch some mistakes only after the edit. Nothing checks:

- that a minor release has a `Visual:` line (1.5.0 and 1.6.0 do; earlier ones do not);
- the section names and order (1.1.0 and 1.2.3 use a non-standard `### Documentation`);
- that ADR ids cited in entries exist. All 31 distinct ids in CHANGELOG and docs resolve today, but nothing enforces that.

**G6. The changelog is edited up to the tag.** The `release: 1.6.0` commit was followed by six more commits before `v1.6.0` was tagged on the last one. Two of them edited the 1.6.0 entry by hand (a new Fixed bullet, a reworded line). In that same window the user docs replaced "errors in 2.0" with "the next major version", but the CHANGELOG entry kept "(errors in 2.0)". The wording ban covers docs, not CHANGELOG, so the two surfaces drifted apart.

**G7. Parallel work collides on one file.** The coordinator runs one work item per subagent, and 1.7.0 adds about fifteen items (adr:modootoday/20261109141321). Each would append to the same `## [Unreleased]` block, so concurrent edits conflict or get lost on rebase. The file-per-change model (towncrier, changie, changesets, GitLab's changelog entries) exists for exactly this.

**G8. No agent instructions in the repository.** There is no `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` or path-scoped rule file. Agent rules live in the coordinator's private brief, so any other agent (or a fresh session) starts without them. CONTRIBUTING has the human version but is long (about 140 lines of mixed policy and reference) and does not say "record decisions in an ADR".

**G9. Decisions are not enforced.** Budget exceptions sometimes cite an ADR next to the constant (structure.rb's `ENTRY_LIMITS` does), but nothing requires it. Commits that change a limit, a rule in RULES.md or the public API page are not checked for an ADR id. Decisions "left in chat" have no structural stop.

**G10. The release does not check the release checks.** RELEASING step 3 asks for green CI, Lighthouse and visual runs on the release commit, but `release.yml` publishes from a tag without verifying they ran on that SHA.

**G11. Docs tests that are still missing.** Every config key the checker's schema registers (26 today) does appear in the Configuration guide, but by luck rather than a test. The same goes for the reverse direction (every documented `modootoday.<key>` is registered) and for checker CLI flags outside the README.

---

## 3. Candidate work items

Columns:

- **Runs:** pre-push hook (local, before landing), push CI, nightly (scheduled CI), or release (release-prep script or release workflow).
- **Cost:** S ≤ half a day, M 1-2 days, L more.
- **Deps:** other items it needs first.
- **Verdict:** 1.7, 1.8, later or reject.

### A. Agent governance

| # | Item | What it adds | Runs | Cost | Risk | Deps | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A1 | **Root `AGENTS.md`** (public, generic) | Project overview; the exact commands (both stacks, `npm test`, docs build, the generators with `--check`); the hard rules (Liquid only, no plugins, English first then stamp, never edit generated files, caps and limits change only with an ADR, user docs never name a future version); a "definition of done" per change type; where decisions live (`.spec/adr`, `spec new`). `CLAUDE.md` is a one-line import of it; Copilot and most other agents read `AGENTS.md` natively. | read by agents | S | Low; must stay short or it gets ignored (budget about 4 KB) | – | **1.7** |
| A2 | **AGENTS.md drift test** | `governance_test.rb` asserts `AGENTS.md` exists, stays under its size budget, and that every command it lists exists (Rake task, npm script, script path) | push | S | Low | A1 | **1.7** |
| A3 | **Nested `AGENTS.md`** in `docs/`, `lib/modootoday/check/`, `test/system/`, `_sass`+`assets` | Path-scoped rules: docs (sections, front matter, stamps, banned words); checker (message style, snapshot refresh); system audits (concurrency, no sleeps); assets (registry row and cap, page types). The nearest file wins, per the agents.md convention and Copilot's support for it. | read by agents | S | Low; duplication with CONTRIBUTING; link rather than copy | A1 | **1.7** (docs, assets) / **1.8** (rest) |
| A4 | **Shared pre-push hook** `script/hooks/pre-push` (opt-in via `git config core.hooksPath script/hooks`; agents' brief turns it on) | Runs the ≤30 s set: structure.rb, `docs-index --check`, `i18n-build --check`, `readme-commands --check`, version and changelog lint (C1), ADR-id resolution (A6), public-surface guard, changelog-fragment presence (C3). The only pre-landing gate in a direct-to-main repo. | pre-push | S | Hooks can be skipped (`--no-verify`); push CI repeats them | C1, A6 | **1.7** (early) |
| A5 | **CONTRIBUTING "Decisions" and "Definition of done" sections** | A table mapping change type → files to touch → checks. Examples: new option → checker key, docs (en/ko/ja), fragment; new asset → registry row and cap; limit change → ADR. Also "a decision lives in an ADR, not in a commit message or chat". The PR template points at the same table. | docs | S | Low | – | **1.7** |
| A6 | **ADR references resolve** | A test: every `adr:/audit:/research:` id cited in CHANGELOG, docs, tests, scripts and code names a committed `.spec` file, and the ADR is not `superseded` where a test or limit relies on it | push | S | Low (0 failures today) | – | **1.7** |
| A7 | **Governed constants cite an ADR** | Each limit or exception constant (structure.rb limits and `ENTRY_LIMITS`, Lighthouse `budget.json`, guide targets, `FLAT_OK`/`LONG_OK` entries where the reason is a decision, `PAGE_TYPES` additions) carries an `adr:` id on its line or in a sidecar map; the test fails on a governed constant without one. Registry caps stay outside this (their rule is mechanical: measured +10 %). Deterministic, needs no git history. | push | S-M | Must define the governed set precisely or it nags | A6 | **1.7** |
| A8 | **Decision trailer on governed paths** | For commits since the last tag that touch RULES.md, the public API page, `structure.rb` limits, `budget.json` or workflows: a check (pre-push and push CI, report then fail) that the commit body has `Decision: adr:…` or the diff adds or changes a `.spec/adr` file. Closes "decision left in chat". | pre-push, push | M | False positives on mechanical edits; needs a `Decision: none (reason)` escape | A6 | **1.8** (report-only trial in late 1.7) |
| A9 | **`spec check` in push CI** | Runs the repository's spec config (ids, relations, public-surface guard on `.spec/**`) on every push touching `.spec/` | push | S | Adds a Node tool install to one job | – | **1.7** |
| A10 | **Extend the public-surface guard** | The same deny patterns (private paths, secrets, internal directory names) applied to `AGENTS.md`, changelog fragments, CHANGELOG and docs (structure.rb already bans the private spec dir name in docs) | push, pre-push | S | Low | A1, C2 | **1.7** |
| A11 | **PR template refresh** | Fragment, ADR, `Visual:` impact, stamps; matches A5. Outside contributors still use PRs. | PRs | S | Low | C2 | **1.7** |
| A12 | **Release workflow verifies the release checks** | Before pushing the gem, `release.yml` queries the workflow runs on the tagged SHA (`ci.yml` full, `lighthouse.yml`, `visual.yml`) and fails unless each concluded `success`. Optionally also a fresh nightly (B3) on the same SHA. Makes RELEASING step 3 structural. | release | S-M | Could block a release on a flaky run (re-run, or a documented `workflow_dispatch` override input with a reason) | – | **1.7** (land early, so 1.7.0 itself is the first release it guards) |
| A13 | **Conventional Commits lint** | Regex check of commit subjects (types already in use, `!` for breaking); report-only | pre-push, push | S | Low value: the CHANGELOG is not generated from commits | – | **later** |
| A14 | CODEOWNERS | Review routing | – | S | One maintainer, no PR flow, so nothing to route | – | **reject (for now)**; revisit with a second maintainer |
| A15 | Required status checks or rulesets on `main` | Block a push until checks pass | – | S | Contradicts adr:modootoday/20261102203210; would need a bypass for every push | – | **reject**; A4 and A12 give the same guarantee where it matters |
| A16 | `.github/copilot-instructions.md` and `*.instructions.md` copies | Copilot-specific rules | – | S | Duplicates A1/A3; Copilot reads `AGENTS.md` | – | **reject** (a pointer at most) |

**Ship publicly vs keep private.** The public repository ships the generic, contributor-useful parts:

- `AGENTS.md` and its nested files;
- CONTRIBUTING's definition of done;
- the PR template and the pre-push hook;
- the CI and the tests;
- ADRs under `.spec/adr`, which already ship as public-safe and are cited from CHANGELOG.

It keeps private:

- the coordinator's delegation protocol and common brief;
- host and runner specifics, lease or load rules, account ids and tokens;
- the session-level progress files;
- research drafts in the git-ignored local spec dir.

The public `AGENTS.md` must make sense to an outside contributor's agent with no knowledge of the private workflow. The private brief should say "follow AGENTS.md" and add only what is private. llms.txt and twins serve *site users'* agents (docs content) and stay separate from contributor instructions.

### B. Docs drift

| # | Item | What it adds | Runs | Cost | Risk | Deps | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- |
| B1 | **Run `structure.rb` and `coverage.rb` in `rake test`** (or the Ruby job) | Neither needs a build; sidebar caps, banned wording, front matter, translation parents and kitchen-sink coverage fail on every push | push, pre-push | S | None | – | **1.7** (first item) |
| B2 | **Fast docs job on push** (path-filtered: `docs/**`, `_includes`, `_layouts`, `_sass`, `assets`, `i18n`, `lib`, `exe`) | Builds docs once (github-pages stack) and runs `modootoday-check --twins`, `links.rb` (anchors), `examples.rb`, and `--i18n-pages` as job-summary warnings. No browser. Budget: about 8 min wall time, `timeout-minutes: 12`, `cancel-in-progress`. | push | S-M | Adds a few minutes per docs push; amends the push-runs-fast-only decision | B1 | **1.7** (needs ADR) |
| B3 | **Nightly full QA** (`schedule:` once a day, on `main`, only when `main` moved since the last green nightly) | Browser audit (`npm run qa`), Lighthouse, visual diff against the latest tag, external link check. On failure it opens or updates **one rolling issue** per workflow (label `nightly-qa`) with the job summary, and closes it on the next green run. `concurrency: {group: nightly-qa, cancel-in-progress: false}` serializes runs (fixes the audit races). Total budget about 45 min. | nightly | M | Scheduled workflows run only on the default branch and are disabled after 60 days without repository activity in public repos; the issue is the alert channel | B2 | **1.7** (needs ADR) |
| B4 | **Concurrency groups on the dispatchable QA workflows** | `docs-qa`, `lighthouse` and `visual` get a group per ref, so a manual run and a nightly never write the same artifacts at once | push, nightly | S | None | – | **1.7** |
| B5 | **Docs Changelog page generated** | `docs/_data/releases.yml` written from CHANGELOG.md by a script (version, date, tag and compare URLs, `Visual:` line, section titles and bullet count, first sentence of each bullet as a summary); the docs Changelog page (en/ko/ja) renders it, ko/ja with translated chrome and the English bullets labelled as English; `--check` mode in `rake test`. The same data feeds the 1.7 **F7** changelog Atom feed and **R4**. | push (check), release (write) | M | Translated pages show English release text (state it); the CHANGELOG prose is long, so the summary needs a rule | C1 | **1.7** (pairs with F7) |
| B6 | **Roadmap page tied to the version** | Rewrite as "Supported now" (no version number in the heading) and "Next" naming the next minor's themes from the scope ADRs; a test that the page names no version older than the current minor | push | S | Low | – | **1.7** |
| B7 | **Config-key doctest** | Every key registered in the checker's schema appears in the Configuration guide (en, and ko/ja as code), and every `modootoday.<key>` written in docs is registered or listed as a site-only example. 26/26 pass today. | push | S | Low | – | **1.7** |
| B8 | **Generated config reference table** | Like `readme-commands`: a table (key, type, allowed values) between markers in the Configuration guide, from the schema; ko/ja share the code columns, prose stays human | push (check) | M | Schema messages are English; ko/ja need a label per key or English cells | B7 | **1.8** |
| B9 | **CLI flag doctest** | Every `modootoday-check`/`modootoday-stubs` OPTIONS flag appears in the docs pages that describe the checker (README is already generated) | push | S | Low | – | **1.8** |
| B10 | **`source_rev` ignores version pins** | The hash normalizes the install pins (`~> X.Y`, `@vX.Y.Z`, tarball versions) before hashing, so a release no longer marks the install and home translations stale. Changes the hash definition, so every stamp is refreshed once. | push | S | One-time restamp of all translations | – | **1.8**, before D1 (needs ADR; amends the source-revision owner ADR). Could move to 1.7 if the 1.7 release check should start from a clean stale list. |
| B11 | **Translation staleness report** | `--i18n-pages` output summarized per language in the push job summary (B2) and in the nightly issue (B3); release-time **strict** for en/ko/ja (stale ko/ja fails the release check), report-only for the 20 home-page languages | push, nightly, release | S | Without B10, every release shows ~16 false positives | B2, B3 | **1.7** (report) / **1.8** (strict at release, after B10) |
| B12 | **Pin rewriting moves into release-prep** | See C5: release-prep writes the eight install snippets the version test checks, so they are never edited by hand | release | – | – | C5 | (with C5) |
| B13 | **"Last verified" front matter** | `verified: X.Y` on guides and recipes, set when the usability audit reads a page; the release check lists pages not verified in the last two minors | release | S | Human-set metadata itself drifts; C2 "last updated from git" (1.8 feature) covers part of it | – | **1.8** (report-only) |
| B14 | **External link check** (lychee or a Ruby equivalent with a cache) | External URLs (links.rb lists them with `--external`) checked weekly; never on push | nightly or weekly | S | Flaky hosts: retries, an allowlist, report-only | B3 | **1.7** (inside B3) |
| B15 | **Release-time docs sweep list** | release-prep prints the docs pages whose English source changed since the last tag (`git diff --name-only vPREV -- docs/**/*.md`), for the usability audit to read first | release | S | None | C5 | **1.7** |
| B16 | Prose lint (Vale for en, textlint for ja) | Style rules beyond the regex ban list | push | M | New toolchains; i18n lint and `BANNED` already cover the observed failures | – | **later**; extend `BANNED` and the i18n lint first |
| B17 | Screenshot freshness | Docs commit no PNG screenshots (diagrams are digest-checked SVGs; the visual baseline is never committed) | – | – | – | – | **reject** (nothing to track); revisit if screenshots are committed |
| B18 | Crowdin, Lunaria, a translation platform | Hosted staleness dashboards | – | M | Lunaria is built for Astro/Starlight; translations follow repo style rules; `source_rev` already does the job | – | **reject** |

### C. CHANGELOG automation

| # | Item | What it adds | Runs | Cost | Risk | Deps | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- |
| C1 | **CHANGELOG lint** (`test/project/changelog_test.rb`) | (1) Header and Keep a Changelog sections only, in order Added, Changed, Deprecated, Removed, Fixed, Security, with the two historical `Documentation` sections grandfathered by version. (2) Every released heading has an ISO date; dates do not go backwards. (3) Link references: `[Unreleased]` compares from the latest heading, each version links its tag. (4) Every minor or major ≥ 1.5 opens with a `Visual:` line. (5) Every `adr:/audit:` id resolves (A6). (6) No private paths or internal names (public-surface patterns). (7) **Released entries are immutable**: the section of each tagged version equals that version's section in the tag's own CHANGELOG (`git show vX.Y.Z:CHANGELOG.md`), with an allowlist for link fixes. (8) New entries (Unreleased) follow the docs wording ban (no bare future-version numbers). | push, pre-push | S-M | (7) needs tags in the CI checkout (`fetch-depth: 0` or fetch tags) | A6 | **1.7** (first week) |
| C2 | **Changelog fragments** `changes/<slug>.md` (not shipped: gemspec files are a whitelist; add to the public-surface guard) | One file per change, written by the subagent that makes the change. Front matter: `kind` (KaC section), `adr: []`, `audit:`, `visual:` (a phrase for the release's `Visual:` sentence, or `none`), `public_api: true/false`, `migration:` (text for the Upgrade guide), `docs: [en, ko, ja]`; the body is the entry prose. Removes the parallel-edit conflicts on one block (G7) and makes the `Visual:` note, the public API list and migration notes derivable. | authored with the change | M | One more convention for contributors; fragments must be validated (C3) | C1 | **1.7** (early; needs ADR) |
| C3 | **"User-facing change ships a fragment" check** | For each commit since the last tag that touches shipped paths (`_layouts`, `_includes`, `_sass`, `assets`, `exe`, `lib`, `i18n`, gemspec): a fragment added in that commit or the same push, or a `Changelog: none (reason)` trailer. The towncrier `check` and changesets idea, adapted to direct-to-main pushes instead of a branch diff. Also validates every fragment's front matter. | pre-push, push | S | Trailer escape can be abused; the release review sees the reasons | C2 | **1.7** |
| C4 | **`script/changelog`**: `--preview` / `--release X.Y.Z` | Preview prints Unreleased (fragments compiled in KaC order). Release writes `## [X.Y.Z] - date`, the sections, the `Visual:` line assembled from the fragments' `visual:` phrases ("the intended differences from A are …; core pages are otherwise unchanged") for the maintainer to edit, and the link references; then deletes the fragments (`git rm`). Own Ruby script, ≤150 lines, like `release-notes`. | release | M | The `Visual:` sentence still needs a human pass; the script drafts it | C2 | **1.7** |
| C5 | **`script/release-prep X.Y.Z`** | One command: bump `spec.version`, run `version-include`, rewrite the install pins in the eight files the version test lists, run C4, regenerate B5 data, print the visual run's differing pages and widths next to the drafted `Visual:` line, and print the B15 docs list. Ends by running the version, release-notes and changelog tests. | release | M | Wrong pins only if the pin regexes drift from version_test (share them) | C4 | **1.7** |
| C6 | **Upgrade guide fed by fragments** | Fragments with `migration:` or `public_api: true` are listed by `script/changelog --migrations`; the release check fails when the Upgrade guide (en) does not mention the release's version or those items | release | S | Prose stays human-written | C2 | **1.8** |
| C7 | **Richer GitHub Release body** | `script/release-notes` appends the compare link, the docs Changelog and Upgrade links, and renders `adr:` ids as links to the committed ADR files (a release page cannot resolve the bare ids) | release | S | Low | – | **1.7** (S, optional) / **1.8** |
| C8 | Entry length guideline | Warn on bullets over ~1,200 characters (1.6.0 has several of 1,400-1,800); a "Details" link to docs instead | push (warn) | S | Style preference; may push detail out of the changelog | C1 | **later** |
| C9 | **git-cliff as a drafting helper** | Lists commits since the last tag by type to cross-check against fragments at release | release | S | One more binary; C3 already covers the check | – | **later** (optional) |
| C10 | release-please | Release PR that bumps the version and writes CHANGELOG from Conventional Commits | – | M | Needs release PRs and writes entries from commit subjects; conflicts with direct-to-main, the tag-driven protected release and the hand-written prose entries | – | **reject** |
| C11 | release-drafter | Draft release from merged PR labels | – | S | No PRs to read | – | **reject** |
| C12 | changesets | Fragment model with semver bump per package | – | M | npm-package oriented; bot is PR-based; borrow the model (C2), not the tool | – | **reject** |
| C13 | towncrier / changie | Mature fragment compilers | – | S-M | Adds a Python or Go toolchain to a Ruby + Node repository for what C2 to C4 do in ~200 lines; KaC sections and the `Visual:` line need custom templates anyway | – | **reject** (design borrowed) |
| C14 | GitHub auto-generated release notes | Notes grouped by PR labels | – | S | No PRs; the CHANGELOG is the source (as the 1.7 research's R10 also recommends) | – | **reject** |
| C15 | Commit-trailer changelog (GitLab model, `Changelog: added`) as the *source* | Entry from a trailer in each commit | – | S | Trailers are one line; this project's entries are paragraphs with ADR ids; amending is awkward after a push | – | **reject** as source; keep `Changelog: none` as the C3 escape |

---

## 4. Recommended split

### Extend 1.7.0 (land in the first days of the cycle, before the feature items)

The point is to stop the four failures (anchors, "2.0" wording, sidebar cap, audit races) as each push lands, and to stop hand-editing the changelog before about fifteen parallel items start writing to it.

**Wave 0** (one day, no ADR beyond what is listed):

1. **B1**: structure.rb and coverage.rb in `rake test`.
2. **C1**: CHANGELOG lint, including immutability of released entries.
3. **A6**: ADR ids resolve.
4. **B4**: concurrency groups on the QA workflows.
5. **A1 + A2**: root `AGENTS.md` and its drift test, with `CLAUDE.md` importing it.
6. **A5**: CONTRIBUTING "Decisions" and "Definition of done".
7. **A4**: the shared pre-push hook, turned on in every subagent's brief.

**Wave 1** (each with its ADR):

8. **C2 + C3**: changelog fragments and the fragment check. Every 1.7 item then ships a fragment instead of editing `## [Unreleased]`.
9. **B2**: the fast docs job on push (links and anchors, examples, checker, i18n-pages summary).
10. **B3** with **B14**: nightly full QA with one rolling issue and the weekly external links.
11. **A12**: the release workflow verifies the release checks on the tagged SHA.
12. **A9 + A10**: `spec check` on push and the wider public-surface guard.
13. **A7**: governed constants cite an ADR.

**Wave 2** (with the feature work, before the release check):

14. **C4 + C5**: `script/changelog` and `script/release-prep`, used for 1.7.0 itself.
15. **B5**: generated `releases.yml` and docs Changelog page, together with F7 and R4.
16. **B6**: roadmap without frozen versions.
17. **B7**: config-key doctest.
18. **B11**: report-only staleness.
19. **B15**: docs sweep list.
20. **A3**: `docs/` and assets `AGENTS.md`.
21. **A11**: PR template refresh.
22. **C7** if time remains.

Rough cost: about 6-8 S and 5 M items. Compared with the 1.7 feature list this is small, and most of it pays back inside the same cycle.

### Extend 1.8.0

1. **B10**: version pins excluded from `source_rev`, then **B11 strict** for en/ko/ja at release. Both land before the D1 "translation may be outdated" notice, which would otherwise fire on every release.
2. **B8 and B9**: generated config reference and the CLI flag doctest.
3. **C6**: the Upgrade guide fed by fragments.
4. **A8**: decision trailer on governed paths, after a report-only trial late in 1.7.
5. **A3** for the checker and system-audit directories.
6. **B13**: "last verified" report, alongside the C2 git-based "Last updated".
7. **C7** if not done in 1.7.

### Later

- A13: Conventional Commits lint.
- B16: Vale or textlint.
- C8: entry length guideline.
- C9: git-cliff as a drafting helper.
- A14: CODEOWNERS, once there is a second maintainer.

## 5. Items that need their own ADR

| Item | Why | Relation |
| --- | --- | --- |
| B2 fast docs job on push | Changes what a push to `main` runs | Amends adr:modootoday/20261102203210 (push runs fast jobs only) |
| B3 nightly QA and rolling issue | New gate cadence, alert channel, run budget, the 60-day inactivity caveat | Same; also adr:modootoday/20261029211906 (QA gate v2) |
| C2-C5 changelog fragments and release-prep | Changes the CHANGELOG's source of truth and the release procedure (RELEASING steps 1-2) | New; references adr:modootoday/20261029201115 (release from tags) |
| A12 release verifies release checks | Changes the release gate and adds an override path | Amends adr:modootoday/20261029201115 |
| A7/A8 governed constants and decision trailers | Defines which changes need an ADR and how that is proven | New; references adr:modootoday/20261104053146 (caps stay mechanical) |
| B10 version-normalized `source_rev` | Changes the hash definition and forces one restamp | Amends the ADR on one owner of a page's language and source revision (adr:modootoday/20261103121248) |
| A1 public agent instructions | What ships publicly vs stays in a private brief; `AGENTS.md` as the single agent entry point | New (short) |

B5 (generated docs Changelog page) can be recorded inside the F7/R4 work under the 1.7 scope ADR, or as a short ADR if the page's ko/ja treatment (English release text) needs a decision.

## 6. Rejected options and reasons

- **release-please, release-drafter, the changesets bot, GitHub auto-generated notes.** All assume pull requests or PR labels. They would also replace a carefully written prose CHANGELOG with commit- or PR-title text. The tag-driven, environment-protected release stays.
- **towncrier, changie.** Same fragment model, but they add a Python or Go toolchain. A ≤150-line Ruby script fits the repository's conventions and handles the custom `Visual:` line.
- **Required status checks or branch rulesets on `main`.** They contradict direct-to-main. The pre-push hook (before landing), push CI (after landing) and A12 (at release) cover the same risk where it matters.
- **CODEOWNERS now.** With one maintainer and no PR flow it routes nothing.
- **Copilot-specific instruction copies.** Copilot and most agents read `AGENTS.md`; copies drift.
- **Browser audits or external links on every push.** Too slow (~35 min) and flaky; nightly or weekly with an issue is the right cadence.
- **Vale or textlint now.** The failures seen are covered by the regex ban list and the existing i18n lint; revisit if prose-style findings recur in audits.
- **A translation platform (Crowdin) or Lunaria.** Translations are localized under the repository's own style rules, `source_rev` already measures staleness, and Lunaria targets Astro/Starlight sites.
- **Screenshot freshness tracking.** The docs commit no screenshots; diagrams are digest-checked SVGs and the visual baseline is never committed.
- **Commit trailers as the changelog source.** Entries here are paragraphs with ADR and audit ids; a trailer only works as the "no changelog" escape.

## 7. Sources

**Agent instructions and governance**

- AGENTS.md format and nearest-file precedence: https://agents.md/
- GitHub Copilot repository instructions (`.github/copilot-instructions.md`, path-specific `*.instructions.md` with `applyTo`, `AGENTS.md` and a single root `CLAUDE.md`/`GEMINI.md` supported): https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot
- Claude Code memory files (`CLAUDE.md`, imports with `@path`): https://docs.anthropic.com/en/docs/claude-code/memory
- llms.txt proposal: https://llmstxt.org/
- CODEOWNERS: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners
- Git hooks and `core.hooksPath`: https://git-scm.com/docs/githooks
- Architecture Decision Records (MADR template and ADR practice): https://adr.github.io/ , https://adr.github.io/madr/

**Docs drift and CI**

- GitHub Actions `schedule` event (default branch only, shortest interval 5 minutes, disabled after 60 days without activity in public repositories): https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows
- Concurrency in GitHub Actions: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/control-the-concurrency-of-workflows-and-jobs
- Starlight i18n (fallback notice for untranslated pages): https://starlight.astro.build/guides/i18n/
- Lunaria (localization status dashboard and PR insights): https://lunaria.dev/
- Docusaurus i18n and Crowdin: https://docusaurus.io/docs/i18n/introduction , https://docusaurus.io/docs/i18n/crowdin
- Kubernetes localization (tracking upstream changes to localized pages): https://kubernetes.io/docs/contribute/localization/
- Vale: https://vale.sh/ ; textlint: https://textlint.org/
- lychee link checker: https://github.com/lycheeverse/lychee
- html-proofer (the model for `links.rb`): https://github.com/gjtorikian/html-proofer

**CHANGELOG and releases**

- Keep a Changelog 1.1.0 (section names and order): https://keepachangelog.com/en/1.1.0/
- Semantic Versioning: https://semver.org/
- Conventional Commits: https://www.conventionalcommits.org/en/v1.0.0/
- towncrier CLI (`check` against a branch, `{issue}.{type}` fragments, `build` compiles and removes them): https://towncrier.readthedocs.io/en/stable/cli.html
- changie (changelog from files in the project, not commit tags): https://changie.dev/guide/
- changesets: https://github.com/changesets/changesets
- git-cliff (changelog from conventional commits, `cliff.toml` templates): https://git-cliff.org/docs/
- release-please (release PRs): https://github.com/googleapis/release-please
- release-drafter (drafts from PR labels): https://github.com/release-drafter/release-drafter
- GitHub automatically generated release notes: https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes
- GitLab changelog entries from commit trailers: https://docs.gitlab.com/ee/development/changelog.html
- RubyGems trusted publishing: https://guides.rubygems.org/trusted-publishing/

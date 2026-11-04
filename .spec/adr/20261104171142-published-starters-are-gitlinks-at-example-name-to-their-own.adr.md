---
id: adr:modootoday/20261104171142
title: Published starters are gitlinks at example/<name> to their own repositories
status: active
created: 2026-11-04T17:11:42Z
updated: 2026-11-04T17:15:10Z
rel:
  governs: [example, script/starters]
  depends_on: [adr:modootoday/20261104171141, adr:modootoday/20261104170556, adr:modootoday/20261103152846]
  evidence: [research:modootoday/20261104170510]
---

# Published starters are gitlinks at example/<name> to their own repositories

## Context

- **What exists.** Each starter is a plain folder beside the manifest, `example/<name>/`. `rake starters:render` writes the published form into `pkg/starters/<stack>/<name>/` and derives everything a person does not write ([[adr:modootoday/20261103152846]]).
- **Where starters publish.** Each starter publishes to `modootoday/jekyll-theme-modootoday-<name>-starter` ([[adr:modootoday/20261103202417]]), and that repository's Pages site is its demo ([[adr:modootoday/20261104170556]]).
- **The decision asked for.** The maintainer decided that the theme repository holds every published starter as a gitlink (a git submodule) to its own repository.
- **What `example/` holds today:** only `starters.yml` and the three starter folders. There is no shared `_data`. The render inputs (the README, Gemfile and Pages workflow templates) live in `script/starters/templates/`.
- **Who reads `example/<name>`:** 16 test and script files, the Starters workflow, CONTRIBUTING and RELEASING.

## Decision

- **Path.**
  - A published starter is a gitlink at `example/<name>`: the folder it already occupies, with `example/starters.yml` beside it.
  - Every reader of `example/<name>` keeps its path. The `[public]` paths of `spec.toml` stay right, and the manifest stays the one list.
  - A `starters/` directory is not added.
- **Manifest semantics.**
  - **`repo:`** is the starter repository, `owner/name`. Its HTTPS URL, `https://github.com/<repo>.git`, is the submodule URL. HTTPS is required, because GitHub Pages fetches only public HTTPS submodules.
  - **`path:`** is optional and defaults to `example/<name>`. It must equal the starter's `.gitmodules` path once published.
  - **Whether a starter is published** is read from git (the path is a gitlink, mode 160000), never from a manifest flag.
  - **Tests** fail when a `.gitmodules` entry has no manifest row, or when its URL or path differs from the row.
- **Source of truth.**
  - **The starter repository holds the published tree:**
    - the hand-written content (Markdown, `_data`, `_config.yml`, assets);
    - the files the theme derives for the `github-pages` stack: the `remote_theme` pin in `_config.yml`, `README.md`, `.github/workflows/pages.yml`, `_config.demo.yml`, and the twin, record and alias stubs.
  - **Content** is edited inside the submodule and committed and pushed in the starter repository. The theme repository then commits the new gitlink.
  - **Derived files** stay owned by the theme's renderer.
  - This amends [[adr:modootoday/20261103152846]] for published starters only: they now contain their derived files, and plain folders still refuse them.
- **Render, check and build.**
  - **`rake starters:render[name]`:**
    - for a published starter, it rewrites the derived files inside the submodule's work tree, for a person to commit there;
    - for a plain folder, it renders into `pkg/` as today;
    - the `jekyll4` tree of every starter is rendered into `pkg/starters/jekyll4/<name>/` from the starter's content, for CI only.
  - **Idempotence:** the renderer reproduces its own output, so rendering a published tree yields the same tree.
  - **`rake starters:check`:**
    - renders each published starter from its own content into a temporary directory and fails on any difference from the submodule;
    - for plain folders, it compares with `pkg/` as today.
  - **The pin:** the check renders with the version the starter pins in `remote_theme`. It fails when that pin is not a released tag, and warns when it is behind the gemspec version.
  - **`rake starters:build[name]`** builds the `jekyll4` tree with this checkout's theme, as today. The Starters workflow keeps its classic job, with `remote_theme` overlaid at the pushed commit.
- **The demo layering on the classic builder.**
  - `actions/jekyll-build-pages` takes no config list, so the rendered `pages.yml` merges `_config.demo.yml` into `_config.yml` inside the runner before the build.
  - The step is guarded by `github.repository == '<repo>'`, so a site generated from the template, or a fork, builds without the showcase and without `noindex`.
  - A test pins the guard in the rendered workflow.
- **Branches in a starter repository.**
  - **`main`** is the deployed demo and builds with its pinned release only.
  - **`next`** holds content that needs an unreleased theme feature. Between releases the theme's gitlink may point to a `next` commit. Theme CI tests it against the theme's head through the `remote_theme` overlay.
- **Release flow, in order, with no cycle.** A starter pins only released tags, and the theme's release never waits for a starter.
  1. Theme repository: the release commit (version, CHANGELOG) and the tag `vX.Y.Z`. Gitlinks are unchanged.
  2. The release workflow publishes the gem.
  3. Each starter repository:
     - merge `next` into `main` if it has commits;
     - run `rake starters:render[name]` from the theme checkout at the tag, which moves the pin to `vX.Y.Z` and refreshes the derived files;
     - commit (`chore: theme vX.Y.Z`) and push `main`. The starter's Pages workflow redeploys the demo.
  4. Theme repository: one commit, `chore(starters): pin starters to vX.Y.Z`, moves every gitlink to those commits.
- **Gem.**
  - `spec.files` is `git ls-files` filtered by the runtime path pattern and by `File.file?`. A gitlink is listed as one path to a directory and `example/` is not a runtime path, so neither filter lets it through.
  - A test asserts that no `example/` path is in `spec.files`.
- **Checkouts and builds.**
  - **Theme workflows:** every job that runs tests or builds or audits starters checks out with `submodules: true`: the CI test jobs, Starters, Visual, Lighthouse, and Release before `rake test`.
    - The tests read `example/<name>`.
    - The repositories are public, so no token is needed.
    - Jobs that read no starter may omit it.
  - **The docs Pages build** (classic, `main` `/docs`) fetches public submodules automatically. The gitlinks are outside `docs/`, so Jekyll never reads them and no `exclude:` is needed.
  - **An unreachable submodule fails the Pages build.** So a gitlink is added only after its repository is public.
- **Contributor flow.**
  - Clone with `git clone --recurse-submodules`. An existing clone runs `git submodule update --init`. `git config submodule.recurse true` keeps them in step on pull and checkout.
  - To change a starter:
    1. `cd example/<name>` and `git switch next` (or `main` for a change that builds with the pinned release).
    2. Edit, then run `rake starters:render[name] starters:check starters:build[name]` from the theme root.
    3. Commit and push in the starter repository.
    4. In the theme repository, stage `example/<name>` and commit `chore(starters): bump <name>`.
  - CONTRIBUTING and RELEASING say this in the change that adds the first gitlink.
- **Bootstrapping.** No starter repository exists yet.
  - **Until a starter's repository is public**, the starter stays a plain folder, and [[adr:modootoday/20261103152846]] holds unchanged. No `.gitmodules` file exists before the first publish.
  - **A starter becomes a gitlink in the change that publishes it.** This happens after 1.5.0, and after 1.6.0 for the first three, because the showcase ships in 1.6.0. In order:
    1. The maintainer creates the public repository, marks it as a template and sets Pages to GitHub Actions.
    2. The rendered `github-pages` tree is pushed as the repository's first commit, pinned to the latest release. Its demo deploy must be green.
    3. One theme commit:
       - replaces the folder with a gitlink at the same path and adds the `.gitmodules` entry;
       - moves the starter's rows of [[sot:modootoday/docs-demo-to-starter-map]];
       - adds `submodules: true` to the workflows on the first publish;
       - updates CONTRIBUTING and RELEASING.

## Consequences

- One repository per starter holds its content, template and demo. The theme repository pins an exact commit of each, so theme CI always tests a known starter.
- **A theme change that needs starter content** takes two commits: the starter's (on `next`) and the theme's gitlink bump. CI catches a gitlink that points to an unpushed commit, because the checkout fails.
- **The `pkg/starters/` render** stays for the `jekyll4` stack and for unpublished folders. Publishing by hand from `pkg/`, which RELEASING describes today, is replaced by pushing in the submodule.
- **Rename and move cost:** removing or renaming a starter needs a `.gitmodules` edit and a manifest edit in one commit.
- **Not done here:** creating repositories, setting the template flag and turning on Pages are maintainer steps.

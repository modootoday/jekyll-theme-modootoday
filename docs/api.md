---
title: Public API
description: The names this theme keeps stable, and how they are deprecated and removed.
---
# Public API

From 1.0 on, the names below follow [Semantic Versioning](https://semver.org/): they change incompatibly only in a major version. Anything not listed (internal includes, Sass partial paths, private `--mt-p-*` primitives, HTML details that no rule describes) can change in any release.

## Stable names

| Area | Stable names |
|---|---|
| Settings | every key under `modootoday:` listed in [Configuration](../configuration/) |
| Design tokens | semantic and component custom properties `--mt-*` (not the primitives `--mt-p-*`); the generated `tokens.json` mirrors them |
| Markdown rules | the patterns in `RULES.md` and their output classes `mt-*` |
| Layouts | `default`, `doc`, `post`, `twin`, `llms`, `llms-full` |
| Includes you may override | `head-custom.html`, `footer-custom.html` |
| Data files | `_data/i18n/<lang>.yml` keys, `_data/nav/<name>.yml`, `_data/components.yml` |
| Checker | the `modootoday-check` options, exit code 0 (no problems) and 1 (problems or bad usage) |

## Deprecation policy

1. A name that will go away is marked deprecated in `CHANGELOG.md` and in the docs, and the checker warns where it can.
2. It keeps working for at least one minor release.
3. It is removed only in the next major release.

> [!IMPORTANT]
> The old `md-*` classes and `--md-*` properties are aliases of `mt-*` and `--mt-*`. They stay through 1.x, are marked deprecated in 1.0, and are removed in 2.0. `modootoday-check` warns when your own Sass, CSS, includes, layouts or pages use them. See the [mapping table](../upgrade/).

## Not in 1.0

- A per-component slot contract in `_data/components.yml` beyond parameter checks is planned for 1.x.
- Right-to-left layouts, math and diagrams are non-goals for 1.0; see [Roadmap](../roadmap/).

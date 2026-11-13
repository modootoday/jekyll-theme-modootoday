---
id: adr:modootoday/20261109200230
title: "Docs consistency rules: one canonical page per topic, a glossary, a front matter contract, parity, version mentions, code registries, navigation shape and link style"
status: active
created: 2026-11-09T20:02:30Z
updated: 2026-11-09T20:02:55Z
rel:
  governs: [docs]
  depends_on: [audit:modootoday/20261109200220, adr:modootoday/20261030083000]
---

# Docs consistency rules: one canonical page per topic, a glossary, a front matter contract, parity, version mentions, code registries, navigation shape and link style

## Context

[[audit:modootoday/20261109200220]] read the documentation site after 1.6.0 and found 52 problems: 3 blockers, 19 major, 30 minor. They include:
- duplicate explanations, such as Markdown twins explained in six places and the components index repeating the kitchen sink;
- one thing under several names;
- pages frozen at 1.0 (Changelog, Roadmap);
- a Public API page that lists 8 of 46 layouts;
- configuration keys the checker does not register;
- a sidebar over its cap;
- stale ko/ja pages.

[[adr:modootoday/20261030083000]] fixes the information architecture: sections, groups, generated navigation and twins. It does not say how pages relate to each other, what words they use, or how they stay true to the code. Contributors, human or agent, had no rule to follow, so each change added its own wording. The maintainer asked on 2026-11-09 for these rules to be canonical before the cleanup starts.

## Decision

Every docs page, in every language, follows these rules. A change that breaks one fails a test, where the check is cheap.

- **R1 One canonical page per topic.** A topic map, a docs data file, names the canonical page for each topic: install, twins, configuration keys, components, layouts, CLI and so on. Other pages summarize in at most one short paragraph and link the canonical page. They never repeat it. Test: no paragraph longer than 200 characters appears verbatim in two pages, and every page that mentions a mapped topic links its canonical page.
- **R2 Glossary.** One term per concept, listed in a glossary data file with the terms to avoid:
  - the product name;
  - "starter site";
  - "twin";
  - "optional stylesheet";
  - component id vs display name;
  - one spelling per word: "color", not "colour".
  The docs show a component's id next to its display name wherever the id is what an author types. Test: an English "avoid" lint, in the same form as the existing i18n lint.
- **R3 Front matter contract.**
  - The H1 equals `title`.
  - `description` is 70–160 characters.
  - `nav_order` is an integer, unique in its group.
  - `nav_title` exists only as a shorter form of `title`.
  - Keys follow one order.
  - Demo pages set `twin:` explicitly.
  Test: extend the docs structure check, which runs in `rake test` on every push.
- **R4 en/ko/ja parity.**
  - ko and ja exist for every English page unless `translate: false`.
  - Their heading tree matches the English page.
  - `source_rev` ignores install version pins (research B10).
  - ko/ja staleness is reported on every push and fails at release.
  Test: a heading-tree comparison, plus the checker's `--i18n-pages`.
- **R5 Version mentions.**
  - No past version in a heading.
  - No past version in the body outside Upgrade and Changelog.
  - Exception: a row of the Configuration key table whose key, or its newest form, a minor release added starts its description with that bare version in bold, so a reader on an older gem can tell which keys it lacks (m1 of [[audit:modootoday/20261113044135]]). It is a bare version, never a sentence; a column was tried first and left most rows blank (the 1.7.1 screenshot review).
  - The Changelog page is generated from CHANGELOG.md.
  - The Roadmap names no frozen version.
  Test: more patterns in the structure check's banned list, plus a `--check` on the generated pages.
- **R6 Docs follow the code registries.**
  - Every `modootoday.*` key the theme reads is registered in the checker schema and listed in the Configuration table, and the reverse.
  - Every shipped layout is in the Public API list or explicitly marked internal.
  - Every component in components.yml has its heading.
  - A CLI reference page is generated from the CLI's help.
  Test: doctests between each registry and its page.
- **R7 Navigation shape.**
  - Groups hold 12 entries or fewer, with a warning at 11.
  - No group directory holds only an index.
  - No page is an orphan: every page is in the navigation or linked from one.
  - Sample-site pages (blog, news, authors) stay out of the docs navigation and out of the llms.txt docs list.
  Test: the structure check, plus a build-free source link-graph pass.
- **R8 Link style.**
  - Links between docs pages are relative, never with a hard-coded base URL.
  - Every guide and recipe links at least one related page.
  Test: regex checks.

The cleanup of the audit's findings follows these rules. The nine findings that overlap the component-order item (D1, D2, D6, D9, T1, N1, N2, X4, and the components half of X2) are fixed within that item or right after it, not in parallel.

## Consequences

- A new or changed docs page has one place for each fact, one word for each concept, and a check that says when it drifts.
- Some rules need data the docs do not have yet: the topic map, the glossary and the full key registration. Each check lands together with its data, first in report mode where the existing pages would fail it, and becomes blocking once the cleanup has cleared them.
- AGENTS.md and CONTRIBUTING's "Definition of done" point to these rules, so agents and people apply the same contract.

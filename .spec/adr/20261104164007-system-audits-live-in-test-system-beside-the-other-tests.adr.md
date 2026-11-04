---
id: adr:modootoday/20261104164007
title: "System audits live in test/system, beside the other tests"
status: active
created: 2026-11-04T16:40:07Z
updated: 2026-11-04T16:40:22Z
rel:
  governs: [test/system]
---

# System audits live in test/system, beside the other tests

## Context

The browser audits, the docs site build and server, the docs link and structure checks, the CSS size report, Lighthouse, visual regression and the records benchmark lived in a top-level `qa/` directory. Ruby gem and Rails conventions keep every kind of test under `test/`, with whole-system checks in `test/system/`; a separate top-level directory was one more place for contributors to learn and for the gemspec, the layout test and the docs to name.

## Decision

- `qa/` moves to `test/system/` with its structure unchanged (`audit/`, `audit/budgets/`, `audit/keyboard/`, `audit/layout/`, `audit/screen-reader/`, `bench/`, `css/`, `docs/`, `lighthouse/`, `site/`, `visual/`).
- The npm script names stay: `npm run qa`, `npm run qa:visual` and `npm run qa:visual:update` run the moved files, and reports still go to `qa-out/`.
- Code files under `test/system/` follow the 150-line limit for code that is not a test file; the layout test no longer lists `qa/` separately.
- The gem keeps shipping no `test/` file (the gemspec lists runtime directories only).

## Consequences

- CI workflows, `package.json`, `.gitignore` (the visual baseline is `test/system/visual/baseline/`), CONTRIBUTING and the governed paths of earlier decisions name `test/system/`.
- Released CHANGELOG entries keep the old path as history.
- `rake test` does not run the system audits: they are not `*_test.rb` files, and the browser audits need a built site and a browser, so CI runs them in their own jobs.

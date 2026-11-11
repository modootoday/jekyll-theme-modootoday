---
id: adr:modootoday/20261111011654
title: "The docs site turns the PWA on, with its stubs under generated/ and a QA check of its own"
status: active
created: 2026-11-11T01:16:54Z
updated: 2026-11-11T01:36:53Z
rel:
  governs: [docs/_config.yml, script/docs/outputs.rb, test/system/audit/features/pwa/docs.mjs]
  depends_on: [adr:modootoday/20261110133153, adr:modootoday/20261111002136]
---

# The docs site turns the PWA on, with its stubs under generated/ and a QA check of its own

## Context

The service worker, the update notice and the install section ([[adr:modootoday/20261110133153]], [[adr:modootoday/20261110165219]], [[adr:modootoday/20261111002136]]) are checked on fixture builds. The docs site is where readers meet the theme, where offline reading pays off, and the only place a real GitHub Pages deploy (cache headers, redirects, a shared `modootoday.github.io` origin) can be watched. It also showed the install section's checker warning while the PWA was off. The docs keep tool output under `docs/generated/` (twin and llms stubs, each naming with `path:` where it stands), and `script/docs-index` is the docs' one generator.

## Decision

- **On, derived.** `docs/_config.yml` sets `modootoday.pwa: {enabled: true, short_name: modoo.today}`; the name, description, icons and colours come from the existing settings. Rolling back is `enabled: kill` (the recipe's Turn it off), never deleting the stubs.
- **Stubs under generated/.** `Modootoday::Stubs::Pwa` takes `dir:` as `Twins` does: each stub sets `path:` to its root path. `script/docs-index` writes `generated/{manifest.webmanifest, sw.js, offline.md, offline.ko.md, offline.ja.md}` through it, writes nothing while the PWA is off and never prunes them. The docs tree skips `generated/`, so the offline stubs are not docs pages or translations. `modootoday-check` reads the stubs from `generated/` when `generated/sw.js` exists, as it finds twin stubs there.
- **QA.** `recipes/pwa/` and `offline/` join the audit pages, the strict CSP pages, the visual run and (the recipe) Lighthouse; `offline` is a page type. The strict CSP demo gains a `c: install` section, so the CSP audit covers it. `features/pwa/docs.mjs` opens that demo and checks the manifest and installability through CDP (ignoring the error a private context always reports), a worker that controls the page with scope `/jekyll-theme-modootoday/`, cache names under `mt:/jekyll-theme-modootoday/:`, the install button hidden with its hint shown, and the precache total, a warning over 150 KiB.
- **Measured.** The docs precache is 13 URLs, 105,063 B raw (102.6 KiB): three offline pages (7.5 KiB each), the home page (`start_url`, 50,007 B) and nine theme files. No CSS or JS file changes and no cap changes; every page adds the register module (cap 1408) to its derived limit.

## Consequences

- Every docs page gains a manifest link and the register module, which draw nothing; `offline/` exists in English, Korean and Japanese. The install section's warning is gone.
- After the deploy, the live drill (plan R-5) runs on the public site: registration, cache names, kill and back.
- A larger home page grows the precache; the QA warning says when it passes the guide target.

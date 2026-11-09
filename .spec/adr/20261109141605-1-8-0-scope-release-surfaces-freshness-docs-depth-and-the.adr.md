---
id: adr:modootoday/20261109141605
title: "1.8.0 scope: release surfaces, freshness, docs depth and the GitHub-surface items deferred from 1.7"
status: active
created: 2026-11-09T14:16:05Z
updated: 2026-11-09T15:00:54Z
rel:
  governs: [_layouts]
  depends_on: [research:modootoday/20261109141301, adr:modootoday/20261109141321, research:modootoday/20261109143250, research:modootoday/20261109150011]
---

# 1.8.0 scope: release surfaces, freshness, docs depth and the GitHub-surface items deferred from 1.7

## Context

[[research:modootoday/20261109141301]] ranks about fifty extensions and assigns each to 1.7, 1.8 or later. [[adr:modootoday/20261109141321]] takes every 1.7 item. On 2026-11-09 the maintainer asked for the 1.8 scope to be recorded as well, so the next release has a canonical list before 1.7 ships. The research's per-item fit, byte estimates, risks and sources stay in the research document; this record fixes what is in 1.8.0 and in what order of priority.

## Decision

1.8.0 holds these items, all opt-in, each with its own context sheet row or a row in an existing one, its cap measured +10 % rounded up to 128 B ([[adr:modootoday/20261104053146]]), labels in every catalog and docs in en, ko and ja.

- **Release surfaces (the headline).**
  - **R1** A releases page or section from GitHub Releases: `site.github` on classic Pages, or `_data` written by an Actions job where the API limit or fields require it.
  - **R3** Download tables from release assets with size, platform and the SHA-256 digest when GitHub provides one (no digest, no column; never a made-up value).
  - **R5** Release notes as one page per version, as a recipe on the existing layouts.
  - **R7** Starters pick up new theme tags (a scheduled job that proposes the pin change).
- **Freshness.**
  - **C2** "Last updated" from git.
  - **D1** A "translation may be outdated" notice, after C2.
  - **J3** Sitemap `lastmod` (and `hreflang` alternates where useful) from the same data.
- **Docs depth.**
  - **A3** Code line highlighting and optional line numbers.
  - **B2** Search hits that land on headings.
- **GitHub surfaces.**
  - **G4** A contributors section.
  - **G5** A repository stats chip built at build time.
  - **G7** Comments (giscus or utterances) behind a click-to-load facade. This needs its own CSP and privacy ADR before code: nothing third-party loads until the reader asks.
- **Reading and offline.**
  - **A2** Image zoom without script.
  - **A6** A CSS-only reading progress bar.
  - **E2** "Make available offline" in the page actions menu, on the 1.7 service worker.
  - **B5** Speculation-rules prefetch, moderate eagerness, where the CSP allows it.
- **Checker.**
  - **L2** Image checks: missing alt text and body images without a known size.
- **Stretch, may move to 1.9.**
  - **J1** Open Graph images generated at build, if CJK and RTL text can be rendered without a new runtime dependency.

Prerequisites carried from 1.7: the spike on what `site.github` returns on github-pages 232 (release count, asset digests, discussion URL, the `github:` override for offline fixtures), and whether a branch-built Pages site rebuilds on a published release.

Later than 1.8: versioned docs (C1, R8) and attestation display (R11) need a design ADR each; a command palette (B4); periodic background sync (F5) stays experimental; web push (F1, F4) stays a recipe until a site-owned endpoint contract is designed (2.x).

## Consequences

- 1.8.0 is the release in which GitHub Releases become a content source; R1 and R3 lead its usability audit.
- G7 is the first opt-in feature that can load a third party; its ADR decides the facade, the CSP additions a site must make and the privacy wording.
- An item can move to 1.9 only by amending this record.

## Amendment (2026-11-09): Cloudflare layers, tiers and presets

The maintainer decided on 2026-11-09 that 1.8.0 also uses Cloudflare, under three rules; [[research:modootoday/20261109143250]] sorted the candidates under them.

- **Layers, not a new host.** GitHub Pages stays the origin and the default. Every Cloudflare piece is an opt-in layer a site owner adds in front of or beside it: edge rules on a proxied custom domain, a Worker on `/api/*` or its own subdomain, and storage behind that Worker. Removing a layer returns the site to plain GitHub Pages behaviour; the theme never needs Cloudflare to build or to work.
- **Three tiers.** *open*: no payment method on the Cloudflare account; over-limit use fails instead of billing. *free*: a payment method is on file but usage stays inside the free allowances, with caps in code where Cloudflare only alerts. *paid*: the design names its cost drivers and a monthly estimate. Every item states the lowest tier it works in and what a lower tier loses.
- **Presets.** Named bundles of layers per tier: `edge-basic`, `open-docs`, `open-blog` (open), `free-community` (free), `paid-product` (paid). The theme reads only per-layer keys under `modootoday.cloudflare` (`endpoint`, `feedback`, `forms`, `turnstile`, `og`, `downloads`); a preset name is a label for docs and starters and never changes output by itself.

1.8.0 adds:

- **CF-E1** CSP and security headers as real HTTP headers through a Response Header Transform Rule, with `modootoday-check --csp-policy` printing the policy the site's config needs (open).
- **CF-E0** An edge hygiene checklist: the Cloudflare features that inject scripts or rewrite HTML stay off (open).
- **CF-E3** Cache rules for versioned assets, `sw.js` and the manifest bypassing the edge cache, and a purge step in the starters' deploy (open).
- **CF-W3** A Worker Cron Trigger that requests rebuilds, since scheduled workflows stop after 60 days without repository activity (open).
- **CF-E4** A `Speculation-Rules` response header, so B5 works under a strict CSP (open; with B5).
- **CF-E2** `modootoday-stubs --redirects=csv` for Cloudflare Bulk Redirects, with the redirect stubs kept as the fallback (open).
- **CF-W1** "Was this page helpful?" stored by the site in a Worker and D1 through no-script forms; without the key, the 1.7 prefilled-issue links remain (open).
- **CF-W2** Contact and subscribe forms posting to the Worker, a honeypot by default and Turnstile only as an opt-in key; double opt-in mail needs *paid* (open / paid).
- **CF-J1** With J1 (stretch): an `og-card` layout rasterised at build time, or by a Worker with cached browser screenshots (open / paid).
- **CF-R3** Optional: download links through the Worker with a counter, for R3 (open).

ADRs that come first: the companion packaging and edge endpoint contract (one companion repository, one Worker whose modules turn on by their bindings, rule files, D1 schema, versioned under the public API policy), before CF-W1, CF-W2, CF-W3, CF-R3 and the redirect CSV format; forms and Turnstile privacy; and the web push endpoint contract (CF-P1). The push contract is written in 1.8; the theme's push client ships in 1.9, so the same service worker does not take two new features in one release. CF-E0, CF-E1, CF-E3 and CF-E4 need nothing beyond this record.

Later: Access in front of the companion's admin routes, a CSP report collector, server-side search, image transformations, view counts, an R2 release mirror, reactions. Rejected: moving hosting to Cloudflare Pages or Workers (an alternative only), Zaraz, the Web Analytics beacon by default, self-hosted comments, a runtime Releases proxy, Workers AI translations or summaries, Durable Objects counters, link checking at the edge, Snippets, and Access for "private docs" (the `github.io` URL and the public repository expose the same content).

The theme's own docs run on a `github.io` host, which Cloudflare cannot proxy, so the edge layers (and redirects for moved docs pages) reach the docs only if they move to a custom domain; that is a separate maintainer decision.

## Amendment (2026-11-09): governance, docs drift and changelog items

From [[research:modootoday/20261109150011]], by the same maintainer decision that extended 1.7.0:

- **B10** Install version pins are excluded from a translation's `source_rev` hash, with one restamp under an amendment of the ADR on page languages. Without this, every release marks the install and home translations stale.
- **B11 strict** After B10, staleness fails the release check for en, ko and ja. Both land before D1 ("translation may be outdated"), which would otherwise fire on every release.
- **B8, B9** A generated configuration reference table, and a test that every `modootoday-check` and `modootoday-stubs` flag appears in the docs.
- **C6** The Upgrade guide is fed by changelog fragments marked `migration:` or `public_api: true`.
- **A8** A `Decision:` trailer on commits that touch governed paths, after a report-only trial late in 1.7.
- **A3** `AGENTS.md` for the checker and system-audit directories.
- **B13** A "last verified" report, alongside C2's git-based "Last updated".
- **C7** A richer GitHub Release body, if 1.7 did not ship it.

Later: a Conventional Commits lint, prose linting, an entry-length guideline, git-cliff as a drafting helper, and CODEOWNERS once there is a second maintainer.

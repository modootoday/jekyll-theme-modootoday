---
id: adr:modootoday/20261109141605
title: "1.8.0 scope: release surfaces, freshness, docs depth and the GitHub-surface items deferred from 1.7"
status: active
created: 2026-11-09T14:16:05Z
updated: 2026-11-09T14:16:29Z
rel:
  governs: [_layouts]
  depends_on: [research:modootoday/20261109141301, adr:modootoday/20261109141321]
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

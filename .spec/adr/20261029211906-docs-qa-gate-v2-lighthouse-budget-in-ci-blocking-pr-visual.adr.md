---
id: adr:modootoday/20261029211906
title: "Docs QA gate v2: Lighthouse budget in CI, blocking PR visual diff without committed baselines"
status: active
created: 2026-10-29T21:19:06Z
updated: 2026-10-29T21:19:06Z
rel:
  governs: [qa]
  supersedes: [adr:modootoday/20261029210930]
---

# Docs QA gate v2: Lighthouse budget in CI, blocking PR visual diff without committed baselines

## Context

The first QA gate kept Lighthouse out of CI because scores vary with runner load, and the visual workflow only reported differences. The 1.0 roadmap requires both to protect the docs site and kitchen sink against regressions. Local runs showed accessibility, best practices and SEO are deterministic at 100, while performance moves by a few points between runs.

## Decision

All deterministic docs-qa checks from the superseded decision stay unchanged. A separate Lighthouse workflow builds docs/ with this checkout's theme, runs qa/lighthouse.sh three times per page and form factor (seven pages, mobile and desktop), and qa/lighthouse-budget.mjs fails the job when a median score is below qa/lighthouse-budget.json: accessibility, best practices and SEO 100; performance 90 on desktop and 80 on mobile. The median of three and the loose performance floor absorb runner variance while still catching real regressions. The visual workflow keeps comparing the base and head builds on the same runner, so no baseline images are committed and qa/visual-baseline/ is git-ignored. It blocks pull requests; an intended change is approved by adding the visual-ok label after reviewing the diff artifact. Pushes to main remain report-only.

## Consequences

Accessibility, best-practice and SEO regressions fail CI; a performance regression fails only when it is large. The performance floor may be tightened once runner variance is measured over more runs. Visual changes need an explicit reviewer decision on pull requests, and the repository carries no platform-specific PNGs. Direct pushes to main are not blocked by visual diffs, so release review still compares the visual artifact.

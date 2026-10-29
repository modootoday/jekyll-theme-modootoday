---
id: adr:modootoday/20261029204503
title: "First public release is 0.5.0, with governance files"
status: active
created: 2026-10-29T20:45:01Z
updated: 2026-10-29T20:45:01Z
rel:
  governs: [jekyll-theme-modootoday.gemspec]
---

# First public release is 0.5.0, with governance files

## Context

Milestones 0.1 to 0.4 were developed but never published. Version numbers in the gemspec, changelog and install snippets had drifted.

## Decision

The first published version is 0.5.0; milestones 0.1 to 0.4 are recorded inside its changelog entry. The gemspec, CHANGELOG and install snippets must agree, enforced by a test. The repository ships SECURITY.md and CODE_OF_CONDUCT.md (Contributor Covenant 2.1) that point only at GitHub private vulnerability reporting, issue and pull request templates, Dependabot for GitHub Actions, Bundler and npm, a RELEASING.md checklist, and a CI job for the Jekyll 3.9 floor. Releases still happen only from tags after owner review.

## Consequences

since: badges that name 0.2 to 0.4 refer to milestones inside 0.5.0.

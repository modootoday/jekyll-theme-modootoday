---
id: adr:modootoday/20261112032809
title: Page feedback links are prefilled GitHub forms with no script and no request until clicked
status: active
created: 2026-11-12T03:28:09Z
updated: 2026-11-12T07:44:29Z
rel:
  governs: [_includes/modootoday/meta/feedback.html, _includes/modootoday/page-meta.html, lib/modootoday/check/config/keys/pages/feedback.rb]
  depends_on: [adr:modootoday/20261109141321, adr:modootoday/20261112023954]
---

# Page feedback links are prefilled GitHub forms with no script and no request until clicked

## Context

G2, C3 and G8 in [[adr:modootoday/20261109141321]]: a docs reader who finds a mistake, or wants to say a page helped, had to find the repository and write an issue from nothing. Feedback widgets usually post to an analytics or form service, which a static GitHub Pages site under a strict CSP should not depend on.

## Decision

- `modootoday.feedback: {issues, helpful, discuss, labels}` adds a second row under the page footer line, `p.mt-page-feedback`. `issues` is `auto` (the repository from `meta/github.html`, never the API-backed `issues_url`), a repository's issues URL, or `false`; `helpful: true` adds "Was this page helpful?" with Yes and No; `discuss` is a plain URL; `labels` are added to the prefilled issues. Front matter `feedback: false` hides the row on one page.
- Every link is a plain `…/issues/new?title=&body=&labels=` URL built at build time with `url_encode`, which both Liquid versions have: the title is the page title, with "Helpful: " or "Not helpful: " before it for the two answers, and the body is the page URL. `rel="nofollow"`, no script, no analytics; nothing leaves the reader's browser until they click, and GitHub asks them to sign in before anything is filed.
- `meta/feedback.html` resolves the values and `page-meta.html` renders them; the row's styles go in the doc-nav sheet, whose cap rises from 896 to 1024 B as planned. Five labels in all 23 catalogs.
- `modootoday-check` checks each sub-key, warns for `helpful: true` without `issues`, and shares the `site.github` warning with `edit_url: auto`.
- The docs site turns it on with its explicit issues URL, `helpful: true` and the label `docs-feedback`, which the operator creates on GitHub. A label that does not exist, or that the reader may not set, is ignored by GitHub.

## Consequences

- Every docs page with chrome gains the feedback row: an intended visual change.
- Risks accepted: spam issues (GitHub's own sign-in and the maintainer's triage), and long titles making long URLs (well under browser limits for page titles).
- Tests: `test/theme/chrome/page_feedback_test.rb` (encoded ko titles, the three links, `feedback: false`, `issues: auto` with a `github:` map and without it, `helpful` without issues) and `test/checker/config/feedback_test.rb`.

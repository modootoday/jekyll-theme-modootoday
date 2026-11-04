---
id: audit:modootoday/20261104182120
title: Visual audit re-run after the flat overhaul
status: active
created: 2026-11-04T18:21:20Z
updated: 2026-11-04T18:21:20Z
rel:
  governs: [_sass]
---

# Visual audit re-run after the flat overhaul

## Scope

A re-run of the 2026-11-03 visual audit (29 findings: 2 blocker, 7 major, 12 minor, 8 polish) after the flat overhaul, on the documentation site built from the commit that closes it ("fix(layouts): three widths for every layout and the reflow failures"), compared with the same checks on the commit before the last six overhaul commits ("ci(visual): build the base with the head's site script"). Both builds use the classic GitHub Pages builder (github-pages 232) with a fixed `time:`.

## Method

- Rendering: Cloudflare Browser Rendering (remote Chrome 152) reaching the locally served build through a short-lived tunnel; no local browser.
- The docs QA page checks (`test/system/audit/pages.mjs`): full-page shots at 360, 768, 1024 and 1440px, horizontal overflow, RTL mirroring, every layout audit that applies (card grids, plan buttons, chip rows, list rows, tabs, inline code, header, anchors, column alignment, measure, code copy, table reflow and four-column table width) and axe (WCAG 2.2 AA), on the 61 English pages, the RTL kitchen sink, the English-only pages and the Korean and Japanese homes, in light and dark: 136 page runs, 544 shots each run.
- The keyboard flows (`test/system/audit/keyboard.mjs`, 12 flows), the reflow checks of the accessibility audit (320px, 200% text at 640px, text spacing at 360px) on nine pages, and the geometry of the API reference's four-column table in English, Korean and Japanese at 768, 1024 and 1440px.
- Not run here: the strict CSP audit (it needs the local server's CSP header), contrast, the first-paint and mobile device passes, forced-colors and reduced-motion shots, Lighthouse and the comparison against the last release (`visual.yml`). They belong to the release check on the deployed site.

## Results

| Check | Before | After |
|---|---|---|
| Failed checks, all pages and schemes | 141 | 75, then 68 after the two follow-up fixes below (rechecked on their pages) |
| Card grids with a card under its floor (16rem features and link cards, 18rem blog cards) | 36 | 0 |
| Pricing rows with one plan beside empty columns | 4 | 0 |
| Paragraphs wider than the measure on wide pages (1440px) | 24 | 0 |
| Four-column tables scrolling at 768 or 1440px | 4 | 0 |
| API component table at 768 / 1024 / 1440px | 817px in 720 / 656 / 720px columns (97 / 161 / 97px of scrolling), tallest cell 16 lines | 720 / 656 / 720px, no scrolling, tallest cell 17 / 20 / 17 lines (Korean 15 / 17 / 15, Japanese 17 / 21 / 17) |
| Reflow failures (company recipe, events directory) | 4 | 0 |
| Keyboard flow failures (12 flows) | 2 (link-card ring) | 0 |

The re-run found two regressions of the overhaul, both fixed in their commits and rechecked: a hero title wider than 312px with the text-spacing override on the configuration page (hero titles now break an overlong word), and status badges whose dot set the flex baseline, so a row of mixed badges in the RTL kitchen sink was 1px off centre (the dot is now positioned outside the flex flow).

Still failing, present before and after (not caused by this work):

- axe `target-size` on the doc sidebar group titles (`.mt-sidebar-title` summaries), 19 pages in both schemes.
- The header-end audit at 390px on a page without search: the trailing controls sit 48px from the end.
- The inline-code wrap audit on the sample post and the agents guide at 360px.
- Table reflow on the kitchen sink and the blog-news index at 320px: a scrolling wrapper not yet labelled when measured, and a three-column table showing 117 to 125px of its last column. These vary between runs and schemes, so they depend on when the labelling script runs.

## Findings

| ID | Severity | Status | Where |
|---|---|---|---|
| TYP-01 | blocker | fixed | type commit; Korean and Japanese hero clip check passes |
| COD-01 | blocker | fixed | code commit |
| TBL-01 | major | fixed | code commit; table audits |
| LAY-01 | major | fixed | doc columns commit |
| HDR-01 | major | fixed | header commit |
| HDR-02 | major | fixed | header commit |
| HDR-03 | major | fixed | header commit; anchor audit passes |
| TYP-02 | major | fixed | layouts commit; measure audit 24 to 0 |
| STR-01 | major | fixed | starters commit; starter chrome test |
| TYP-03 | minor | fixed | type commit |
| RFL-01 | minor | fixed | layouts commit; reflow 4 to 0 |
| COD-02 | minor | fixed | code commit; code-copy audit passes |
| LAY-02 | minor | fixed | doc columns commit; column audit passes |
| LAY-03 | minor | fixed | blog and layouts commits |
| LAY-04 | minor | fixed | components and blog commits; card grid audit 36 to 0 |
| BLG-01 | minor | fixed | components and blog commits |
| MKT-01 | minor | fixed | marketing commit; plan audit 4 to 0 |
| STR-02 | minor | fixed | chrome and starters commits |
| FOC-01 | minor | fixed | doc columns commit; TOC ring flow passes |
| FCM-01 | minor | fixed in CSS, not rendered | components commit; no forced-colors pass in this run |
| ERR-01 | minor | fixed | chrome commit |
| TYP-04 | polish | fixed | type commit |
| HER-01 | polish | fixed | marketing commit |
| CMP-01 | polish | fixed | components commit; link-card ring flow passes |
| CMP-02 | polish | fixed | content and components commits |
| CMP-03 | polish | fixed | code commit |
| CMP-04 | polish | fixed | chrome commit; search tests |
| CMP-05 | polish | fixed | components commit |
| FCM-02 | polish | fixed in CSS, not rendered | marketing commit; no forced-colors pass in this run |

Not yet checked, as before: text-only 200% zoom on real browsers, measured anchor-jump shots, real Mac and Windows fonts, the partially translated languages and the starters at 768px. Forced colors, contrast and CSP move to the release check.

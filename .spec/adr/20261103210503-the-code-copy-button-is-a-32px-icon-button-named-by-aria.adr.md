---
id: adr:modootoday/20261103210503
title: "The code copy button is a 32px icon button named by aria-label, in the title bar or a reserved strip, with a polite status"
status: active
created: 2026-11-03T21:05:03Z
updated: 2026-11-03T21:05:19Z
rel:
  governs: [_sass/modootoday/components/core/inline/_code-copy.scss, assets/js/modootoday/code-copy.js]
---

# The code copy button is a 32px icon button named by aria-label, in the title bar or a reserved strip, with a polite status

## Context

The copy button was a text button ("Copy" with an icon) floating over the top end of the code. From 48rem it covered the end of long first lines; below 48rem a strip was reserved for it. The flat base specifies code blocks at 14/24 with one radius, a 40px title bar and the copy button at its right as an icon. An icon-only button needs an accessible name and a non-visual confirmation, and both must come from the interface catalogs.

## Decision

- `pre` is 14/24 with 1rem padding; its corners and the title bar's come from the hook `--mt-code-radius` (default `var(--mt-radius)`), added to `registry/_hooks.scss`. A `file:` title is a 40px flex bar on the code background, its 12/16 mono text muted; the code's top border is the bar's hairline.
- The button is 32px square (44px on coarse pointers), transparent, filled with `accent` on hover and focus, with a 16px icon. `code-copy.js` names it with `aria-label` and `title` from `data-mt-copy` (`code.copy`) and shows no text. After a copy the icon turns to a check, and a `role=status`, `aria-live=polite` region says `data-mt-copied` (`code.copied`); both reset after 1.5 s, so a second copy is announced again. The accessible name does not change.
- A titled block puts the button in the title bar (`top: -2.25rem` from the code box). An untitled block reserves a 40px strip above the code at every width while scripting is on, before the script runs, so nothing moves after load and the button never covers code; a titled block keeps 1rem.
- Diff lines are blocks: Rouge keeps the newline inside each `.gi`/`.gd` span, so inline blocks put added and removed lines side by side.
- Inline code is a chip on the `accent` fill with a 1px border and `0 .25rem` padding. Its wrapping (`overflow-wrap: anywhere`) is unchanged here: inline code in table cells is left to the table work.

## Consequences

`code-copy.js` grows by 69 bytes gzip (918 to 987); no new interface string. Untitled blocks are 24px taller at 48rem and up. Sites that styled the button's text lose it. The docs QA checks at 360, 768 and 1440px that no copy button reaches the text of its block.

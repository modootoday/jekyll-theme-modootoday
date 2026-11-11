---
id: adr:modootoday/20261111002136
title: "Installing is offered by a page section, never by the header or by a prompt the theme starts"
status: active
created: 2026-11-11T00:21:36Z
updated: 2026-11-11T00:22:00Z
rel:
  governs: [_includes/modootoday/markdown/c/install.html, assets/js/modootoday/pwa/install.js]
  depends_on: [adr:modootoday/20261105130236, adr:modootoday/20261110165219]
---

# Installing is offered by a page section, never by the header or by a prompt the theme starts

## Context

An installable site ([[adr:modootoday/20261105130236]]) is offered for installing by the browser, in its own interface: Chromium fires `beforeinstallprompt` when the manifest qualifies and shows an icon in the address bar or menu; Safari installs from Share (iOS, iPadOS) or File, Add to Dock (macOS 14+); Firefox on Android from its menu, Firefox on desktop not at all. A page can only defer Chromium's offer and replay it from a click. The design put an install button in the header. The header is one row at every width ([[adr:modootoday/20261103205338]]) and its controls render at first paint ([[adr:modootoday/20261030083001]]); a control that appears after load, and only in some browsers, would shift that row and could not be tested by the first-paint audit. Remote Chromium also ignores an emulated `display-mode` (the 1.7.0 spike), so a rule that lives only in CSS cannot be checked in a browser test.

## Decision

- **A `c: install` section, not a header button.** The section prints its text, `button.mt-install` with `hidden` (label `pwa.install`) and `p.mt-install-hint` (label `pwa.install_hint`, for browsers that install from their own menu or share sheet). It is a component like any other: `install` in `modootoday.components`, `docs/_data/components.yml` (lead slot), the Page sections group, a RULES §2 row, the kitchen sinks and the Components page. The design's header button and its `install_button` key are dropped.
- **The button shows only while the browser offers installing.** `pwa/install.js` (a module, probe `class="mt-install`, loaded only with `modootoday.pwa.enabled: true` and the component on) listens for `beforeinstallprompt`, calls `preventDefault()` and unhides the button; a click calls `prompt()` once; after the reader's choice or `appinstalled` the button hides again and, if it had focus, focus moves to the hint. The theme never prompts by itself and reads no user agent. Nothing is stored.
- **An early offer is kept by `pwa/register.js`.** Chromium can fire the event before the install module runs. `register.js`, on every PWA page already, listens only on pages that have the button, calls `preventDefault()` there and keeps the event on the manifest link (`mtInstall`), where `install.js` picks it up. It adds a listener, no import and no request, so the rule of [[adr:modootoday/20261110165219]] holds: nothing is fetched through a leaving worker. Pages without the button keep the browser's own install interface unchanged.
- **Hidden in the installed app.** The sheet hides the section under `(display-mode: standalone), (display-mode: minimal-ui)`, and `install.js` does the same from `matchMedia` and `navigator.standalone`, which a test can stub.
- **Files.** The sheet is `assets/css/modootoday/showcase/install.css` with the partial `components/section/showcase/_install.scss`, beside `subscribe`: a section sheet's partial must sit at `components/section/<sheet path>` for `css: bundle`, so the plan's `chrome/` paths are not used.
- **Checker.** An `install` section on a site whose `modootoday.pwa.enabled` is not `true` is a warning: the button never shows there. The docs site gets the warning until it turns the PWA on.
- **Caps** (measured gzip +10 %, rounded up to 128 B): `showcase/install.css` 352 B, cap 512; `pwa/install.js` 842 B, cap 1024; `pwa/register.js` grows from 1,181 B to 1,305 B and stays under its cap of 1408. The core sheet is unchanged.

## Consequences

- A reader in Chromium sees an Install button where the author put the section; other readers see the hint. An installed app never shows the section.
- Installing is never offered in the header, so the first-paint audit and the header row stay as they are.
- `beforeinstallprompt` does not fire in headless browsers, so the button's behaviour is covered by unit tests with a synthetic event; the browser check of the section is the visual run (the hint shown, the button hidden).

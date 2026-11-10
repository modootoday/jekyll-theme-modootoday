---
id: adr:modootoday/20261110165219
title: The update notice appears only when the theme's files changed; deploys of pages alone activate silently
status: active
created: 2026-11-10T16:52:19Z
updated: 2026-11-10T16:52:45Z
rel:
  governs: [assets/js/modootoday/pwa, _sass/modootoday/pwa, _includes/modootoday/pwa/head.html]
  depends_on: [adr:modootoday/20261110133153, adr:modootoday/20261109141321]
---

# The update notice appears only when the theme's files changed; deploys of pages alone activate silently

## Context

[[adr:modootoday/20261110133153]] ships a service worker whose `sw.js` changes on every deploy, so browsers always find the new worker; until now it waited, unannounced, until no page of the site was open. A worker that waits is invisible: a reader with an installed app open for days keeps the old one. Prompting on every deploy would be worse: docs sites deploy content many times a day, and a notice each time teaches readers to dismiss it. Pages are fetched from the network first, so a deploy that changes only pages needs no new worker to be seen; only new theme files (the worker's cache-first assets) do. An automatic reload is not an option either: it loses what a reader typed and moves them on the page. [[adr:modootoday/20261109141321]] adds E1 to this step (an open window checks for a new `sw.js`).

## Decision

- **Silent when the theme files are the same.** In `install`, a worker whose assets cache (`mt:<scope>:assets:<assets>`) already exists calls `skipWaiting()` and takes over at once; `clients.claim()` on activate moves open pages to it without a reload. With the default `asset_version: theme` that is every deploy that does not update the theme; with `build` or `false` every deploy changes the assets version and shows the notice (documented).
- **A notice when they changed, never a reload by itself.** A new worker opens its assets cache at the start of `install`, so while it waits there are two assets caches of the scope. `pwa/register.js` watches the registration (a waiting worker at load, and `updatefound` until `installed`) on controlled pages and imports `pwa/update-toast.js`, which shows the notice only when two assets caches exist. Reload posts `mt:skip` to the waiting worker and reloads once on `controllerchange`; Later and `Esc` close it. "Never notify" is not offered: the notice is the only way a reader of an open app learns of a theme update.
- **The notice.** `div.mt-toast[role=status]` at the end of the body, inserted empty and filled after its sheet loads, so screen readers announce the text; it never takes focus, `Esc` closes it unless a component already handled the key, buttons are at least 24 px, it sits above the bottom safe area with inverted colours and transparent borders for forced colours, and it does not move. Labels (`pwa.update`, `pwa.reload`, `pwa.later`) and the sheet URL reach the module through `data-*` attributes on the manifest link, so `csp: strict` needs nothing new. Nothing is stored.
- **Its files.** `assets/css/modootoday/chrome/toast.css` is a fixed sheet with the partial `_sass/modootoday/pwa/_toast.scss`, outside `components/`: it is not a component a site turns off with `modootoday.components` (every partial there names one, adr:modootoday/20261105075436); it follows `modootoday.pwa`. `pwa/update-toast.js` is a fixed import, loaded only when a notice shows. Neither is on any page otherwise, and `css: bundle` does not fold the sheet into the core sheet: the script links it in both modes.
- **E1: an open window asks for a new worker.** When a page becomes visible again more than an hour after the last check, `register.js` calls `registration.update()`. Browsers check on navigations and at most daily on their own, so an app window that is never navigated would otherwise never see an update. All windows do this, not only installed ones: the cost is one conditional request an hour, and Chromium ignores an emulated `display-mode`, so an installed-only rule could not be checked in a browser test.
- **E3: an offline notice through the same module.** When the browser fires `offline` (or reports `navigator.onLine` false at load), a page other than the offline page shows "You are offline. Pages you visited still open." with Close; it closes on `online`. `navigator.onLine` can be wrong (a captive portal counts as online), so the wording is a hint and nothing depends on it; it never replaces a waiting update notice. The notice's sheet and module are precached, so it is styled offline. Labels `pwa.offline_notice` and `pwa.close`.
- **Caps** (measured +10 %, rounded up to 128 B): `pwa/register.js` 990 B, cap 768 to 1152; `pwa/worker.js` 2,003 B, cap 2048 to 2304; `pwa/update-toast.js` 1,094 B, cap 1280; `chrome/toast.css` 481 B, cap 640. A PWA page carries register.js only (about 350 B more than before this step, for the notice, E1 and E3); the notice's files load when it shows.

## Consequences

- A content deploy reaches an open page's worker within seconds of the browser's update check, with no notice; the pages cache is kept, since it follows the theme files too ([[adr:modootoday/20261110133153]], amendment).
- A theme update shows one notice per page until the reader reloads or every page of the site is closed. The fixture flow `features/pwa/update.mjs` checks both paths on builds `v2` (another build) and `next` (another theme version).
- A worker installed by 1.7.0 before this step still waits on a content deploy once: the change reaches readers with the deploy that ships it.

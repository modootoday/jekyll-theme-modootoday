---
id: research:modootoday/20261109141301
title: "Feature extensions for 1.7.0: themes surveyed, notifications and push, GitHub surfaces and Releases"
status: active
created: 2026-11-09T14:13:01Z
updated: 2026-11-09T14:13:01Z
rel:
  governs: [_layouts]
---

# Feature extensions for 1.7.0: themes surveyed, notifications and push, GitHub surfaces and Releases

Date: 2026-11-09. Base: the theme at v1.6.0 (main), the 1.7.0 plan (PWA manifest, service worker, offline and update QA, update toast, install section, docs enable; event ticket price keys; component order), the design notes and the theme .spec audits. Read-only research: nothing was edited, built, tested or opened in a browser.

Scope grew three times during the task (operator): (1) a section on browser notifications / web push and GitHub public
surfaces, (2) no cap on candidates, grouped by theme area, with a rejected table, (3) a separate group for GitHub
Releases and related release surfaces. All three are covered below (groups F, G, R).

Byte figures are estimates (gzip), made by analogy with registry rows of similar size (`banner` 384, `share` 640,
`doc-nav` 896, `toast` est. 330). A real cap is measured +10 % rounded up to 128 B (adr 20261104053146).

---

## 0. Summary

**Recommended for 1.7 (core; all S, no core-sheet bytes, no rule change, each complements the PWA/update theme or
closes an audit minor):**

| Rank | ID | Extension | Est. bytes | Where |
|---|---|---|---|---|
| 1 | E1 | Check for a new version when an installed app returns to the foreground (fold into 16a) | +60 B JS | `pwa/register.js` |
| 2 | A1 | Heading anchor links, no script | ~200 B CSS | new component row `anchor` (cap 256) |
| 3 | F6 | Feed discovery and a Subscribe link on tag, category, author and blog pages | ~80 B CSS | blog sheet |
| 4 | F7 + R4 | Atom feed from the `changelog` layout, plus the GitHub `releases.atom` as an alternate link | 0 B CSS | `layout: feed` source mode |
| 5 | G1 | `edit_url: auto` derived from `site.github` on classic Pages | 0 B | Liquid |
| 6 | G2 + C3 + G8 | Page footer links: "Report an issue" (prefilled), "Was this page helpful?" as two prefilled links, optional "Discuss" | ~100 B CSS | `doc-nav` sheet |
| 7 | A12 + A13 | Audit V2 (`min_width` on a diagram entry) and V1 (per-language diagram entries, docs) | ~60 B CSS | `figure` sheet |
| 8 | A5 | Opt-in print sheet (`media="print"`, never render-blocking) | ~640 B CSS | new `chrome/print.css` (cap 768) |
| 9 | F10 + R6 + G6 | Recipe "Tell readers about updates" + `on: release` and scheduled rebuild in the starters' Pages workflow | 0 B | docs, starters |

**1.7 if capacity remains (S, independent, can slip without harm):** G3 (built-from-commit link), R2 (latest-release
banner from `site.github`), J2 (Open Graph image fallback, `og:image:alt`, size), L1 (internal link and anchor check in
`modootoday-check`), E3 (offline notice through the 16a toast), E9 (manifest `shortcuts` and `screenshots`).

**1.8 headline candidates:** R1 (releases page/section from GitHub Releases), R3 (download tables from release assets
with SHA-256 digests), C2 (last updated from git), A3 (code line highlighting), B2 (search hits on headings), A2
(image zoom without script), G4 (contributors), G7 (comments behind a click-to-load facade), E2 (save a page for
offline), B5 (speculation rules), R5, R7, D1, L2, G5, J1.

**Later (1.9 / 2.x):** C1 + R8 (versioned docs), F1/F4 (web push, needs a site-owned endpoint), F5, R11 (attestations
display), B4 (command palette), J3, L3, D2.

**Not recommended:** see §6 (picture/dark images, collapsible or custom alerts, local notifications on update, a
`version.json` poller, runtime fetch of `releases.atom`, CI badges, auto language redirect, and others).

---

## 1. What the theme already has (inventory, v1.6.0)

- **Content:** 5 GitHub alerts, sections with ~25 components (cards 2/3/4, CTA, tabs, badges, kbd, accordion, steps,
  timeline, figure, tables with stack/dl variants and filter, code with copy, `File:` titles, diff, terminal chrome,
  progress, embeds, loading/skeleton, filetree, details, FAQ, params, chart, widget, link cards, quote, gallery with a
  no-script `:target` lightbox, pricing, subscribe, split), scroll reveal, bleed bands, static Mermaid SVGs and static
  MathML, KaTeX/Mermaid loaders, Chart.js charts (site's copy).
- **Layouts:** ~48 (docs, blog/news, directory, detail incl. event/job/episode, marketing incl. `download`, documents
  incl. legal/resume, docs extras incl. `changelog`, `reference`, `roadmap`, `glossary`, `course`, `book`; system pages).
- **Navigation/search:** one-row header, menu sheet, sidebar, "On this page", breadcrumb, previous/next, header search
  loaded on first use (`/`, Ctrl/Cmd+K, highlights, NFC, CJK single char), list/table filter, back-to-top, banner.
- **Docs tooling:** "Edit this page" (`edit_url`), "Last updated" from front matter `last_modified_at`, page actions
  (View as Markdown, Copy page, Copy for AI), twins, `llms.txt`/`llms-full.txt`, URL aliases, records (pages from data),
  `--byte-exact`, component registry checks.
- **i18n:** 23 UI catalogs, RTL, `hreflang` with `x-default`, translations beside sources, `ref:`, `source_rev`
  checks, English fallback notice for untranslated pages, per-script font stacks.
- **SEO:** canonical, Open Graph (`image`, `og_image`), Twitter card, JSON-LD (FAQ, DefinedTerm, nested checks),
  per-language Atom feeds via `layout: feed` (already filterable by `tag`/`category`, `feed_lang`), optional
  jekyll-feed/jekyll-sitemap.
- **Delivery:** split CSS with per-file gzip caps, ES modules, `?v=` asset versions (`theme`/`build` from
  `site.github.build_revision`), strict CSP mode, token bridge, `site_css`, `preload`, `scripts`.
- **Print:** only some layouts (resume, legal, docs-extra, detail, directory presets, tables, SVG figures) have
  `@media print` rules; there is no site-wide print sheet.
- **Planned 1.7:** T (event ticket price), 15a manifest, 15b service worker + offline page (which already lists cached
  pages) + kill switch, 15c QA fixtures, 16a update toast, 16b `c: install`, 16c docs enable, component-order canon and
  recipes sidebar regroup (adr 20261109124854).

What is absent (checked by grep): heading anchor links, a site-wide print sheet, image zoom outside `c: gallery`, code
line highlighting, version switcher, feedback widget, "report an issue" link, any use of `site.github` beyond
`build_revision`, feed discovery on tag pages, a changelog feed, `og:image:alt`/size tags, link checking.

---

## 2. Survey of comparable themes and frameworks

| Project | Features users value that are relevant here | Source |
|---|---|---|
| Just the Docs | `heading_anchors` (default on), custom callout types, `gh_edit_link`, `last_edit_timestamp` (front matter), lunr search with heading level, previews, focus key | https://just-the-docs.com/docs/configuration/ |
| Minimal Mistakes | skins, `read_time`, comments (giscus, utterances, Staticman, Discourse), share, related, breadcrumbs, lunr/Algolia/Google search, `atom_feed`, `og_image` + `og_image_alt`, tag/category archives | https://mmistakes.github.io/minimal-mistakes/docs/configuration/ |
| Chirpy | built-in PWA (offline cache), prompts (tip/info/warning/danger), LQIP, light/dark image variants, image size/position/shadow, captions, Mermaid, MathJax, media embeds, TOC, comments, pinned posts | https://chirpy.cotes.page/posts/write-a-new-post/ |
| al-folio | `enable_medium_zoom` (image zoom), `enable_progressbar`, back to top, giscus, related posts, publication badges, newsletter, last updated, repo trophies | https://github.com/alshedivat/al-folio/blob/main/_config.yml |
| Beautiful Jekyll | RSS in footer, `edit_page_button`, share links, comments (giscus, utterances, Staticman, Disqus), analytics | https://github.com/daattali/beautiful-jekyll/blob/master/_config.yml |
| Docsy | version dropdown and archived-version banner, "Print entire section", "Was this page helpful?", last modified linked to commit, scroll spy | https://www.docsy.dev/docs/adding-content/navigation/ , https://www.docsy.dev/docs/adding-content/print/ , https://www.docsy.dev/docs/adding-content/feedback/ , https://www.docsy.dev/docs/adding-content/versioning/ |
| Docusaurus | versioning (`versioned_docs`, `versions.json`, unreleased/unmaintained banners, `docsVersionDropdown`, keep < 10 versions), blog feeds RSS/Atom/JSON, `showLastUpdateTime` (needs full git history), `editUrl`, line highlighting by magic comments, PWA plugin, `onBrokenLinks`/`onBrokenAnchors` | https://docusaurus.io/docs/versioning , https://docusaurus.io/docs/api/plugins/@docusaurus/plugin-content-blog , https://docusaurus.io/docs/markdown-features/code-blocks , https://docusaurus.io/docs/api/plugins/@docusaurus/plugin-pwa , https://docusaurus.io/docs/api/docusaurus-config |
| Starlight | `lastUpdated` from git (default), `editLink`, `markdown.headingLinks` (default on), Pagefind search, Expressive Code (frames, markers), component overrides, pagination, `credits` | https://starlight.astro.build/reference/configuration/ |
| MkDocs Material | social cards (generated OG images), privacy plugin (self-hosts external assets), offline plugin, tags, blog, versioning via mike, "Was this page helpful?", announcement bar, comment system, repository info (stars/forks), git revision dates, admonitions incl. collapsible, code annotations and line highlighting | https://squidfunk.github.io/mkdocs-material/setup/ |
| Hugo PaperMod | reading time, TOC, breadcrumbs, share buttons, code copy, cover images with `srcset`, Fuse.js search page, archives, "Suggest Changes" edit link, scroll-to-top, comments partial, RSS | https://github.com/adityatelange/hugo-PaperMod/wiki/Features |

Pattern: every documentation framework surveyed has heading anchors, edit links and git-based "last updated"; most
have a feedback prompt and line highlighting; the large ones have versioning. Blog themes converge on comments, share,
reading time, feeds and image zoom. Only Chirpy, Docusaurus (plugin) and Material (offline plugin) do offline/PWA, which
1.7 adds.

---

## 3. How candidates were judged

- **Value:** who asks (docs readers, blog readers, product sites, maintainers) and evidence from §2.
- **Fit:** classic Pages (github-pages 232 / Jekyll 3.10, Liquid only, allowed plugins) and Jekyll 4; `remote_theme`;
  strict CSP (`script-src 'self'`, `style-src 'self'`, no inline); no third-party request by default; byte caps and the
  core sheet untouched (~393 B headroom is reserved); opt-in config; 23 languages and RTL; axe 0, keyboard, reduced
  motion, forced colours; md-components v1 body rules (raw HTML, IAL, abbreviations are forbidden).
- **Effort:** S ≤ 1 day, M 2-5 days, L > 1 week (including 23 catalogs, checker rules, docs en/ko/ja, tests on three
  stacks).
- **1.7 admission rule:** S effort, complements the PWA/update work or closes an open audit minor or a gap every peer
  has, needs no new rules version, and does not touch files that 15a-16c are changing at the same time (or folds into
  one of them cleanly). Everything else is 1.8 or later.

Field key per candidate: **Value** · **Fit** (Pages / CSP / bytes and sheet) · **Effort** · **Risk** · **Overlap**
with 15a-16c · **Release**.

---

## 4. Candidates by theme area

### A. Content and components

**A1. Heading anchor links (no script).**
Value: high; deep links into long docs and posts; default-on in Just the Docs and Starlight, standard in Docusaurus
and Material. Fit: Pages O (Liquid post-processing of kramdown's `<h2 id>`; the markdown pipeline already rewrites
alerts and sections), CSP O (no script, no inline), bytes ~200 B CSS in a new component row `anchor` triggered by
`class="mt-anchor"` (cap 256), 1 i18n key ("Link to section: [name]") x 23. Use the accessible pattern: the link
follows the heading text, not inside it, with a visible focus state and always visible on `pointer: coarse`. Twins
unchanged (bodies are source). TOC and search must strip the anchor text. Effort S. Risk: the `##` section split and
the TOC parser read headings, so tests must cover both; RTL position (logical properties). Overlap: none; helps offline
links. Release: **1.7**. A copy-to-clipboard variant can reuse `share.js` later.

**A2. Image zoom without script.**
Value: medium (screenshots in docs; al-folio medium-zoom, Chirpy, Material glightbox). Fit: an image wrapped in a link
to itself, `[![alt](shot.png)](shot.png)`, is plain GFM; the theme turns it into the `:target` lightbox `c: gallery`
already ships. Pages O, CSP O, ~250 B CSS in the `figure` sheet or a `zoom` row. Effort M (focus return and Escape need
the gallery's pattern; `:target` changes history). Risk: back-button history entries; large images on phones.
Overlap: none. Release: 1.8.

**A3. Code line highlighting (and optional line numbers).**
Value: high for docs (benchmark gap #5/#11; Docusaurus, Starlight markers, Material `hl_lines`). Fit: a code-span line
before the fence, ``Lines: 2,4-6``, mirroring the existing ``File:`` title, so GitHub shows a harmless line; Liquid
splits the Rouge output by newline and wraps marked lines. Pages O, CSP O, ~150-200 B in `code.css` (cap 1408; measure
headroom) or a `code-lines` row. Effort M (Rouge spans that cross lines, diff and terminal interplay). Risk: an additive
rules change (md-components v1.x row). Overlap: none. Release: 1.8.

**A5. Opt-in print stylesheet.**
Value: medium; Docsy prints whole sections; offline readers save pages as PDF; legal/resume already print well. Fit:
`modootoday.print: true` links `chrome/print.css` with `media="print"` (not render-blocking; fetched at low priority);
hides header, sidebar, TOC, page actions, toast, install section, showcase, banner; opens accordions and shows every tab
panel; prints external link URLs after the link text; avoids breaks inside figures, code and alerts; black on white.
Pages O, CSP O, ~640 B (cap 768), core 0. Effort S. Risk: tabs/accordion open state needs CSS only (`details` cannot be
opened by CSS: print shows summaries only unless the layout duplicates; document the limit or add a 100 B `beforeprint`
handler in the accordion module). Overlap: must hide the 16a toast and 16b install section. Release: **1.7**.

**A6. Reading progress bar (CSS only).**
Value: low-medium (al-folio `enable_progressbar`). Fit: `animation-timeline: scroll()` inside `@supports` and
`prefers-reduced-motion: no-preference`, `aria-hidden`, ~150 B in the blog sheet. Effort S. Risk: decorative only;
forced colours. Overlap: none. Release: later (1.8, low priority).

**A12. Audit V2: a diagram entry sets its minimum width.**
Value: closes a deferred 1.6 minor (10 px text at 360 px). Fit: strict CSP forbids a `style` attribute, so `min_width`
picks one of a few classes (e.g. 24/32/40/48rem) rather than a free value; ~60 B in `figure` sheet; checker validates
the value. Effort S. Risk: none. Overlap: none. Release: **1.7**.

**A13. Audit V1: one SVG pair per language.**
Value: closes the other deferred minor. Fit: the checker already compares each `diagrams:` entry with its own fence;
work is docs (translated fences, `recipes/flow-ko`, `flow-ja`) and a recipe sentence. 0 B. Effort S. Release: **1.7**.

### B. Navigation and search

**B2. Search hits on headings.** Value: medium-high (Pagefind sub-results, Just the Docs `heading_level`). Fit: the
index gains `##`/`###` entries with anchors (needs A1 ids, already from kramdown); `search.json` grows (the 1.5 MB
warning stays); ~100 B JS in `search.js`. Effort M. Risk: index size on big sites; option `search.headings: true`.
Overlap: 15b serves `search.json` stale-while-revalidate. Release: 1.8.

**B3. Search offline.** Value: medium for installed docs apps. Fit: precache `search.json` when small. Decided against
in the 1.7 plan (D7, D9 dropped `search`). Release: revisit in 1.8 with measurements from 16c.

**B4. Command palette search (`<dialog>`, grouped results, recent items).** Value: medium (benchmark #4). Effort L,
~1-2 KB JS. Release: 1.9+.

**B5. Speculation-rules prefetch.** Value: faster navigation in Chromium. Fit: rules must be inline JSON or an HTTP
header (Pages cannot set headers); under strict CSP the site must add `'inline-speculation-rules'` (or a hash) to its
policy, so it cannot be default under `csp: strict`. Interplay with the 15b worker needs measurement. 0 B CSS, ~150 B
HTML. Effort S-M. Risk: extra requests on metered connections (use `eagerness: moderate`). Release: 1.8 (after the
worker has a release in the field). Sources: https://developer.mozilla.org/en-US/docs/Web/API/Speculation_Rules_API ,
https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/script-src

**B10. Keyboard shortcut help (`?`).** Value: low. Release: later/optional.

### C. Docs tooling

**C1. Versioned docs.** Value: high for libraries (Docusaurus, Docsy, Material + mike). Fit: folder snapshots
(`/v1/`, `/v2/`) plus `_data/versions.yml`, a version menu (header is one row: needs a slot, not a new control), an
"older version" banner (reuse `banner`), canonical to the latest page, `noindex` option, `hreflang` per version,
`llms.txt` per version, a worker precache limited to the current version. Pages O for committed snapshots; building tags
needs Actions. Effort L. Risk: header crowding, checker load on copied trees, twin and alias volume. Overlap: 15b
scope/precache. Release: 1.9+ (design first; ties to R8).

**C2. "Last updated" from git.** Value: high (Starlight default, Docusaurus, Docsy, Material). Fit: Jekyll 4: the
theme plugin sets `last_modified_at` from `git log -1 --format=%cI -- <path>` when front matter has none (needs
`fetch-depth: 0`). Classic Pages has no git plugin (`jekyll-last-modified-at` is not in the allowed list,
https://pages.github.com/versions/), so `modootoday-stubs --lastmod` writes `_data/modootoday/lastmod.yml` from a
pre-commit hook or Actions, and `modootoday-check` reports drift. 0 B CSS (page meta exists). Effort M. Risk: shallow
clones give wrong dates; data file churn. Overlap: none (precache unaffected). Release: 1.8. Feeds `dateModified` and
sitemap `lastmod` later.

**C3. "Was this page helpful?"** Value: medium (Docsy, Material, Nextra). Fit: two links, Yes and No, each a prefilled
GitHub issue or discussion URL (or a site `feedback.url`), no script, no analytics, no request until clicked. ~60 B CSS
in `doc-nav`, 3 i18n keys. Effort S. Risk: spam issues (use a label and an issue template). Overlap: none.
Release: **1.7** (with G2).

### D. i18n

**D1. "Translation may be outdated" notice.** Value: medium for multilingual docs. Fit: Liquid compares the
translation's `source_rev`/date with the source page's `last_modified_at` (C2) and shows a note reusing the existing
untranslated-page notice style; 1 key x 23. Effort S after C2. Release: 1.8 (depends on C2).

**D2. Per-language manifests.** Decided later (plan D3). Release: on request.

### E. Performance, offline and PWA complements

**E1. Check for updates when an installed app returns to the foreground.** Value: high for 16a's purpose: a standalone
window can stay open for days, and the browser checks `sw.js` only on navigations and events (at most every 24 h).
Fit: `register.js` calls `registration.update()` on `visibilitychange` to visible, throttled (e.g. once an hour); ~60 B
JS (est. 520 of 640 cap). Effort S. Risk: an extra request per hour per open app; harmless. Overlap: folds into 16a.
Release: **1.7**. Sources: https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/update ,
https://web.dev/articles/service-worker-lifecycle

**E2. "Make available offline" in the page actions menu.** Value: medium (travel reading of a guide). Fit: when
`pwa.enabled`, the existing page actions menu gets an item that asks the worker to cache this page and its resources
(the 15b warm-up message already does this); ~300 B JS dynamic import; 2 keys. Effort M. Risk: storage eviction
(Safari 7 days, plan K15). Overlap: 15b message protocol. Release: 1.8.

**E3. Offline notice.** Value: medium (tells why a page is a saved copy). Fit: `online`/`offline` events show a status
line through the 16a toast module (dynamic import only when offline); ~120 B; 2 keys. Effort S. Risk: `navigator.onLine`
false positives (captive portals); wording must be neutral. Overlap: reuses 16a. Release: 1.7 if capacity, else 1.8.

**E9. Manifest `shortcuts` and `screenshots`.** Value: low-medium; Chromium shows a richer install dialog with
screenshots, shortcuts appear on long-press. Fit: optional `pwa.shortcuts` (or the first N top-level nav items) and
`pwa.screenshots` (site paths, sizes checked). 0 B CSS. Effort S. Risk: plan D2 prefers no new keys; derive shortcuts
from nav. Overlap: 15a manifest. Release: 1.7 if capacity (as a 15a follow-up), else 1.8. Source:
https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Manifest/Reference/shortcuts

### F. Notifications, push and subscriptions (operator scope addition)

**How web push works and why Pages alone cannot send.** A page asks permission after a user gesture
(`Notification.requestPermission()`), subscribes with `pushManager.subscribe({userVisibleOnly: true,
applicationServerKey: <VAPID public key>})`, and gets a `PushSubscription` (an endpoint URL at the browser vendor's
push service plus `p256dh`/`auth` keys). A **server** must store each subscription and later send an encrypted
(RFC 8291) request signed with the VAPID private key (RFC 8292) to that endpoint (RFC 8030); the push service wakes the
service worker, whose `push` handler calls `showNotification()`. GitHub Pages serves static files only: it cannot
receive the subscription (no POST), store it, or hold the private key. Sources:
https://developer.mozilla.org/en-US/docs/Web/API/Push_API , https://web.dev/articles/push-notifications-overview ,
https://datatracker.ietf.org/doc/html/rfc8030 , https://datatracker.ietf.org/doc/html/rfc8292

**Where subscriptions could live without a server of one's own, and the cost:**
- In the repository (an issue, a discussion or a committed file): the browser cannot write there without a token, so a
  reader would paste the subscription by hand, and endpoints become public. With VAPID-bound subscriptions others
  cannot send, but the endpoint still identifies a device at a push service: a privacy leak. Not acceptable.
- A third-party push SaaS: violates the no-third-party default and moves reader data to a vendor. Not acceptable as a
  theme default.
- A tiny site-owned endpoint (a serverless function with a key-value store) that accepts subscribe/unsubscribe; a
  GitHub Actions job `on: release` (or `on: push` to the posts folder, or a schedule) reads the store with a secret token
  and sends with the VAPID private key from Actions secrets. This works and keeps data with the site owner, but it is
  outside what a theme can ship or test, needs CSP `connect-src` for the endpoint, secret rotation, unsubscribe and
  expiry handling (410 Gone), and a privacy notice. Sources: https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions ,
  https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows

**iOS/Safari:** push works from iOS/iPadOS 16.4 only for web apps added to the Home Screen with a manifest `display`
of `standalone` or `fullscreen`, and the permission request must come from a direct user action; the Badging API works
there for Home Screen apps (https://webkit.org/blog/13878/web-push-for-web-apps-on-ios-and-ipados/). Declarative Web
Push (iOS/iPadOS 18.4, macOS 15.5) shows a notification from a JSON payload without a service worker, but still needs
the same sender and store (https://webkit.org/blog/16535/meet-declarative-web-push/).

**F1. Web push for new posts or releases.** Value: medium-high for blogs and product sites, but only for readers who
install the app and allow notifications; notification permission prompts are widely disliked
(https://web.dev/articles/push-notifications-permissions-ux). Fit: the theme could ship only the client half:
`pwa.push: {endpoint, vapid_public_key}`, a `c: notify` section with a subscribe button (never an automatic prompt,
same rule as 16b), a `push` and `notificationclick` handler in `worker.js` (~400 B), and a documented contract for the
site's endpoint. Classic Pages O for the client, CSP needs the site's `connect-src`. Secrets: VAPID private key and
store token in Actions secrets. Effort L (theme) plus the site's endpoint. Risk: high (abuse, unsubscribe, privacy,
abandoned endpoints, worker bugs that outlive rollbacks). Overlap: extends 15b's worker and 16b's section pattern.
Release: 2.x at the earliest, after the 1.7 worker has a release in the field; until then a recipe that points to the
pull-style channels below.

**F2. Local notification on update (no push).** A worker can call `showNotification()` only with permission, and it
runs only while a page of the site is open or an event wakes it; when a page is open, the 16a toast already informs
the reader. Value ~0, cost a permission prompt. Release: rejected (§6).

**F3. Badging API.** `navigator.setAppBadge()` on an installed app (Chromium desktop, iOS 16.4+ Home Screen apps).
Without push or periodic sync the badge only changes while the app is open, so it adds nothing over the page itself.
Release: only together with F1 or F5. Source: https://developer.mozilla.org/en-US/docs/Web/API/Badging_API

**F4. Declarative Web Push.** Same verdict as F1 (needs a sender); revisit with F1.

**F5. Periodic Background Sync to check a feed and set a badge.** Chromium only, installed apps only, frequency set by
site engagement; Safari and Firefox do not support it. ~300 B in `worker.js`. Release: later, experimental at most.
Source: https://developer.mozilla.org/en-US/docs/Web/API/Web_Periodic_Background_Synchronization_API

**Pull-style channels (no server, privacy-first; recommended instead of push):**

**F6. Feed discovery and Subscribe links per tag, category, author and blog.** Value: high-ish for blogs (MM
`atom_feed`, Beautiful Jekyll RSS in footer, Docusaurus feeds, Hugo per-section RSS in PaperMod). The `feed` layout
already filters by `tag`/`category`/language; what is missing is the `<link rel="alternate" type="application/atom+xml">`
on the matching tag/category/author/blog page when its feed page exists, and a visible "Subscribe (Atom)" link. Fit:
Pages O, CSP O, ~80 B CSS in the blog sheet, 1 key x 23; `modootoday-stubs` could plan per-tag feed stubs
(`--feeds`) for classic Pages. Effort S (S-M with stubs). Risk: many tags give many files (opt-in list).
Overlap: 15b treats `feed*.xml` as network only (right). Release: **1.7**.

**F7. Atom feed from the `changelog` layout.** Value: high for product and library sites ("subscribe to updates", the
pull answer to push). Fit: `layout: feed` with `feed_source: <changelog page>` renders one entry per `releases:` item
(version, date, url, Added/Changed/Fixed lists as XHTML content); the changelog page gets the alternate link. Pages O,
0 B CSS, no keys beyond `feed_source`. Effort S-M. Risk: entry ids must be stable (`tag:` URI from site URL + version).
Overlap: none. Release: **1.7**. (A GitHub Releases mode is R1.)

**F8. JSON Feed.** Value: low (Docusaurus offers it; readers mostly take Atom/RSS). Release: later, on request.

**F10. Recipe "Tell readers about updates".** Value: medium; documents the privacy-first ladder: Atom feeds (F6, F7),
GitHub "Watch > Custom > Releases" (https://docs.github.com/en/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/configuring-notifications),
the repository's `releases.atom`, an email form (`c: subscribe` exists), the 16a toast for app users, and why the theme
ships no push. 0 B. Effort S (en/ko/ja). Release: **1.7** (docs; lands with 16c).

**F11. Worker polling `version.json`.** The browser already fetches `sw.js` on navigation and compares bytes, and 15a
puts the build stamp in `sw.js`, so a second version file duplicates the mechanism and adds a request. Rejected.

**F12. Update toast fed by `releases.atom` at runtime.** A browser fetch to github.com is a third-party request,
reveals the reader to GitHub, and is not readable cross-origin unless GitHub sends CORS headers (not observed; verify
in a spike if ever reconsidered). Rejected; use R2 (build time) instead.

### G. GitHub public surfaces (operator scope addition)

What runs where: **classic Pages build** has `jekyll-github-metadata` 2.16.1 on by default (cannot be disabled) and
fills `site.github` (repository URLs, `source` branch/path, `build_revision`, `releases`, `latest_release`,
`contributors`, `public_repositories`, licence) from the API during the GitHub-run build
(https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll ,
https://github.com/jekyll/github-metadata/blob/main/docs/site.github.md). **Jekyll 4 / local builds** need the plugin in
the Gemfile and a token (`JEKYLL_GITHUB_TOKEN`) or they hit the 60 requests/hour anonymous limit; with no network the
values are empty, so every use needs an empty fallback. **Actions** can do anything (gh api, GraphQL) and write `_data`
before building. **Browser** use of GitHub is a third-party request and is excluded by default. Values can also be set
in `_config.yml` under `github:`, which the plugin honours as overrides; that makes offline test fixtures possible
(verify against 2.16.1 in the first commit). Data is frozen at build time: it changes only when the site rebuilds (G6).

**G1. `edit_url: auto`.** Value: high convenience: "Edit this page" with zero config on classic Pages. Fit: Liquid
builds `<repository_url>/edit/<source.branch><source.path>` from `site.github`; empty `site.github` keeps it off.
0 B. Effort S. Risk: sites built from Actions artifacts report a different source; the explicit `edit_url` wins.
Overlap: none. Release: **1.7**.

**G2. "Report an issue" link, prefilled.** Value: medium-high (docs feedback loop; GitHub supports
`/issues/new?title=…&body=…&labels=…&template=…`,
https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-an-issue#creating-an-issue-from-a-url-query).
Fit: `issue_url: auto` (from `site.github.issues_url`) or a URL; body holds the page URL and title; no request until
clicked. ~40 B CSS in `doc-nav`; 1 key. Effort S. Risk: labels must exist or GitHub ignores them. Release: **1.7**
(with C3).

**G3. "Built from commit abc1234" link.** Value: medium for docs freshness and support. Fit:
`site.github.build_revision` (already read for `asset_version: build`) linked to the commit; in page meta or footer,
opt-in. 0-30 B CSS. Effort S. Release: 1.7 if capacity.

**G4. Contributors section `c: contributors`.** Value: medium (community and OSS sites; Material git-committers,
al-folio trophies). Fit: names and profile links from `site.github.contributors` by default; avatars from
`avatars.githubusercontent.com` only with `avatars: true` (third-party images: CSP `img-src`, privacy note), or
committed local avatars. ~200 B section sheet. Effort S-M. Risk: bots in the list (filter by `type`). Release: 1.8.

**G5. Repository stats chip (stars, forks, licence, latest version) at build time.** Value: medium for project
landing pages; replaces shields.io images (third party). Fit: Liquid from `site.github.public_repositories` /
`latest_release`; badge styles exist (0-60 B). Effort S. Risk: numbers stale until rebuild (G6). Release: 1.8.

**G6. Scheduled and event rebuilds (recipe + starters).** Value: keeps G4/G5/R1 data fresh. Fit: an Actions workflow
on `schedule` (cron) and `release: published`; for branch-built sites, a job can request a Pages build
(`POST /repos/{owner}/{repo}/pages/builds`). Scheduled workflows in public repositories are disabled after 60 days
without repository activity (GitHub Docs, events that trigger workflows). 0 B. Effort S. Release: **1.7** (docs and the
starters' `pages.yml`; together with R6).

**G7. Comments (giscus or utterances) behind a click-to-load facade.** Value: high demand on blogs (MM, Beautiful
Jekyll, Chirpy, al-folio, Material). Fit: giscus/utterances load a script and an iframe from their hosts; the site must
widen CSP (`frame-src https://giscus.app`, plus the client script unless vendored) and the reader's IP and referrer
reach giscus and GitHub when it loads. giscus states it collects no data and stores a token in local storage after
sign-in (https://github.com/giscus/giscus/blob/main/PRIVACY-POLICY.md). Theme design: off by default; a button "Load
comments (GitHub)" creates the iframe only on click; ~300 B module + ~150 B CSS; the CSP recipe lists the exact
additions. Effort M. Risk: theming the iframe (giscus supports a theme CSS URL), dark mode sync via `mt:themechange`,
dead discussions. Overlap: none (worker must not cache cross-origin; it does not). Release: 1.8.

**G8. "Discuss this page" link.** Value: low-medium; a link to a Discussions category or search. Fold into C3/G2.
Release: **1.7** (as an option of the same footer row).

**G9-G14** (sponsors button, CI/Dependabot badges, social preview sync, runtime GitHub Atom feeds, jemoji/mentions,
`#123` autolinks): see §6.

### R. GitHub Releases and release surfaces (operator scope addition)

**R1. Releases page or section from GitHub Releases.** Value: high for libraries and apps whose release notes live on
GitHub. Fit (two sources, one renderer): (a) classic Pages: `layout: changelog` with `releases: github` (or a
`c: releases` section) reads `site.github.releases`: `tag_name`, `name`, `published_at`, `prerelease` (badge),
`html_url`, `discussion_url` (R9), and `body` through `markdownify`; (b) Actions: a job writes `_data/releases.json`
with `gh api` (paginated, authenticated with `GITHUB_TOKEN`), which also covers Jekyll 4 and avoids build-time network.
How many releases `site.github.releases` returns (first API page only?) must be measured on 2.16.1. Release bodies are
GitHub Markdown: `@mentions`, `#123` references and "Full Changelog" links stay plain text in kramdown, and raw HTML
passes through, so document trust (maintainer content) and keep strict CSP (inline script would be blocked anyway).
CSS 0 B (reuses `docs-extra` changelog styles). Effort M. Risk: empty data offline (fallback text), rate limits locally,
Markdown dialect differences. Overlap: none with 15-16; feeds R4/F7. Release: 1.8 headline (a short spike in the 1.7
cycle to measure fields, page size and the `github:` override).

**R2. "Latest release" banner or chip from `site.github.latest_release`.** Value: medium ("v2.3 is out, what's new").
Fit: `banner: {release: latest}` fills the existing banner text and link at build time; 0 B CSS; 1 key. No runtime
request. Effort S. Risk: stale until rebuild (R6). Overlap: distinct from the 16a toast (toast = site files changed;
banner = product released). Release: 1.7 if capacity, else 1.8.

**R3. Download tables from release assets.** Value: high for product/download pages. Fit: `download` layout already
renders `downloads: [{label, url, size, checksum}]`; `downloads: github` (or `{release: <tag>}`) maps assets to
`name`, `browser_download_url`, humanised `size` and `digest` (GitHub exposes SHA-256 digests for release assets since
2025-06, https://github.blog/changelog/2025-06-03-releases-now-expose-digests-for-release-assets/); a `platforms:` map
labels files by name pattern. Whether `site.github` on Pages carries `digest` must be checked; the Actions `_data` path
does. 0-60 B CSS. Effort S-M. Risk: no digest on old assets (show nothing, never a fake). Release: 1.8.

**R4. Release Atom as a subscription channel.** Value: medium; zero-cost pull channel. Fit:
`https://github.com/<owner>/<repo>/releases.atom` as a second `<link rel="alternate">` and a visible link on changelog
and download pages; derived from `site.github.repository_url`. No request until a reader's feed reader fetches it.
0 B. Effort S. Release: **1.7** (with F7).

**R5. Release notes as one page per version.** Value: medium (linkable notes, search hits). Fit: existing
`modootoday.records` turns an Actions-written `_data/releases.json` into one page per version on classic Pages (stubs
via `modootoday-stubs --records`); no new theme code for a first version, a recipe shows it. Effort S (recipe), M with a
`release` detail layout. Release: recipe in 1.8, layout later.

**R6. Release-driven rebuilds.** Value: the Releases data in R1-R4 is only as fresh as the last build; a branch-built
Pages site rebuilds on push, not on publishing a release. Fit: starters' `pages.yml` adds `release: {types: [published]}`
next to `push`; the recipe shows the same for custom workflows (https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).
0 B. Effort S. Release: **1.7** (starters + recipe, with G6).

**R7. Starters pick up new theme tags.** Value: medium; Dependabot handles the gem stack (bundler) but not
`remote_theme: owner/repo@v1.6.0`. Fit: a scheduled workflow in rendered starters compares the pin with
`gh api repos/modootoday/jekyll-theme-modootoday/releases/latest` and opens a pull request, or Renovate with a regex
manager. Needs only `GITHUB_TOKEN`. Effort M. Risk: noisy PRs, major-version jumps (limit to the pinned major).
Release: 1.8 (starters).

**R8. Versioned docs snapshots per release tag.** Part of C1: an Actions job builds each kept tag's `docs/` into
`/vX.Y/`. Release: with C1 (1.9+).

**R9. Discussions linked from releases.** `discussion_url` on a release becomes a "Discuss" link in R1. Effort S
inside R1. Release: with R1.

**R10. GitHub's auto-generated release notes vs the theme's CHANGELOG notes.** Recommendation, not a feature: keep
`CHANGELOG.md` (Keep a Changelog, structured `releases:` lists) as the source for the theme's own docs and for sites
that want categories; offer R1 for sites whose source is GitHub Releases; do not parse auto-generated notes into
categories (they group by PR label through `.github/release.yml`,
https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes). Effort:
docs paragraph. Release: with R1.

**R11. Supply-chain display: immutable release, attestations, SBOM.** Value: niche but rising (security-minded product
pages). Fit: an Actions job reads attestations (`gh attestation verify`) and immutable-release state into `_data`; the
download page shows "Verify this download" with the exact command and links; no runtime request. Effort M. Risk: wording
must not overclaim. Release: 1.9+. Sources:
https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases ,
https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds

**R12. A release-aware update toast.** The 16a toast reacts to changed site files; naming the new product version in
it (from `latest_release` baked into `sw.js` constants) is possible but conflates two events. Release: later, only if
asked; R2 covers "a release happened".

### J. SEO and social

**J1. Open Graph images generated at build.** Value: medium-high for blogs and docs (Material social cards). Fit:
classic Pages cannot rasterise; a site script (like `script/figures/math.mjs`) renders a PNG per page from a theme SVG
template in the site's tooling or Actions, commits `/assets/og/<page>.png`, and the checker reports missing or stale
images by digest. No runtime bytes; the renderer is site tooling, not a bundled dependency. Effort M-L. Risk: font
coverage for 23 languages (CJK, RTL shaping). Release: 1.8-1.9.

**J2. Open Graph polish.** Value: medium, S. `og:image:alt` (from `image.alt`), `og:image:width/height`, and a
fallback to the hero `poster` or post cover before `og_image`; currently only `og:image` and the card type are printed.
0 B. Effort S. Release: 1.7 if capacity.

**J3. Sitemap with `hreflang` alternates and `lastmod`.** `hreflang` is already in the head (either place is valid),
so the gain is small; `lastmod` needs C2. Release: later, after C2.

### K. Accessibility

The 1.5 audit item m10 (search results stay open after Tab) is already fixed in `search-keys.js` (focusout handler);
no open accessibility minors were found beyond V1/V2. Items:

**K5. Accessibility statement template.** Value: low-medium (organisations under the European Accessibility Act or
public-sector rules). Fit: a `legal` page in the company recipe/starter, no new layout. Effort S (docs). Release: later.

### L. Author workflow and checker

**L1. Internal link and anchor check (`modootoday-check --links`).** Value: high, zero runtime cost (Docusaurus
`onBrokenLinks`/`onBrokenAnchors`, MkDocs validation). Fit: Ruby stdlib scan of the built site the checker already
reads: same-site links that 404 and `#fragment` targets that do not exist (A1 makes anchors more linkable). Effort S-M.
Risk: baseurl and alias edge cases; warning level first. Overlap: offline: a broken link is worse offline.
Release: 1.7 if capacity, else 1.8.

**L2. Image checks.** Missing `alt` (GFM `![](x)`), body images without known size (CLS). Warning. Effort S.
Release: 1.8.

**L3. JSON Schema for front matter and `_config.yml`.** Editor completion (VS Code YAML). Effort S-M. Release: later.

### M. Starters

**M1.** The starters' Pages workflow gains `release` and optional `schedule` triggers (R6/G6) in 1.7; the tag-update
pull request (R7) in 1.8. The docs starter demo already turns the PWA on through the overlay (plan D14).

---

## 5. Ranking (all fitting candidates)

Score = value (1-5) + fit (1-5) - effort (S 1, M 2, L 3) - risk (1-3). Ties broken by overlap with 1.7.

| Rank | ID | Extension | Val | Fit | Eff | Risk | Score | Release |
|---|---|---|---|---|---|---|---|---|
| 1 | E1 | Foreground update check | 4 | 5 | S | 1 | 7 | **1.7** |
| 2 | A1 | Heading anchors | 5 | 5 | S | 2 | 7 | **1.7** |
| 3 | G1 | `edit_url: auto` | 4 | 5 | S | 1 | 7 | **1.7** |
| 4 | R4 | `releases.atom` alternate link | 3 | 5 | S | 1 | 6 | **1.7** |
| 5 | F6 | Feed discovery + Subscribe per tag/category/author | 4 | 5 | S | 2 | 6 | **1.7** |
| 6 | G2/C3/G8 | Report issue, helpful yes/no, discuss links | 4 | 5 | S | 2 | 6 | **1.7** |
| 7 | A12/A13 | Audit V2 min width, V1 per-language diagrams | 3 | 5 | S | 1 | 6 | **1.7** |
| 8 | R6/G6/F10 | Release and scheduled rebuilds; updates recipe | 3 | 5 | S | 1 | 6 | **1.7** |
| 9 | F7 | Changelog Atom feed | 4 | 5 | S-M | 2 | 6 | **1.7** |
| 10 | A5 | Print sheet | 3 | 5 | S | 2 | 5 | **1.7** |
| 11 | J2 | Open Graph polish | 3 | 5 | S | 1 | 6 | 1.7 if capacity |
| 12 | G3 | Built-from-commit link | 2 | 5 | S | 1 | 5 | 1.7 if capacity |
| 13 | R2 | Latest-release banner | 3 | 5 | S | 2 | 5 | 1.7 if capacity |
| 14 | L1 | Link and anchor check | 4 | 5 | S-M | 2 | 5 | 1.7 if capacity |
| 15 | E3 | Offline notice via toast | 3 | 4 | S | 2 | 4 | 1.7 if capacity |
| 16 | E9 | Manifest shortcuts, screenshots | 2 | 5 | S | 1 | 5 | 1.7 if capacity |
| 17 | R1 | Releases from GitHub | 5 | 4 | M | 2 | 5 | 1.8 |
| 18 | R3 | Downloads from release assets | 4 | 4 | S-M | 2 | 5 | 1.8 |
| 19 | C2 | Last updated from git | 5 | 3 | M | 2 | 4 | 1.8 |
| 20 | A3 | Code line highlighting | 5 | 4 | M | 2 | 5 | 1.8 |
| 21 | B2 | Search hits on headings | 4 | 4 | M | 2 | 4 | 1.8 |
| 22 | G7 | Comments facade | 4 | 3 | M | 2 | 3 | 1.8 |
| 23 | A2 | Image zoom | 3 | 4 | M | 2 | 3 | 1.8 |
| 24 | G4 | Contributors | 3 | 4 | S-M | 2 | 4 | 1.8 |
| 25 | G5 | Repo stats chip | 2 | 5 | S | 2 | 4 | 1.8 |
| 26 | E2 | Save page for offline | 3 | 4 | M | 2 | 3 | 1.8 |
| 27 | B5 | Speculation rules | 3 | 3 | S-M | 2 | 3 | 1.8 |
| 28 | R7 | Starter tag-update PRs | 3 | 4 | M | 2 | 3 | 1.8 |
| 29 | D1 | Outdated translation notice | 3 | 4 | S | 2 | 4 | 1.8 (after C2) |
| 30 | R5 | Release page per version | 3 | 4 | S-M | 2 | 4 | 1.8 (recipe) |
| 31 | L2 | Image checks | 3 | 5 | S | 1 | 6 | 1.8 |
| 32 | A6 | Reading progress | 2 | 5 | S | 1 | 5 | 1.8 (low) |
| 33 | J1 | Generated OG images | 4 | 3 | M-L | 3 | 2 | 1.8-1.9 |
| 34 | C1/R8 | Versioned docs | 5 | 3 | L | 3 | 2 | 1.9+ |
| 35 | R11 | Attestations display | 2 | 4 | M | 2 | 2 | 1.9+ |
| 36 | B4 | Command palette | 3 | 4 | L | 2 | 2 | 1.9+ |
| 37 | F5 | Periodic sync badge | 2 | 2 | M | 2 | 0 | experimental |
| 38 | F1/F4 | Web push (client half) | 3 | 1 | L | 3 | -2 | 2.x, recipe first |
| 39 | J3, L3, K5, B3, B10, F8, D2, R12 | small or conditional | - | - | - | - | - | later / on request |

The ranking deliberately keeps scores high for small, zero-runtime, privacy-neutral items: the 1.7 release already
carries a service worker, which is the riskiest code the theme has shipped, so 1.7 additions should not compete with it
for review attention or for the shared files of 15b/16a.

## 5a. Recommendation for 1.7, with rationale

- **E1 Foreground update check.** The point of 16a is that readers of an installed app learn about a new version; an
  app window that is never navigated never checks `sw.js`. Calling `registration.update()` when the window becomes
  visible again, at most hourly, makes 16a work for its main audience for ~60 B in `register.js`. It belongs in the 16a
  commit, not a separate one.
- **A1 Heading anchors.** The most universal gap against every docs peer, no script, a ~200 B context row, and it makes
  offline deep links, search-to-section (B2 later) and the link checker (L1) more useful. The one real risk, heading
  parsing in sections/TOC/search, is contained by existing tests.
- **G1 + G2 + C3 + G8 GitHub page links.** Zero-config "Edit this page" from `site.github`, a prefilled "Report an
  issue", a two-link "Was this page helpful?" and an optional "Discuss" give docs sites a feedback loop with no script,
  no analytics and no request until a reader clicks. One footer row in the `doc-nav` sheet (~100 B), ~5 keys x 23.
- **F6 + F7 + R4 Pull-style update channels.** 1.7 is about telling readers that something changed; for people who do
  not install the app, feeds are the privacy-first, server-free answer to push. The `feed` layout already filters by
  tag and category, so the work is discovery links, a Subscribe link, a changelog feed source and GitHub's
  `releases.atom` as an alternate. No CSS beyond ~80 B; nothing runs in the browser.
- **R6 + G6 + F10 Release-aware builds and the updates recipe.** Documentation plus two triggers in the starters'
  workflow: it explains the channels (feeds, watch releases, email form, toast) and why the theme ships no push, and
  keeps build-time GitHub data fresh. It lands with 16c.
- **A12 + A13 Audit follow-ups.** Both were deferred to 1.7 by the 1.6 audit; S each, ~60 B.
- **A5 Print sheet.** Opt-in, never render-blocking, ~640 B in its own file, and it must know about the new toast and
  install section, so it is cheapest to do in the same release that adds them.

**If capacity remains in 1.7:** J2, G3, R2, L1, E3, E9, in that order; each is independent and can move to 1.8 without
touching anything else.

**Defer:** R1/R3 become the 1.8 "release surfaces" headline (spike in the 1.7 cycle: fields, page size, `digest`,
the `github:` override for fixtures); C2 + D1 + J3 form a "freshness" bundle; A3 + B2 a "docs depth" bundle; G7 needs
its own CSP/privacy ADR; C1/R8 versioned docs need a design ADR; web push stays a recipe until a site-owned endpoint
contract is designed (2.x).

## 6. Rejected

| Idea | Reason |
|---|---|
| Light/dark image variants via `<picture>` | raw HTML is forbidden in bodies (RULES §4); GitHub's `#gh-dark-mode-only` fragments are deprecated; `<picture>` follows the system, not the toggle |
| Collapsible alerts, custom alert types (Material, Just the Docs) | GitHub alerts are fixed to five types and do not collapse; new syntax would break md-components v1 portability; `c: details` and `c: accordion` exist |
| Abbreviation tooltips, glossary hover | kramdown abbreviations are forbidden; hover-only text fails keyboard/touch |
| Footnote hover previews | script for little gain; footnotes already link both ways |
| Local notification on update (F2) | needs a permission prompt; the worker only runs with a page open, where the 16a toast already informs |
| Badging API alone (F3) | cannot update in the background without push or periodic sync |
| Worker polling `version.json` (F11) | duplicates the browser's byte check of `sw.js`; an extra request per navigation |
| Toast fed by `releases.atom` at runtime (F12) | third-party request, reader exposed to GitHub, not readable cross-origin without CORS |
| Third-party push service | violates no-third-party default and moves reader data to a vendor |
| Storing push subscriptions in the repository | needs a write token in the browser or manual pasting; endpoints become public |
| CI, Dependabot or shields.io badges rendered by the theme | third-party images; authors can already write a Markdown image (GitHub's workflow badge, https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/monitoring-workflows/adding-a-workflow-status-badge) |
| Syncing GitHub's repository social preview | set only in repository settings (https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/customizing-your-repositorys-social-media-preview); document reusing `og_image` instead |
| Sponsor button feature | the `sponsors` layout and footer data already link GitHub Sponsors; `FUNDING.yml` is outside the site source |
| "Recent changes" from `commits.atom` | runtime third-party fetch; no build-time source on classic Pages |
| jemoji styling by default | emoji images load from GitHub's CDN (third party) |
| `#123` autolinks | github.com does not autolink them in repository Markdown files either, so no portability gain |
| Discussions as build data | needs GraphQL with a token (Actions only); a link (G8) covers the need |
| Automatic language redirect | hurts SEO and user choice; `hreflang` and the language menu already handle it |
| `navigator.storage.persist()` | decided against in the plan (K15) |
| OpenAPI/API renderer | needs a JS renderer or build plugin; `c: params` and `reference` cover static tables |
| `prefers-reduced-data`, text-spacing controls | not shipped in browsers / browser zoom and WCAG 1.4.12 CSS already cover it |
| PR preview deploys | GitHub Pages has no preview environments; outside the theme |

## 7. Spikes and checks before committing

1. `site.github` on github-pages 232 (jekyll-github-metadata 2.16.1): number of `releases` returned, presence of
   `assets[].digest`, `discussion_url`, `source.branch/path` on project and user sites, and whether `_config.yml`
   `github:` overrides work for offline fixtures (R1, R3, G1, G2).
2. Whether a branch-built Pages site rebuilds on `release: published` without a workflow (expected: no) (R6).
3. Heading anchors: kramdown id generation for CJK and RTL headings on Jekyll 3.10 vs 4 (A1).
4. Print: which existing `@media print` rules conflict with a site-wide print sheet (A5).
5. Measure the `doc-nav`, `figure`, `code` and blog sheets' current gzip vs caps before assigning bytes.

## 8. Sources

- Jekyll on GitHub Pages: https://pages.github.com/versions/ , https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll , https://github.com/jekyll/github-metadata/blob/main/docs/site.github.md , https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages
- Themes and frameworks: URLs in §2.
- Web platform: https://developer.mozilla.org/en-US/docs/Web/API/Push_API , https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API , https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/showNotification , https://developer.mozilla.org/en-US/docs/Web/API/Badging_API , https://developer.mozilla.org/en-US/docs/Web/API/Web_Periodic_Background_Synchronization_API , https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/update , https://developer.mozilla.org/en-US/docs/Web/API/Speculation_Rules_API , https://web.dev/articles/push-notifications-overview , https://web.dev/articles/push-notifications-permissions-ux , https://web.dev/articles/service-worker-lifecycle , https://webkit.org/blog/13878/web-push-for-web-apps-on-ios-and-ipados/ , https://webkit.org/blog/16535/meet-declarative-web-push/ , RFC 8030/8291/8292.
- GitHub: issue URL queries, notifications (watch releases), Actions events and secrets, automatically generated release notes, immutable releases, artifact attestations, release asset digests changelog, workflow status badge, social preview (URLs inline above); giscus privacy policy.

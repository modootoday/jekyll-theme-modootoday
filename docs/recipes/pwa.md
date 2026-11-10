---
nav_order: 29
title: Installable site
description: Let browsers install the site as an app and keep it readable offline, with a manifest built from the settings you already have and a service worker.
---
# Installable site

`modootoday.pwa` turns a site into a web app that browsers can install: Chrome, Edge and Android show an install button, and iOS and macOS Safari add it to the Home Screen or the Dock with the site's own name and icon. The theme builds the web app manifest from settings you already have, so you name nothing twice, and a service worker keeps the theme files and the pages a reader visited for reading offline. The setting is off by default; a site without it builds exactly as before.

## Turn it on

```yaml
modootoday:
  favicon: brand
  pwa:
    enabled: true
    short_name: Docs   # the name under the icon; keep it to 12 characters
```

A remote theme cannot add files to the root of your site, so a few small files live in your repository. Write them with the stub writer that comes with the gem:

```sh
modootoday-stubs . --pwa           # list what it would write
modootoday-stubs . --pwa --write   # write the files below
```

| File | What it is |
|---|---|
| `manifest.webmanifest` | the web app manifest |
| `sw.js` | the service worker. It sits at the root of the site (with your `baseurl`), because a worker serves only the pages under its own folder. |
| `offline.md` | the offline page at `/offline/`, and `offline.<lang>.md` at `/<lang>/offline/` for each language in `modootoday.full_languages` |

Each file holds only front matter and one include, or front matter alone; commit them. Every page then links the manifest with `<link rel="manifest">` and loads a small script that registers the worker. Build the site and run `modootoday-check . _site`: it checks the settings, that the files are there and current, the built manifest, its icons, the link on every page, the worker and the pages it keeps.

The writer never deletes these files and never overwrites a file of your own at the same path; it stops with exit code 3 instead.

## What goes into the manifest

| Manifest field | Comes from |
|---|---|
| `name` | `pwa.name`, else the site `title` |
| `short_name` | `pwa.short_name`, else the name. Home screens cut names longer than about 12 characters, and `modootoday-check` warns. |
| `description` | `pwa.description`, else the site `description` |
| `lang`, `dir` | the site's default language (`lang:`) and its writing direction |
| `start_url`, `id` | `pwa.start_url`, a path on your site such as `/guides/` (default `/`), with your `baseurl` in front. It cannot carry a query string, so the app never opens with tracking parameters. |
| `scope` | always the site root with your `baseurl`, such as `/docs/`. It is not a setting. |
| `display` | `pwa.display`: `standalone` (default, a window without the address bar), `minimal-ui` or `browser` |
| `theme_color` | `modootoday.theme_color`, the same color as the browser bar tag: the light value, or the dark one with `color_scheme: dark`. With `theme_color: false` the manifest has none. |
| `background_color` | `pwa.background_color` (a hex color), else the page background: `#ffffff`, or `#0a0a0a` with `color_scheme: dark` |
| `icons` | `pwa.icons`: `brand` (default) or your own list |

## Icons

`icons: brand` uses the theme's mark, the same as `favicon: brand`: a 192 px and a 512 px icon and a 512 px maskable icon, whose mark sits inside the circle that Android may crop. To use your own, list PNG files on your site:

```yaml
modootoday:
  pwa:
    enabled: true
    icons:
      - {src: /assets/icons/app-192.png, sizes: 192x192}
      - {src: /assets/icons/app-512.png, sizes: 512x512}
      - {src: /assets/icons/app-maskable.png, sizes: 512x512, purpose: maskable}
```

- A 192 px and a 512 px icon with purpose `any` (the default) are required: browsers do not offer to install without them.
- A `maskable` icon is recommended. Keep its artwork inside the center circle of 80 % of the width, and fill the whole square with a background.
- `sizes` must match the file. `modootoday-check` reads each PNG's real size from the built site.
- When `favicon` is not `brand` and `icons` is not set, the check warns that the app shows the theme's mark. Set `icons:` to your own, or `icons: brand` to keep it.

The Apple touch icon comes from `favicon`, as before. Safari 16.4 and later read the manifest too.

## Check that browsers can install it

1. Build the site and serve it over HTTPS, or from `localhost`.
2. In Chrome, open the developer tools, then Application, then Manifest. The Installability section lists nothing when the site can be installed.
3. Run `modootoday-check . _site --strict` before you publish.

In a private (incognito) window Chrome always reports that installing is not available. Test in a normal window.

## Offline reading

The worker handles only `GET` requests to your own site inside its scope. Everything else (forms, other sites, embeds, CDNs) goes to the network as before, and a request that fails inside the worker also goes to the network.

| Request | What the worker does |
|---|---|
| A `POST`, another origin, a path outside the site, or a request with a `Range` header (audio, video) | nothing; the browser fetches it as usual |
| Theme files (`/assets/css/modootoday*`, `/assets/js/modootoday*`) | serves the kept copy, else fetches and keeps it |
| Pages | fetches first, so readers see the latest version. Offline, it serves the kept copy, else the offline page of the page's language; on a server error (5xx) it serves the kept copy. It keeps only successful responses, at most 50 pages. |
| `search.json` | serves the kept copy and fetches a fresh one for next time |
| Markdown twins, `llms.txt`, feeds, `sitemap.xml`, the manifest and `sw.js` | nothing; always fetched |
| Your own CSS and JavaScript (`site_css`, `scripts`) | fetches first, kept copy when offline |
| Images and fonts | serves the kept copy and fetches a fresh one, at most 60 files |

When the worker installs, it saves the offline pages and the files they link, `start_url`, the paths in `pwa.precache` and the pages whose front matter has `pwa: precache`:

```yaml
modootoday:
  pwa:
    enabled: true
    precache: [/guides/, /reference/api/]   # site paths, no query string
```

Keep this list short: every first visit downloads it. `modootoday-check` fails when a listed page is not in the build and warns when the list is over 1 MiB. The first page a reader opens is not served by the worker yet; once the worker is ready, the page sends it the URLs it loaded, so the site also looks right when the reader starts it offline.

The offline page says the reader is offline, links Try again (it reloads the page they asked for) and the home page, and lists the pages the worker keeps on this device. It is not in the sitemap or the search index.

### Caches, versions and shared origins

The caches are named after the site's path: `mt:<baseurl>/:assets:<version>`, `mt:<baseurl>/:pages:<build>` and `mt:<baseurl>/:media`. Two project sites on the same `<user>.github.io` therefore never touch each other's caches.

- The pages cache is replaced on every deploy: its name carries the theme version and the commit (or the build time).
- The theme files cache follows `modootoday.asset_version` (see [Performance](../../guides/performance/#versioned-asset-urls)): with `theme` (the default) it changes with the theme version; with `build` or `false`, on every deploy.
- A new worker deletes only this site's older caches.

`sw.js` changes on every deploy, which is how browsers find the new worker. If a CDN such as Cloudflare sits in front of your site, keep `/sw.js` out of long edge caching (a cache rule that bypasses the cache for that path); otherwise visitors keep the old worker until the edge copy expires.

## Turn it off

Do not just delete the files: a worker already on visitors' devices would keep serving the old copies. Instead:

1. Set `enabled: kill` and deploy. `sw.js` becomes a worker that deletes this site's caches, removes itself and reloads open pages; the manifest link and the register script are gone.
2. Keep it deployed for a week, so returning visitors pick it up.
3. Set `enabled: false` (or remove `pwa`), then delete `manifest.webmanifest`, `sw.js` and the offline pages.

With `enabled: false` the `sw.js` file still renders the self-removing worker, so turning the setting off without these steps also cleans up; `modootoday-check` warns until you delete the file.

## What stays on the device

Installing adds a shortcut and an app window. The worker stores, in Cache Storage under `mt:<baseurl>/:`, the theme files, at most 50 visited pages and at most 60 images and fonts; it adds no cookies and nothing to `localStorage`. The theme sends nothing anywhere, asks for no push, background sync or persistent storage, adds no analytics and starts no install prompt of its own: the browser decides when to offer installing. A visitor removes the app from the browser's app list or the Home Screen like any other app, and clears what the worker kept by clearing the site's data in the browser settings. Browsers may also clear it on their own (Safari after a few weeks without a visit), so offline reading is best effort.

## Content Security Policy

The manifest is a file from your own site, so a policy with `default-src 'self'` allows it. The worker and the scripts it loads come from your site too. If your policy sets `default-src` to something narrower, add `manifest-src 'self'` and `worker-src 'self'`. See [CSP](../csp/).

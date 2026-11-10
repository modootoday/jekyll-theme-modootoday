---
nav_order: 29
title: Installable site
description: Let browsers install the site as an app, with a web app manifest built from the settings you already have.
---
# Installable site

`modootoday.pwa` turns a site into a web app that browsers can install: Chrome, Edge and Android show an install button, and iOS and macOS Safari add it to the Home Screen or the Dock with the site's own name and icon. The theme builds the web app manifest from settings you already have, so you name nothing twice. The setting is off by default; a site without it builds exactly as before.

## Turn it on

```yaml
modootoday:
  favicon: brand
  pwa:
    enabled: true
    short_name: Docs   # the name under the icon; keep it to 12 characters
```

A remote theme cannot add files to the root of your site, so one small file lives in your repository. Write it with the stub writer that comes with the gem:

```sh
modootoday-stubs . --pwa           # list what it would write
modootoday-stubs . --pwa --write   # write manifest.webmanifest
```

`manifest.webmanifest` holds only front matter and one include; commit it. Every page then links it with `<link rel="manifest">`. Build the site and run `modootoday-check . _site`: it checks the settings, that the file is there and current, the built manifest, its icons and the link on every page.

The writer never deletes this file and never overwrites a file of your own at the same path; it stops with exit code 3 instead.

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

## What stays on the device

Installing adds a shortcut and an app window; the manifest itself stores nothing. The theme sends nothing anywhere, adds no analytics and starts no install prompt of its own: the browser decides when to offer installing. A visitor removes the app from the browser's app list or the Home Screen like any other app.

## Content Security Policy

The manifest is a file from your own site, so a policy with `default-src 'self'` allows it. If your policy sets `default-src` to something narrower, add `manifest-src 'self'`. See [CSP](../csp/).

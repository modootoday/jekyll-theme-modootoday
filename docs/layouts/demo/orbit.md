---
title: Hero module demo
description: "A split hero whose picture a site module script draws over a poster image, the setup of script: and poster:."
twin: false
sitemap: false
edit: false
nav_exclude: true
hero: {c: split, visual: orbit-stage, script: orbit, turn: 12, poster: {path: /assets/images/hero/orbit-960.webp, srcset: "/assets/images/hero/orbit-640.webp 640w, /assets/images/hero/orbit-960.webp 960w", width: 960, height: 960}}
sections: [setup, contract]
---
# Hero module demo

Three dots circle the centre of the picture. A module script of this site draws and turns them over a poster image, which is what you see first and what stays when JavaScript is off or you prefer reduced motion.

[Section visuals](../../../guides/customize/#section-visuals-and-full-width-pages)

## Setup

Register the module once in `_config.yml`, then name it on the hero with a poster:

```yaml
# _config.yml
modootoday:
  scripts:
    orbit: {src: /assets/js/hero/orbit.js, css: /assets/css/orbit.css}
```

```yaml
# front matter
hero:
  c: split
  visual: orbit-stage
  script: orbit
  poster: {path: /assets/images/hero/orbit-960.webp, width: 960, height: 960}
```

Only this page loads `orbit.js`, its sheet and the theme's small helpers it imports. The poster is the page's largest image, fetched first.

## What the module does

- Under reduced motion it stops at once, so the poster stays.
- It draws into the element with the class `mt-visual-stage` from the `orbit-stage` include, which covers the poster.
- After drawing it sets `data-mt-ready` on the visual column, which hides the poster.
- It reads `data-turn` with `readConfig` and follows light and dark with `onThemeChange`.

---
id: adr:modootoday/20261105105733
title: Widgets are site custom elements with a light-DOM fallback shown by :defined
status: active
created: 2026-11-05T10:57:33Z
updated: 2026-11-05T10:57:53Z
rel:
  governs: [_includes/modootoday/markdown/c/widget.html, _includes/modootoday/markdown/inline/widget.html, _sass/modootoday/components/media/_widget.scss]
---

# Widgets are site custom elements with a light-DOM fallback shown by :defined

## Context

Sites moving to GitHub Pages have interactive parts (a calculator, a live status box) that Markdown cannot express. The rules (`md-components v1`) keep a page readable on github.com, in its Markdown twin and without JavaScript; the theme bundles no renderer or widget code (adr:modootoday/20261029212621); the core sheet holds only tokens, base and shell (adr:modootoday/20261104053143); and 1.5.0 already has a registry of the site's own ES modules, `modootoday.scripts`, whose schema accepts `element:`.

## Decision

- **A widget is the site's custom element.** `modootoday.scripts.<name>.element` names the element a module defines. The theme places it and never ships widget JavaScript. The contract for the module: define the element, read `data-props` (JSON), keep the light-DOM fallback, add its own controls after it.
- **Two forms.** A `c: widget` section (params `widget`, required, and `props`) puts `<element class="mt-widget" data-props="{json}">` after the section heading, with the rest of the section inside `div.mt-widget-fallback`. A paragraph holding only `` `widget:<element>` `` puts the element there, with props from front matter `widget_props.<element>` and the i18n sentence `widget.fallback` as its fallback. The inline form converts only an element that a `modootoday.scripts` entry registers, so a 1.5 site's `widget:` code spans build the same HTML; the section names the component itself and always renders.
- **The fallback is shown by CSS, not `<noscript>`.** The `widget` sheet (probed by `class="mt-widget`, born at its 2.0 path `components/media/_widget.scss`) makes the element a block and hides `.mt-widget-fallback` once the element is `:defined`, so a blocked, failed or slow module leaves the text. `:defined` compiles unchanged on Ruby Sass 3.7 (the github-pages stack) and Dart Sass; the widget build test reads the compiled rule on both.
- **Loading follows the element.** `assets/site-scripts.html` adds an entry to the page's modules when the rendered body contains `<element ` or `<element>`, in the same one pass over `site.modootoday.scripts` as `script:`, so the module and its sheet load once and only where the element is (no `site.pages` scan, `script-src 'self'` is enough).
- **Checker.** Errors: a `widget:` line or section `widget:` that no entry registers, props (section or `widget_props`) that are not maps of plain values, a section without a lead paragraph (unless `_data/components.yml` owns the slot contract), an `element` starting with `mt-`, and one element named by two entries. A `widget_props` key no entry registers warns. Existing rules (lowercase with a hyphen, not a name SVG or MathML reserves, `src`/`css` in the build) are unchanged.
- **Budget.** The widget sheet has its own cap in the registry row (measured gzip +10 %, rounded up to 128 B); core is unchanged.

## Consequences

A site adds interactivity with one module and one `scripts` entry, and every reader without the module still gets the section text. Pages without a widget load nothing new. The fallback briefly shows while a module loads; a widget that must avoid that keeps its fallback short or the same size as its controls. Shadow DOM is allowed but the theme only hides the light-DOM fallback, so a module that renders into a shadow root without a slot hides the fallback itself.

---
id: adr:modootoday/20261029201121
title: "Configure the theme through the modootoday: namespace with per-component toggles"
status: active
created: 2026-10-29T20:11:13Z
updated: 2026-10-29T20:11:20Z
rel:
  governs: [_includes]
---

# Configure the theme through the modootoday: namespace with per-component toggles

## Context

A gem theme's own `_config.yml` is not merged into the site, so defaults must live in Liquid.

## Decision

Site `_config.yml` key `modootoday:` (`color_scheme`, `css_layers`, `components`, `nav`, `tokens`, `tokens_dark`, `badges`, `twins`, `llms`); defaults in `_includes/modootoday/config.html`; all P0 components on by default; invalid settings are checker errors.

## Consequences

One documented place for settings; adding a component means adding a toggle and a default.

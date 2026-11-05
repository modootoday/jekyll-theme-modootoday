---
id: adr:modootoday/20261105075436
title: New Sass partials are born at their 2.0 path components/<ns>/_<id>.scss
status: active
created: 2026-11-05T07:54:35Z
updated: 2026-11-05T07:55:35Z
rel:
  governs: [_sass/modootoday/components]
  depends_on: [adr:modootoday/20261104053143]
---

# New Sass partials are born at their 2.0 path components/<ns>/_<id>.scss

## Context

adr:modootoday/20261104053143 keeps the Sass partial paths through 1.x, because they are a shadowing API, and moves every partial to `components/<ns>/_<id>.scss` once, in 2.0. The 1.6 features add new partials. Born at a 1.x-style path, each would be a shadowing name for one minor release and then move with the rest.

## Decision

- **A partial added in 1.x goes straight to `_sass/modootoday/components/<ns>/_<id>.scss`**: `<ns>` is the namespace of the sheet that links it (the folder under `assets/css/modootoday/`) and `<id>` is its component name. The registry row names it as a path part (`media/diagram`), which `assets/imports.html` already resolves under `components/`.
- Existing partials keep their paths until the 2.0 move. Until then `components/` holds both shapes of subfolder; the layout test counts files, not folders.
- The first one is `components/media/_diagram.scss` (static diagrams, adr:modootoday/20261105075445).

## Consequences

No new partial moves twice, and its shadowing path is final from the first release. A reader finds 1.x partials under two kinds of folder until 2.0, when the old ones join the namespaces.

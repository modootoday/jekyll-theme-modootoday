---
title: "API reference demo"
description: "A library reference with a grouped sidebar and a package table."
layout: reference
nav_order: 8
edit: false
sections: []
sidebar: true
packages_title: "Packages"
members:
  - {name: "build", group: "CLI", signature: "modootoday build [--drafts]", text: "Builds the site into `_site`."}
  - {name: "serve", group: "CLI", signature: "modootoday serve [--port N]", text: "Builds and serves the site, rebuilding on change."}
  - {name: "Site.load", group: "Library", signature: "Site.load(path) -> Site", text: "Reads the configuration and pages under `path`."}
  - {name: "Site#render", group: "Library", signature: "site.render(page) -> String", text: "Renders one page to HTML."}
  - {name: "Page#data", group: "Library", signature: "page.data -> Hash", text: "The page's front matter."}
packages:
  - {name: "modootoday-core", version: "1.4.0", text: "Parsing, rendering and the page model.", url: "#", links: [{label: "Docs", url: "#"}, {label: "Source", url: "#"}]}
  - {name: "modootoday-cli", version: "1.4.0", text: "The `modootoday` command.", url: "#", links: [{label: "Docs", url: "#"}, {label: "Source", url: "#"}]}
  - {name: "modootoday-lint", version: "0.9.2", text: "Checks pages against the layout contracts.", url: "#", links: [{label: "Docs", url: "#"}, {label: "Source", url: "#"}]}
---
The sidebar groups members by `group:`; the table lists the packages that make up the library.

> [!TIP]
> Pin the packages to one minor version so the table and the members stay in step.

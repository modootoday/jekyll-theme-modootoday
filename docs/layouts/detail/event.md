---
title: Event demo
image: {path: /assets/images/events/stage.webp, alt: "An empty stage under spotlights facing rows of seats", width: 800, height: 600}
description: An evening meetup about building sites with the theme.
layout: event
nav_order: 4
edit: false
sections: []
starts: "2026-11-20 19:00:00 +0900"
ends: "2026-11-20 21:00:00 +0900"
venue: Hall A
address: 1 Sejong-daero, Seoul
online: "#"
tickets: "#"
schema: {offers: {type: Offer, price: 0, priceCurrency: KRW, availability: "https://schema.org/InStock", url: "https://modootoday.github.io/jekyll-theme-modootoday/layouts/detail/event/"}}
twin: false
---
Two short talks, then questions.

**Admission:** free. Register with the Get tickets button.

This page's front matter, which the [Detail pages](../) guide explains:

```yaml
layout: event
title: Event demo
starts: "2026-11-20 19:00:00 +0900"
ends: "2026-11-20 21:00:00 +0900"
venue: Hall A
address: 1 Sejong-daero, Seoul
online: "#"
tickets: "#"
schema: {offers: {type: Offer, price: 0, priceCurrency: KRW, availability: "https://schema.org/InStock", url: "https://modootoday.github.io/jekyll-theme-modootoday/layouts/detail/event/"}}
```

The `offers` in `schema:` states the same free admission in the page's structured data, with the page as its `url`.

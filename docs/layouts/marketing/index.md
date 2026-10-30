---
title: Marketing pages
description: Feature, pricing, download, brand, link and contact pages with a shared optional stylesheet.
nav_order: 40
---
# Marketing pages

These layouts build the pages around a product: what it does, what it costs, where to get it, how to show it and how to reach you. They load `modootoday-marketing.css` only on their own pages and add no JavaScript. Every layout reads a title, a `description:` (the lead) and optional `actions: [{label, url}]` buttons.

| Layout | Front matter | Structured data | Demo |
|---|---|---|---|
| `feature` | `features: [{title, text}]`, `cta` | WebPage | [Feature](/jekyll-theme-modootoday/layouts/marketing/feature/) |
| `pricing` | `plans`, `currency` | WebPage | [Pricing](/jekyll-theme-modootoday/layouts/marketing/pricing/) |
| `download` | `version`, `date`, `downloads: [{label, url, size, checksum}]` | WebPage | [Download](/jekyll-theme-modootoday/layouts/marketing/download/) |
| `brand` | `colors: [{name, hex}]`, `assets: [{label, url, format}]` | WebPage | [Brand](/jekyll-theme-modootoday/layouts/marketing/brand/) |
| `links` | `image`, `name`, `links: [{label, url}]` | ProfilePage | [Links](/jekyll-theme-modootoday/layouts/marketing/links/) |
| `contact` | `contacts: [{label, value, url}]`, `form: {action, fields}` | ContactPage | [Contact](/jekyll-theme-modootoday/layouts/marketing/contact/) |

For product data, add a `schema:` map (for example `type: SoftwareApplication` with `offers`) and the page prints it as the main entity.

## Pricing

```yaml
---
layout: pricing
currency: $
plans:
  - {name: Free, monthly: 0, yearly: 0, features: [One site]}
  - {name: Team, monthly: 12, yearly: 120, recommended: true, features: [Ten sites, Support], cta: {label: Choose Team, url: /buy/}}
---
```

Plan cards use the pricing component styles. When plans have `yearly`, a Monthly/Yearly switch made of two radio buttons changes the prices with CSS alone. Set `yearly` on every plan or none; only one plan can be `recommended`, and it is labelled in text.

## Links

A link page has no site header. `links:` become large buttons; their full URLs become `sameAs` of the Person (or `profile: organization`) in the ProfilePage data.

## Contact

```yaml
---
layout: contact
contacts:
  - {label: Email, value: hello@example.com, url: "mailto:hello@example.com"}
form:
  action: https://forms.example.com/your-form   # an external form service; https only
  fields: [name, email, message]
---
```

GitHub Pages cannot receive form posts, so the form appears only when `form.action` is set. Every field has a visible label and `autocomplete`.

## Brand

Swatches are SVG fills, so the page needs no inline style under a strict Content Security Policy, and each color also shows its hex code as text. `modootoday-check` reports a color that is not `#rgb` or `#rrggbb`.

---
id: adr:modootoday/20261105122027
title: "Event tickets takes a map with url, price and currency; the string form stays"
status: active
created: 2026-11-05T12:20:27Z
updated: 2026-11-05T12:20:40Z
rel:
  governs: [_includes/modootoday/detail, lib/modootoday/check/layouts/detail.rb]
  depends_on: [adr:modootoday/20261105112439]
---

# Event tickets takes a map with url, price and currency; the string form stays

## Context

adr:modootoday/20261105112439 left the event layout writing `offers` from `tickets:` with only a `url`, so every event page with tickets gets the nested-object warnings for a missing price (errors from 2.0), and the only fix was a `schema: {offers: ...}` map. It left "a front matter price key for events" for later. Google asks that a marked-up price is also visible on the page.

## Decision

- `tickets:` also takes a map `{url, price, currency}`. `url` is required in the map; `price` is a YAML number of 0 or more; `currency` is an ISO 4217 code (three capital letters); price and currency come together or not at all. The string form renders exactly as before.
- With a price, the offer carries `price` and `priceCurrency`, and the facts list gains a Price row (`layouts.price`) that shows `layouts.free` for 0 and otherwise the number and currency as written, with no locale formatting (the `salary` precedent). `schema.offers` still replaces the whole offer.
- One include, `detail/tickets.html`, reads the key and sets `mt_tickets_url`, `mt_tickets_price` and `mt_tickets_currency`; the call to action, the facts list and the JSON-LD read only those. On a string, `page.tickets.url` is nil on both Liquid 4.0 (Jekyll 3.10) and 4.0.4 (Jekyll 4).
- `modootoday-check` reports a map of the wrong shape as an error, and warns when an event's offer will have no price (a string, or a map without price) and the page sets no `schema.offers`, naming the fix. `availability` and sale dates stay in `schema.offers`.

## Consequences

An event states its price in one place and passes the nested-object check without `schema.offers`; the docs event demo uses the map. Pages with a string `tickets:` build the same bytes and get one more warning that says what to write. The Price row adds two labels to every catalog and no CSS or JavaScript.

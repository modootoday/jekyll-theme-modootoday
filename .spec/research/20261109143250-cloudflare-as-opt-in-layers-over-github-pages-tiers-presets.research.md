---
id: research:modootoday/20261109143250
title: "Cloudflare as opt-in layers over GitHub Pages: tiers, presets and candidates for 1.8.0"
status: active
created: 2026-11-09T14:32:50Z
updated: 2026-11-09T14:32:50Z
rel:
  governs: [_layouts]
---

# Cloudflare as opt-in layers over GitHub Pages: tiers, presets and candidates for 1.8.0

Date: 2026-11-09. Base: the theme at v1.6.0 with the 1.7.0 scope (PWA manifest, service worker, update toast,
install section, footer feedback links, feeds, print sheet, link check) and the 1.8.0 scope (release surfaces,
freshness, docs depth, GitHub surfaces, reading and offline, image checks, J1 stretch). Read-only research: nothing
was edited, built, deployed or tested; no Cloudflare account was touched. Cloudflare facts come from
developers.cloudflare.com as published on the research date; prices and allowances change, so every number below
must be re-read before it is copied into public docs.

Fixed constraints carried into every candidate:

- GitHub Pages (classic `github-pages` 232 and Jekyll 4) stays the origin and the default. Nothing in the theme may
  need Cloudflare. Every Cloudflare piece is an opt-in **layer** the site owner adds in their own account, in front of
  or beside GitHub Pages; removing it must give plain GitHub Pages behaviour back.
- Strict CSP capable, no third-party request by default, privacy first, per-asset byte caps, 23 languages including
  RTL, axe 0.
- The gem ships Jekyll files only. Anything that runs on Cloudflare is a separately versioned companion (Worker
  template, rule files, recipe), never gem code that runs at build.

---

## 0. Summary

**Recommended for 1.8 (ranked).** All work in the **open** tier (no payment method on file).

| Rank | ID | Layer added | Theme work | Effort | Tier | Own ADR first? |
|---|---|---|---|---|---|---|
| 1 | CF-E1 | Real CSP and security headers from Response Header Transform Rules | `modootoday-check --csp-policy` prints the policy the config needs; recipe | S | open | no (amend CSP recipe) |
| 2 | CF-E0 | Edge hygiene: Cloudflare features that break strict CSP or byte-exact output | recipe checklist only | S | open | no |
| 3 | CF-E3 | Cache Rules for `?v=` assets, `sw.js` bypass, purge on deploy | recipe + starter workflow step | S | open | no |
| 4 | CF-E2 | Bulk Redirects from the theme's own moved-URL data | `modootoday-stubs --redirects=csv` | S-M | open | yes, folded into the companion ADR |
| 5 | CF-W1 | `/api/feedback`: "Was this page helpful?" as no-script POST forms | `feedback.endpoint` key, `:target` thank-you, fallback to the 1.7 links | S-M | open | yes (companion ADR) |
| 6 | CF-W2 | `/api/forms`: contact and subscribe to a site-owned Worker, D1, mail to the owner | honeypot field, optional Turnstile key | S theme, M companion | open | yes (forms and Turnstile privacy ADR) |
| 7 | CF-W3 | Cron Trigger that requests a rebuild (`repository_dispatch` or the Pages build API) | none; starter companion + recipe | S | open | no |
| 8 | CF-E4 | `Speculation-Rules` response header so 1.8 B5 works under strict CSP | ship a rules JSON file; header in the recipe | S | open | no (part of B5) |
| 9 | CF-J1 | `og-card` layout the theme renders; optional Worker that screenshots it with Browser Run and caches it | layout + `og.base` key | M | open (small sites), paid (large) | yes (part of the J1 ADR) |
| 10 | CF-R3 | `/dl/` download redirect with a counter, for R3 tables | `downloads.via` key | S | open | covered by companion ADR |

**Needs an ADR in the 1.8 cycle, code later:** CF-P1 web push (endpoint contract now, theme client half in 1.9
behind the 1.7 service worker's first field release), and the **companion packaging and endpoint contract ADR**
that all CF-W items depend on.

**Later (1.9 / 2.x):** CF-P1 client half, CF-S1 server-side search (D1 FTS5 or AI Search), CF-I1 image
transformations for layout images, CF-R2 R2 release mirror with digests, CF-C2 privacy-preserving view counts,
CF-A2 Access in front of the companion's admin routes (lands with CF-W2 if the operator wants it in 1.8),
CF-E5 CSP violation report collector.

**Rejected:** moving hosting to Cloudflare Pages or Workers static assets (kept only as an alternative), Zaraz, the
Web Analytics beacon by default, Access as "private docs" on a GitHub Pages origin, self-hosted comments, a runtime
GitHub Releases proxy, Workers AI translations or summaries in the theme, Durable Object live counters, link
checking at the edge, Snippets. See §8.

**Important caveat for the theme's own docs.** The theme docs are served at a `github.io` host. Cloudflare can only
proxy a domain the owner controls, so none of the edge layers (headers, redirects, cache rules) can apply to the
docs site unless it moves to a custom domain. CF-E2 therefore does **not** by itself solve the "docs have no
redirects" problem behind adr 20261109124854; it solves it for every proxied site and for the docs only after a
custom-domain decision (operator call).

---

## 1. Layer model

```text
reader ── HTTPS ──▶ ┌──────────────────────────────────────────────────────────────┐
                    │ L1  Cloudflare edge (proxied custom domain, "orange cloud")  │
                    │     Transform Rules (response headers), Redirect Rules /     │
                    │     Bulk Redirects, Cache Rules, Speed settings              │
                    └───────────────┬───────────────────────────┬──────────────────┘
                                    │ /*  (everything else)     │ /api/*, /og/*, /dl/*
                                    ▼                           ▼
                    ┌───────────────────────────┐   ┌────────────────────────────────┐
                    │ L0  GitHub Pages origin   │   │ L2  Worker routes (same origin)│
                    │     static Jekyll output  │   │     or a separate workers.dev /│
                    │     (always the default)  │   │     subdomain endpoint         │
                    └───────────────────────────┘   └───────────────┬────────────────┘
                                                                    ▼
                                                    ┌────────────────────────────────┐
                                                    │ L3  Storage and services       │
                                                    │     D1, KV, Durable Objects,   │
                                                    │     Queues, R2, Email, Browser │
                                                    │     Run, Workers AI, Turnstile │
                                                    └────────────────────────────────┘
L4  Out-of-band jobs: Cron Triggers on the Worker, GitHub Actions calling the Worker or the Cloudflare API.
```

- **L0 GitHub Pages origin.** Unchanged. The theme's output is identical with or without any layer, except where a
  `modootoday.cloudflare.*` key (opt-in) prints a form action, an endpoint URL or a meta tag.
- **L1 edge rules** need the custom domain's DNS on Cloudflare with the record **proxied**. Transform Rules require
  proxied records (https://developers.cloudflare.com/rules/transform/); Bulk Redirects require proxied traffic
  (https://developers.cloudflare.com/rules/url-forwarding/bulk-redirects/create-api/). They add no request, no script
  and no third party; the reader still talks only to the site's hostname.
- **L2 Workers** come in two shapes. (a) **Same-origin route** `example.com/api/*` on the proxied zone: CSP needs
  nothing beyond `'self'`, cookies and CORS are moot, and the reader sees one origin. (b) **Separate endpoint**
  (`*.workers.dev` or `api.example.com`): works without proxying the main site (GitHub Pages can stay DNS-only), but
  each feature then needs `connect-src` (fetch), `form-action` (forms) or `img-src` (images) for that origin, and the
  reader contacts a second hostname. Shape (b) is the only option for a site on a `github.io` host.
- **L3 storage** is bound to the Worker; the theme never talks to it directly.
- **L4 jobs** run without a reader: rebuild requests, push sending, OG pre-warming, purges.

**How layers compose.** L1 is independent of L2: headers, redirects and caching work for a pure static site. L2
features each depend on L1 only for the same-origin route; with shape (b) they work on any host. Rules run before
Workers on a route in Cloudflare's phase order, so a Bulk Redirect on `/old/` wins over a Worker on the same path;
keep Worker routes under one prefix (`/api/`, `/og/`, `/dl/`) that no Jekyll page uses and that the redirect list
never names. Workers on a route also switch off Speed Brain prefetch for that path
(https://developers.cloudflare.com/speed/optimization/content/speed-brain/), which is desirable for `/api/*`.

**Degradation when a layer is removed.**

| Layer removed | What happens | What the owner does |
|---|---|---|
| L1 (record set to DNS only, or zone rules deleted) | Headers fall back to whatever GitHub Pages sends (no CSP header; the site's meta CSP still applies), redirects stop (pages that kept a `layout: redirect` stub still meta-refresh), caching falls back to GitHub's `max-age=600` | keep the meta CSP and the redirect stubs as the floor (the recipes say so) |
| L2 route deleted while the theme still points at it | same-origin `/api/*` returns GitHub Pages' 404; no-script forms land on a 404/405 page; scripts that fetch show their fallback | **order**: remove the `modootoday.cloudflare` keys, rebuild, then delete the Worker |
| L2 Worker exceeds the Workers Free daily request limit | Error 1027, or the route **fails open** and the request reaches GitHub Pages (404) if the route is set to fail open (https://developers.cloudflare.com/workers/platform/limits/#daily-requests) | set feature routes to fail open; every client path already has a fallback |
| L3 free allowance exhausted (D1, KV, Queues, Browser Run) | the binding call errors until 00:00 UTC; D1 has enforced this since 2026-09-01 (https://developers.cloudflare.com/changelog/post/2026-09-01-d1-free-tier-limit-enforcement/) | the Worker answers 503 with `Retry-After`; the theme's fallback links still work |

### 1.1 Per-layer enable / disable checklist

**L1 edge (proxied domain)**

Enable:
1. Custom domain on GitHub Pages works first with HTTPS (DNS only). Then move DNS to Cloudflare and switch the record
   to proxied, SSL/TLS mode Full (strict). *Spike:* confirm GitHub's certificate renewal and "Enforce HTTPS" keep
   working with the proxy on; if not, document Full mode with an Origin Rule as the fallback.
2. Run the edge hygiene list (CF-E0): Email Address Obfuscation off, Rocket Loader off, Web Analytics automatic
   injection off, Bot Fight Mode understood (its JavaScript detections need a CSP nonce in a header, not a meta).
3. Import the header rule (CF-E1), cache rules (CF-E3), redirect list (CF-E2), optional `Speculation-Rules` header
   (CF-E4).
4. Verify with the theme's docs QA pattern: fetch a few pages and check headers, zero CSP violations, `sw.js` not
   cached at the edge.

Disable: switch the record to DNS only (instant), or delete rules one by one. Keep the meta CSP and redirect stubs
in the repository the whole time so disabling is safe.

**L2 Worker (companion)**

Enable:
1. Deploy the companion Worker (one Worker, features switched by bindings and vars).
2. Same-origin: add a route `example.com/api/*` (and `/og/*`, `/dl/*` if used), fail-open. Separate: use the
   `workers.dev` URL or a Custom Domain on a subdomain, and add the origin to the site CSP.
3. Create the bindings the preset lists (D1 database, KV, send_email, Browser Run, R2), apply the D1 schema,
   set secrets.
4. Only now add the `modootoday.cloudflare` keys to `_config.yml` and rebuild.

Disable: remove the `modootoday.cloudflare` keys, rebuild and deploy the site, wait for the 1.7 service worker update
cycle, then delete the route and the Worker. Export D1 data first (subscribers are personal data).

**L3 storage**

Enable: create resources in the same account; note the free allowance (§2) beside each binding in the companion's
config. Disable: export (`wrangler d1 export`), delete; delete R2 objects before the bucket.

**L4 jobs**

Enable: Cron Trigger in the Worker config (5 per account on Workers Free) or a GitHub Actions workflow with
`CLOUDFLARE_API_TOKEN` scoped to the one zone (cache purge) or one Worker secret (push send). Disable: remove the
trigger or workflow; nothing on the site depends on it.

---

## 2. Tiers

Definitions use Cloudflare's billing rules as published on the research date.

### 2.1 open: no payment method on file

A Cloudflare account on the Free zone plan and the Workers Free plan, no card added. Over-limit usage **fails** rather
than bills, which makes this tier safe by construction.

| Product | What the open tier gets | Hard behaviour at the limit | Source |
|---|---|---|---|
| Proxied DNS and CDN, Free zone plan | proxying, HTTP/3, Brotli, cache, Speed Brain (on by default on Free) | n/a | https://developers.cloudflare.com/speed/optimization/content/speed-brain/ |
| Transform Rules (request/response headers, URL rewrite), Cache Rules, Configuration Rules | available on Free; rule counts per zone are plan-bound (Enterprise raised to 300 in 2025; check the Free count in the dashboard) | rules beyond the count cannot be created | https://developers.cloudflare.com/rules/transform/ , https://developers.cloudflare.com/changelog/post/2025-02-12-rules-upgraded-limits/ |
| Single Redirects | 10 rules per zone, wildcards, no regex | cannot create more | https://developers.cloudflare.com/rules/url-forwarding/#availability |
| Bulk Redirects | 15 rules, 5 lists, 10,000 URL redirects per account | cannot add items | same |
| Workers Free | 100,000 requests/day, 10 ms CPU per request and per Cron, 50 external subrequests per request, 5 Cron Triggers per account, 100 Workers | Error 1027 or fail-open bypass | https://developers.cloudflare.com/workers/platform/limits/ |
| Workers KV | 100,000 reads, 1,000 writes, 1,000 deletes, 1,000 lists per day, 1 GB | operation errors until 00:00 UTC | https://developers.cloudflare.com/kv/platform/pricing/ |
| D1 | 5 M rows read, 100,000 rows written per day, 5 GB total, 10 databases | queries fail until 00:00 UTC (enforced from 2026-09-01) | https://developers.cloudflare.com/d1/platform/pricing/ |
| Durable Objects (SQLite backend) | same row allowances as D1, 5 GB | errors | https://developers.cloudflare.com/durable-objects/platform/pricing/ |
| Queues | 10,000 operations/day, 24 h retention, 10,000 queues | errors | https://developers.cloudflare.com/queues/platform/pricing/ |
| Workers AI | 10,000 Neurons/day; some large models need Workers Paid | errors (403 for paid-only models) | https://developers.cloudflare.com/workers-ai/platform/pricing/ |
| Browser Run (formerly Browser Rendering) | 10 browser-minutes/day, 3 concurrent browsers, Quick Actions 1 request per 10 s | 429 until the next UTC day | https://developers.cloudflare.com/browser-run/limits/ |
| Images transformations | 5,000 unique transformations/month on the Images Free plan | new transformations return error 9422; never charged | https://developers.cloudflare.com/images/pricing/ |
| AI Search | 100 instances, website crawl 500 pages/day on Workers Free, monthly included usage (5 M ingestion tokens, 10 GB-month, 1,000 semantic and 1,000 full-text queries); billing starts 2026-12-01 | `monthly_query_quota_exceeded` (429) | https://developers.cloudflare.com/ai-search/platform/limits-pricing/ |
| Email Routing + send to **verified destination addresses** | inbound routing unlimited; a Worker may send to the owner's verified addresses free on any plan | sending to other recipients is not available | https://developers.cloudflare.com/email-service/platform/pricing/ , https://developers.cloudflare.com/email-service/platform/limits/ |
| Turnstile | embeddable without proxying; WCAG 2.2 AA | n/a | https://developers.cloudflare.com/turnstile/ |
| Web Analytics | cookie-less RUM beacon (rejected as a default here; see §8) | n/a | https://developers.cloudflare.com/web-analytics/faq/ |

### 2.2 free: a payment method is on file, usage stays inside allowances

| Product | Why a card is involved | Free allowance | Cap available? |
|---|---|---|---|
| Zero Trust Free (Access) | onboarding asks for payment details even on the Free plan ("you will not be charged") | Zero Trust Free plan seats (verify the current seat count in the plan page) | seats cannot exceed the plan without changing plan |
| R2 | R2 is a pay-as-you-go subscription; Cloudflare's R2-based products state "an active R2 subscription" and "a linked payment card" (https://developers.cloudflare.com/basin-sql/platform/pricing/). *Spike:* confirm the card prompt for plain R2 when enabling it | 10 GB-month storage, 1 M Class A, 10 M Class B per month, egress free (https://developers.cloudflare.com/workers/platform/pricing/#r2) | **no hard cap**: overage bills |

What must be capped or monitored so the free tier never bills:

- **Budget alerts are informational, daily, and exclude subscription fees.** Pay-as-you-go accounts get a default $10
  alert; set one at $1. They do not stop usage
  (https://developers.cloudflare.com/changelog/post/2026-06-15-budget-alerts-default-on/ ,
  https://developers.cloudflare.com/changelog/post/2026-04-13-billable-usage-dashboard-and-budget-alerts/).
- **Cap in code.** The companion keeps a running byte and object count for R2 writes in D1 and refuses writes past
  90 % of 10 GB-month; it never exposes a public write path to R2; reads go through cached responses so Class B stays
  low.
- **Cap with limits.** `limits.cpu_ms` and `limits.subrequests` in the Worker config
  (https://developers.cloudflare.com/workers/wrangler/configuration/#limits) bound runaway code (they matter more on
  Paid, where CPU bills).
- **Keep the Worker on Workers Free.** Adding a card does not move the account to Workers Paid; usage of Workers, KV,
  D1, Queues, Browser Run and Workers AI keeps failing at the free limits instead of billing.

### 2.3 paid: incurs cost

Cost drivers (Workers Paid is $5/month base, https://developers.cloudflare.com/workers/platform/pricing/):

| Driver | Included with Workers Paid | Overage |
|---|---|---|
| Workers requests / CPU | 10 M requests, 30 M CPU-ms per month | $0.30 / M requests, $0.02 / M CPU-ms |
| Email Sending to any recipient (double opt-in, notifications to readers) | 3,000 emails/month | $0.35 / 1,000 (https://developers.cloudflare.com/email-service/platform/pricing/) |
| Browser Run | 10 browser-hours/month, 10 concurrent | $0.09 / browser-hour, $2 / extra concurrent browser |
| Workers AI | 10,000 Neurons/day | $0.011 / 1,000 Neurons |
| Queues | 1 M operations/month | $0.40 / M |
| D1 / Durable Objects | 25 bn rows read, 50 M written, 5 GB | $0.001 / M read, $1.00 / M written, $0.75 / GB-month (D1) |
| Vectorize | 50 M queried, 10 M stored dimensions | $0.01 / M queried, $0.05 / 100 M stored |
| AI Search (from 2026-12-01) | monthly included usage as above | $0.75 / 1,000 semantic queries, $0.10 / 1,000 full-text, $2 / GB-month, $0.75 / M ingestion tokens |
| Images Paid | 5,000 unique transformations | $0.50 / 1,000 |
| R2 beyond free | as above | $0.015 / GB-month, $4.50 / M Class A, $0.36 / M Class B |

Rough monthly estimates (assumptions in brackets; recompute before publishing):

- **Small docs or blog site** [10,000 page views, 300 API calls, 50 form posts, 300 push subscribers × 4 sends,
  200 OG images generated once, no AI]: everything except edge-sent push fits the open tier. With the paid preset
  the bill is the **$5 base**; usage stays inside the included amounts.
- **Busy product site** [2 M page views, 400,000 API calls, 20,000 push subscribers × 8 sends = 160,000 sends through
  Queues (≈ 480,000 operations), 20,000 confirmation emails, 3,000 OG images (≈ 2 browser-hours), 50,000 AI Search
  semantic queries]: Workers within included; Queues within 1 M; email ≈ (17,000 / 1,000) × $0.35 ≈ $6; AI Search
  ≈ (49,000 / 1,000) × $0.75 ≈ $37; Browser Run within 10 h. **≈ $50 / month**, of which AI Search is three
  quarters; without AI Search **≈ $11**.

---

## 3. Candidates by area

Field key: **Runs where** · **Products and limits** · **Tier** (minimum, and what degrades below it) · **Secrets** ·
**CSP / privacy** · **Theme ships** · **Effort** (S ≤ 1 day, M 2-5 days, L > 1 week, including 23 catalogs, docs in
en/ko/ja and three-stack tests) · **Risk** · **Depends on** · **Verdict**.

### E. Edge rules (L1, no Worker)

**CF-E0. Edge hygiene for theme sites.**
Runs where: zone settings. Several Cloudflare features rewrite HTML or inject scripts and break the theme's
guarantees: Email Address Obfuscation and Rocket Loader inject scripts (strict CSP violations) and change HTML;
automatic Web Analytics injection adds a third-party script from `static.cloudflareinsights.com`
(https://developers.cloudflare.com/web-analytics/faq/); Bot Fight Mode's JavaScript Detections need `/cdn-cgi/` in
`script-src` and parse a nonce only from a CSP **header**, never a meta
(https://developers.cloudflare.com/bots/get-started/bot-fight-mode/); Speed Brain adds a `Speculation-Rules` header
on Free by default unless the origin sends one. HTML rewriting also breaks `modootoday-check --byte-exact` if a
byte-exact folder holds HTML (it should not; the recipe says so). Tier: open. Theme ships: a checklist section in the
new recipe; optionally a `docs QA` step that fetches pages from a proxied preview. Effort S. Risk: none. Verdict:
**1.8**.

**CF-E1. Real CSP and security headers.**
Runs where: a Response Header Transform Rule with **Set** (not Add, to avoid duplicate CSP headers;
https://developers.cloudflare.com/client-side-security/troubleshooting/). Gains over the meta tag: directives a meta
cannot carry (`frame-ancestors`, `report-to`/`report-uri`, `sandbox`), plus `Strict-Transport-Security`,
`X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`, `Cross-Origin-Opener-Policy`. Tier: open. Theme
ships: `modootoday-check --csp-policy[=json|text|terraform]` prints the policy the site's config implies (strict base;
plus the documented additions for KaTeX HTML, Chart.js on a CDN, G7 comments, Turnstile, a separate Worker origin),
so the rule and the meta stay in step; the CSP recipe gains a "Send it as a header through Cloudflare" section and
keeps the meta as the floor (a page with both a header and a meta enforces both; keep them identical). Config: none
required; an optional `modootoday.csp_header: true` only suppresses the checker's "no header" note. Secrets: none.
Effort S. Risk: a wrong header can blank a page (Set replaces); recipe insists on a report-only phase first. Depends
on: nothing; docs QA already serves the strict policy as a header. Verdict: **1.8 (rank 1)**.

**CF-E2. Redirects for moved URLs.**
Runs where: Bulk Redirect list (CSV import) or Single Redirect rules. Limits on the open tier: 10,000 URL redirects
in 5 lists per account, 10 Single Redirects per zone (https://developers.cloudflare.com/rules/url-forwarding/#availability).
Theme ships: `modootoday-stubs --redirects=csv` that emits source URL, target URL, 301 for every alias in
`modootoday.aliases` (`html` kind), every page with `redirect_from:`/`moved_to:` front matter (new optional key) and
every record that moved; the existing `layout: redirect` stubs stay as the GitHub Pages floor (meta refresh plus
canonical), so removing the layer still redirects, only slower and with a 200 status. Tier: open. Effort S-M (the
planner already knows aliases; a `moved_to` key needs a rules-additive change). Risk: redirect loops when an alias
equals a live page (checker already rejects that conflict). Depends on: the alias planner (1.6). Caveat: the theme
docs on `github.io` cannot use it (see §0). Verdict: **1.8**; needs the companion ADR only for the output format.

**CF-E3. Cache Rules for theme assets.**
Runs where: Cache Rules + a Response Header rule. GitHub Pages sends `max-age=600` for everything; the theme already
versions asset URLs with `?v=` (adr 20261102215137). Rules: (1) `/assets/` with a `v` query → Edge TTL long, browser
`Cache-Control: public, max-age=31536000, immutable` (cache key must include the query string; it does by default);
(2) `/sw.js`, `/manifest.webmanifest`, `/offline/` → bypass cache, so the 1.7 update toast is never delayed by the
edge; (3) HTML → respect origin (600 s) or short edge TTL plus purge on deploy. Purge: a starter workflow step after
`actions/deploy-pages` calls the purge API with a zone-scoped token (secret `CLOUDFLARE_API_TOKEN`, permission
"Cache Purge" on one zone). Tier: open. Theme ships: recipe and an optional starter step (skipped when the secret is
absent). Effort S. Risk: caching `sw.js` at the edge would freeze updates for the TTL; the rule list makes the bypass
rule first. Depends on: 1.7 service worker (rule 2). Verdict: **1.8**.

**CF-E4. `Speculation-Rules` as a header.**
Runs where: Response Header rule `Speculation-Rules: "/assets/speculation.json"` plus a rule that sets
`Content-Type: application/speculationrules+json` on that file (GitHub Pages serves `.json` as `application/json`;
*spike*: confirm Chromium rejects the wrong type). This is the strict-CSP route for 1.8 **B5**: external rules need
no `'inline-speculation-rules'`. Speed Brain (on by default on Free) does not override an origin-sent header and only
prefetches from cache (https://developers.cloudflare.com/speed/optimization/content/speed-brain/); a header added by
a Transform Rule may or may not count as "origin" for that check (*spike*). Theme ships: the rules JSON as a static
file (moderate eagerness, same-origin, exclude `/api/`, `?`, `#`), the recipe. Tier: open. Effort S. Risk: double
rules (Speed Brain and the site's) — recipe turns Speed Brain off when this is used. Depends on: B5 in 1.8.
Verdict: **1.8** (inside B5).

**CF-E5. CSP violation reports.**
Runs where: header `report-to` (CF-E1) + `/api/csp-report` in the companion, storing counts per directive and blocked
URI in D1, no IP stored. Tier: open (rows written per report; sample at 10 % to stay inside 100,000 writes/day).
Theme ships: nothing (checker prints the `report-to` line when an endpoint is set). Effort S (companion). Risk:
report floods from extensions; sampling and a size cap. Verdict: later (optional module once the companion exists).

**CF-E6. HTTP/3, compression, Early Hints.**
Zone toggles. Early Hints uses `Link: rel=preload` headers it has seen from the origin; GitHub Pages sends none, and
whether a Transform-Rule-added `Link` header feeds Early Hints is unverified. Theme ships: one recipe paragraph.
Verdict: recipe note in 1.8, no feature.

### W. Worker endpoints for forms and feedback (L2)

**CF-W1. "Was this page helpful?" stored by the site.**
Runs where: Worker `POST /api/feedback` (`page`, `lang`, `value`, optional `reason`), D1 table of counts per page per
day, no IP, no cookie, no user agent stored. The 1.7 C3 links become two `<form method="post">` buttons when
`modootoday.cloudflare.feedback` is set; the Worker answers `303 See Other` to `<page>#mt-thanks`, and a `:target`
rule in the `doc-nav` sheet shows the thank-you line: no script at all, strict CSP intact (`form-action` is not
restricted by the base policy; same-origin anyway). Without the key the 1.7 prefilled-issue links render as before;
if the layer disappears while the key is still set, the form posts land on a GitHub Pages 404, which is why the
disable order in §1.1 matters. Tier: open (one row write per vote). Abuse: rate limit per IP hash in memory, Origin
check, honeypot. Theme ships: key, ~60 B CSS, 1 i18n key ("Thanks for the feedback") × 23. Companion: route + D1
schema + a CSV export route behind a bearer token (or Access, CF-A2). Effort S-M. Risk: low. Depends on: 1.7 C3.
Verdict: **1.8**.

**CF-W2. Contact and subscribe forms without a third-party form service.**
Today: `c: subscribe` posts to `modootoday.subscribe.action`, the `contact` layout posts to `page.form.action` (an
external form service). The theme already supports a Worker as the action; what is missing is a companion that
receives it and three small theme additions.
- Runs where: Worker `POST /api/forms/<name>`, validates fields, stores in D1, sends the owner a notification with the
  `send_email` binding to a **verified destination address** (free on any plan,
  https://developers.cloudflare.com/email-service/configuration/email-routing-addresses/#destination-addresses),
  answers 303 to `<page>#mt-sent` (or `#mt-error`), so no script is needed.
- Subscribe without a mail provider: open tier stores the address with a `pending` state and gives the owner an export;
  **double opt-in mail to the subscriber** needs Email Sending to arbitrary recipients, which needs Workers Paid
  (3,000 emails/month included). The recipe must say plainly that without double opt-in the list is not
  consent-proof in many jurisdictions; the open preset therefore labels it "notify me" (owner contacts manually) and
  the paid preset does double opt-in.
- Abuse without a third party (default): honeypot field hidden by a class (theme, ~40 B CSS), a timestamp field and
  a minimum fill time checked in the Worker, Origin check, per-IP-hash rate limit, length limits; optionally a WAF
  rate limiting rule on `/api/forms/*` (*verify* the Free-plan rate-limiting rule allowance).
- Abuse with Turnstile (opt-in): `modootoday.cloudflare.turnstile.sitekey` renders the widget container and loads
  `https://challenges.cloudflare.com/turnstile/v0/api.js` only on pages that carry a form; it must load from that exact
  URL (no vendoring, https://developers.cloudflare.com/turnstile/get-started/client-side-rendering/), so it is a
  **third-party script**: CSP `script-src` and `frame-src https://challenges.cloudflare.com`; the Worker validates
  the token with Siteverify (single use, 300 s) and the secret key lives in a Worker secret. Accessibility: Turnstile
  states WCAG 2.2 AA. Language: its own UI, not the theme's 23 catalogs (check coverage, set `data-language` from
  `page.lang`).
- Tier: open (D1 writes, owner mail). Paid for double opt-in. Secrets: `TURNSTILE_SECRET`, export token.
- Theme ships: `modootoday.cloudflare.forms: true` (sets the honeypot and the `#mt-sent` notices), the Turnstile key,
  ~80 B CSS, ~200 B JS loader for Turnstile only when the key is set, 3 i18n keys × 23, recipe. Companion: route,
  schema, mail templates in en/ko/ja (owner-facing only).
- Effort S theme, M companion. Risk: personal data (retention, deletion on request: the companion needs a delete
  route and a retention setting); spam. Depends on: the companion ADR and a **forms and Turnstile privacy ADR**
  (same shape as the G7 comments ADR). Verdict: **1.8** (theme half + companion), Turnstile behind its own key.

**CF-W3. Scheduled and event rebuilds from a Cron Trigger.**
Runs where: Worker Cron Trigger (5 per account on Free) calling GitHub `POST /repos/{owner}/{repo}/dispatches`
(`repository_dispatch`) for Actions-built sites, or the Pages build endpoint for branch-built sites; token in a
Worker secret (fine-grained, one repository, Contents read/write or Actions write). Why: GitHub disables scheduled
workflows in public repositories after 60 days without activity (1.7 research, G6); a Cron Trigger does not expire.
Tier: open (one subrequest per run, far below 10 ms CPU). Theme ships: nothing; the starters' `pages.yml` already
gains `repository_dispatch` in 1.7 with R6/G6 (add the event type). Effort S. Risk: token scope; recipe gives the
minimal scope. Verdict: **1.8** (companion module + one recipe paragraph).

### P. Web push done properly

**CF-P1. Site-owned push endpoint.**
How the pieces fit (RFC 8030/8291/8292 as summarised in the 1.7 research):
- **Endpoint contract** (companion): `GET /api/push/key` → VAPID public key (or the key is a config value);
  `POST /api/push/subscribe` `{subscription, topics[], lang}`; `POST /api/push/unsubscribe` `{endpoint}`;
  `POST /api/push/send` (bearer token from an Actions secret, or an Access service token) `{topic, title, body, url,
  tag, lang}`; `GET /api/push/export` (owner only). Storage: D1 `subscriptions(endpoint PRIMARY KEY, p256dh, auth,
  topics, lang, created, last_ok, failures)`. Validation: the endpoint host must be a known push service
  (`fcm.googleapis.com`, `updates.push.services.mozilla.com`, `web.push.apple.com`, `*.notify.windows.com`) so the
  sender cannot be used as an open relay; Origin must be the site; payload size limits.
- **Sending, two options.** (a) **Store at the edge, send from Actions** (recommended for the open tier): a workflow
  `on: release` or `on: push` to posts calls `/api/push/export` with the token and sends with a Node web-push
  library and the VAPID private key from Actions secrets; it reports 404/410 endpoints back to `/api/push/unsubscribe`.
  The Worker never holds the private key; Worker usage is two requests per release. (b) **Send from the edge**: the
  VAPID private key in a Worker secret, encryption with WebCrypto, fan-out through Queues because Workers Free allows
  only 50 external subrequests and 10 ms CPU per invocation
  (https://developers.cloudflare.com/workers/platform/limits/). Queues on Free give 10,000 operations/day, about
  3,300 sends/day (write + read + delete per message,
  https://developers.cloudflare.com/queues/platform/pricing/), and per-message crypto must fit 10 ms (*spike*: measure
  ECDH + HKDF + AES-GCM per message on Workers). Realistically (b) is the paid preset.
- **Client half** (theme): `modootoday.pwa.push: {endpoint, vapid_public_key, topics}`; a `c: notify` section with a
  Subscribe button (never an automatic prompt, same rule as 16b's install section); `register.js` dynamically imports
  `push.js` (est. 700-900 B gzip) on click; `worker.js` gains `push` and `notificationclick` handlers (est. 350 B) that
  show a notification localised by the payload's `lang` and focus or open the URL; 6 i18n keys × 23 (subscribe,
  unsubscribe, blocked, unsupported, iOS install hint, subscribed).
- **CSP**: same-origin route needs nothing; a separate endpoint needs its origin in `connect-src`. The push service
  itself is contacted by the browser, not by the page, so no CSP entry for it.
- **iOS / iPadOS**: push only in Home Screen web apps (16.4+) and only after a user gesture; the button shows the
  install hint (16b's section) when `navigator.standalone` is false on iOS Safari.
- **Privacy wording**: "Your browser's push service (Apple, Google, Mozilla or Microsoft, chosen by your browser) gives
  this site an address for your device. The site stores that address, the topics you chose and your language, and
  nothing else. Messages are end-to-end encrypted. Unsubscribe here or in your browser settings at any time."
- **Abuse**: Turnstile optional on subscribe (third-party trade-off as in CF-W2), rate limit per IP hash, cap topics.
- Tier: open with sending from Actions; paid for edge sending at scale.
- Effort: theme L, companion M. Risk: high (a worker bug outlives rollbacks; permission UX; abandoned endpoints).
- Depends on: the 1.7 service worker having a release in the field; the companion ADR.
- Verdict: **endpoint contract ADR in the 1.8 cycle; client half 1.9** (not 1.8): the 1.8 release already carries
  E2 "save for offline" on the same worker, and two worker features in one release double the rollback risk. The 1.7
  "Tell readers about updates" recipe gains a forward link once the contract exists.

### S. Search

**CF-S1. Optional server-side search.**
Options: (a) **D1 FTS5**: an Actions job or the Worker ingests the built `search.json` into an FTS5 table (*verify*
FTS5 availability and the `trigram` tokenizer in D1; the default `unicode61` tokenizer does not segment CJK, while
the theme's static search does compact matching for Korean); query `GET /api/search?q=&lang=`. Open tier: 5 M rows
read/day is plenty for small sites, but each query reads many rows on large indexes. (b) **AI Search** (hybrid
keyword + vector, website crawl data source needs the domain on Cloudflare): open tier crawls 500 pages/day and
includes 1,000 semantic + 1,000 full-text queries per month; billing begins 2026-12-01
(https://developers.cloudflare.com/ai-search/platform/limits-pricing/); its answers are only as multilingual as its
models. (c) Vectorize + Workers AI embeddings by hand (more work than (b)).
Theme: `modootoday.search.endpoint`; `search.js` queries the endpoint when set and falls back to `search.json` on
any error or offline (the 1.7 worker serves `search.json` stale-while-revalidate), so offline behaviour is never
worse than today. Est. +150 B in `search.js` (classic script through 1.x, adr 20261103053805). CSP: `connect-src`
only for a separate origin. Privacy: queries reach the site's own Worker instead of staying in the browser (a
regression from fully local search; must be stated). Effort M (theme) + M (companion). Value: only for sites whose
`search.json` passes the 1.5 MB warning. Verdict: **later (1.9+)**; B2 heading hits in 1.8 first.

### C. Comments, reactions, counters, analytics

**CF-C1. Self-hosted comments on Workers + D1.** Needs identity (or anonymous posting with moderation), spam control,
moderation UI, deletion and export, notification mail: an application, not a theme layer. G7 (giscus behind a
click-to-load facade) covers the demand with GitHub identity. Verdict: **reject** (§8).

**CF-C2. View counts without cookies.**
Options: zone analytics on a proxied site already counts requests at the edge with **no client code at all** (the
recommended answer); a per-page counter needs either a Worker in front of every page (every view becomes a Worker
request and counts against 100,000/day on Free, and Speed Brain stops prefetching those paths) or a beacon
`navigator.sendBeacon('/api/hit')` (~150 B, same-origin, no cookie, no IP stored, D1 one write per view: 100,000
views/day on Free). Showing counts on pages needs a fetch per view. Privacy: counting is benign; showing popularity
is a product choice. Effort S-M. Verdict: **later**, optional companion module; the recipe points to zone analytics.

**CF-C3. Cloudflare Web Analytics.** Manual beacon loads `https://static.cloudflareinsights.com/beacon.min.js` and
reports to `cloudflareinsights.com` (third party for the reader, CSP `script-src` and `connect-src` additions);
automatic setup on a proxied site reports to the site's own `/cdn-cgi/rum` but still injects the script from
`static.cloudflareinsights.com` with an `integrity` attribute
(https://developers.cloudflare.com/web-analytics/faq/). Cookie-less, but against "no third-party request by
default". Verdict: **reject as a default**, document the exact CSP additions for owners who want RUM; prefer zone
analytics (no client code).

**CF-C4. Reactions (emoji counts per post).** Same mechanics as CF-W1 with more buttons. Verdict: later, only if
CF-W1 shows use.

### J. Open Graph images

**CF-J1. `og-card` layout plus optional edge rendering.**
The hard part of J1 is CJK and RTL text. A browser shapes text correctly with the theme's own per-script font
stacks, so the theme ships **`layout: og-card`**: a 1200 × 630 page per post or doc (generated by `modootoday-stubs
--og` on classic Pages, by the plugin on Jekyll 4) that renders title, section, site name, language direction and
brand tokens with no script. Two ways to rasterise it:
- **Build-time** (site tooling, any host): an Actions step screenshots the og-card pages and commits or deploys
  `/assets/og/<page>.png`; the checker reports missing or stale images by digest (as in the 1.7 research).
- **Edge** (companion): `GET /og/<path>.png` → cache (Cache API, then R2 if on the free tier) → on a miss, Browser Run
  Quick Action `screenshot` of `<site>/og-card/<path>/` → store and return. Open tier: 10 browser-minutes/day and one
  Quick Action per 10 s (https://developers.cloudflare.com/browser-run/limits/) is enough for a few dozen new pages a
  day; a post-deploy Actions job pre-warms new pages so social crawlers never wait. Paid: 10 browser-hours/month
  included, then $0.09/h. A Satori/resvg-wasm Worker is the alternative, but CJK fonts are several MB each and the
  10 ms Free CPU limit rules it out; it would be paid only and still needs font subsetting per language.
Theme: the og-card layout and CSS (own page type, est. ≤ 1.5 KiB CSS, not loaded on normal pages),
`modootoday.og.base` (`/assets/og/` default for build-time, `/og/` for the edge), `og:image` + J2's alt, width and
height. Fallback when the layer is removed: images 404 until the key is removed and the site rebuilds; J2's fallback
image is used when the key is absent. CSP: `og:image` is fetched by social crawlers, not the page; no CSP change.
Privacy: none for readers. Effort M (theme), S (companion). Risk: crawler timeouts on a cold edge (pre-warm);
og-card pages must be `noindex` and excluded from search, sitemap, feeds and `llms.txt`. Depends on: J2 (1.7).
Verdict: **1.8 stretch with J1** (the og-card layout is useful even without Cloudflare); the J1 ADR decides.

### R. Release surfaces

**CF-R1. GitHub Releases API proxy.** A Worker caching `GET /repos/.../releases` with a token in a secret gives a
same-origin, rate-limit-safe JSON. But R1/R3 render at build time from `site.github` or an Actions-written `_data`
file, and R6 rebuilds on release; a runtime fetch would add a request per view for data the page already has.
Verdict: **reject** (§8).

**CF-R2. Release assets mirrored to R2 with digests.** An Actions job on `release: published` copies assets to R2,
records SHA-256 (GitHub exposes asset digests since 2025-06), and the download table links to `/dl/<tag>/<file>` served
from R2 with `Content-Digest`. Value: own-domain downloads, survival if GitHub URLs change. Tier: free (card for R2;
10 GB-month free, egress free). Risk: storage creep; the companion caps it (§2.2). Verdict: **later**.

**CF-R3. Download redirect and counter.** `GET /dl/<tag>/<asset>` → increment a D1 counter (date, asset; nothing
about the reader) → 302 to the GitHub `browser_download_url`. Theme: `modootoday.cloudflare.downloads.via: /dl` makes
R3's table link through it; without the key links point at GitHub directly. Tier: open (one write per download).
Effort S. Risk: an extra hop; a dead Worker breaks downloads (route fail-open would 404 at GitHub Pages: the theme
should prefer a no-script fallback link "Direct link" in the table's detail row). Depends on: R3. Verdict: **1.8
optional**, low priority.

### A. Access

**CF-A1. Access for "private docs".** An Access application on the proxied hostname puts a login in front of it, but
the content still lives on GitHub Pages: the `github.io` URL of the repository and the public repository itself
(GitHub Pages on free plans requires a public repository) expose the same files. Access cannot make a GitHub Pages
site private. Verdict: **reject** for that purpose (§8); the honest answer to the earlier TOTP/MFA question is "private
docs need private hosting (GitHub Enterprise private Pages, or another host), not a layer".

**CF-A2. Access in front of the companion's admin routes.** `/api/*/export`, `/api/push/send`, `/api/forms/*/delete`
behind an Access self-hosted application with one-time PIN or GitHub login, and an Access service token for Actions.
Tier: **free** (Zero Trust Free asks for payment details at onboarding,
https://developers.cloudflare.com/cloudflare-one/setup/). Open-tier alternative: a long random bearer token in a
Worker secret and an Actions secret. Verdict: **later**, or with CF-W2 if the operator wants it in 1.8; the
companion supports both.

### I. Images and AI

**CF-I1. Image transformations for layout images.** On a proxied zone, `/cdn-cgi/image/width=…,format=auto/<path>`
serves resized AVIF/WebP from the site's own images; Images Free gives 5,000 unique transformations/month and returns
error 9422 beyond (never charged), with `onerror=redirect` falling back to the original
(https://developers.cloudflare.com/images/pricing/). Theme: `srcset` for hero posters, cards and covers only (layout
images, not body Markdown images) when `modootoday.cloudflare.images: true`; widths capped at 3 per image to stay
within 5,000 (≈ 1,600 images). CSP: same origin. Effort M. Risk: transformation must be enabled per zone; a removed
layer turns `srcset` URLs into GitHub Pages 404s (keep `src` original so only the `srcset` candidates fail, which
browsers skip poorly: a rebuild without the key is required). Verdict: **later (1.9)**.

**CF-I2. Workers AI translation drafts and summaries.** The theme's translation rules require localisation from
English, not literal output (adr 20261029220746), with a linted style guide; machine drafts would be site tooling at
most. Summaries for `llms.txt` would put generated text in a file that promises to describe the site. Verdict:
**reject** as theme features (§8).

### O. Other

**CF-O1. Durable Objects for live counters / presence.** Overkill for static sites; D1 or zone analytics cover counts.
**Reject.**

**CF-O2. Link checking at the edge.** L1 (1.7) checks internal links in the built site; external link checks belong in
Actions, not in a Worker limited to 50 external subrequests per invocation on Free. **Reject.**

---

## 4. Ranking

Score = value (1-5) + fit (1-5) − effort (S 1, M 2, L 3) − risk (1-3), as in the 1.7 research.

| Rank | ID | Candidate | Tier | Val | Fit | Eff | Risk | Score | Release |
|---|---|---|---|---|---|---|---|---|---|
| 1 | CF-E1 | CSP and security headers as real headers | open | 5 | 5 | S | 1 | 8 | **1.8** |
| 2 | CF-E0 | Edge hygiene checklist | open | 4 | 5 | S | 1 | 7 | **1.8** |
| 3 | CF-E3 | Cache Rules, `sw.js` bypass, purge | open | 4 | 5 | S | 2 | 6 | **1.8** |
| 4 | CF-W3 | Cron rebuild requests | open | 3 | 5 | S | 1 | 6 | **1.8** |
| 5 | CF-E4 | `Speculation-Rules` header (B5) | open | 3 | 5 | S | 2 | 5 | **1.8** (with B5) |
| 6 | CF-E2 | Bulk Redirects export | open | 4 | 4 | S-M | 2 | 5 | **1.8** |
| 7 | CF-W1 | Feedback endpoint, no-script forms | open | 4 | 4 | S-M | 2 | 5 | **1.8** |
| 8 | CF-W2 | Forms companion, honeypot, opt-in Turnstile | open (paid for double opt-in) | 4 | 4 | M | 2 | 4 | **1.8** |
| 9 | CF-J1 | og-card layout + edge screenshots | open / paid | 4 | 4 | M | 2 | 4 | **1.8 stretch** (J1) |
| 10 | CF-R3 | Download redirect + counter | open | 2 | 4 | S | 2 | 3 | 1.8 optional |
| 11 | CF-P1 | Push endpoint contract (ADR) | open (Actions send) / paid (edge send) | 4 | 2 | L | 3 | 1 | ADR 1.8, client **1.9** |
| 12 | CF-A2 | Access for admin routes | free | 2 | 4 | S | 1 | 4 | later (or with W2) |
| 13 | CF-E5 | CSP report collector | open | 2 | 4 | S | 2 | 3 | later |
| 14 | CF-S1 | Server-side search | open / paid | 3 | 3 | M | 2 | 2 | 1.9+ |
| 15 | CF-I1 | Image transformations (layout images) | open | 3 | 3 | M | 2 | 2 | 1.9 |
| 16 | CF-C2 | Cookie-less view counts | open | 2 | 3 | S-M | 2 | 1 | later |
| 17 | CF-R2 | R2 release mirror | free | 2 | 3 | M | 2 | 1 | later |
| 18 | CF-C4 | Reactions | open | 2 | 3 | S | 2 | 2 | later |
| 19 | CF-E6 | HTTP/3, compression, Early Hints | open | 1 | 5 | S | 1 | 4 | recipe note only |

**Which need their own ADR first:**
1. **Companion packaging and edge endpoint contract** (§7): before CF-W1, CF-W2, CF-W3, CF-R3, CF-E2's output format.
2. **Forms and Turnstile privacy**: the second opt-in third-party script after G7; decide default abuse controls,
   retention, double opt-in wording.
3. **Web push endpoint contract** (CF-P1): before any client code.
4. **J1** (already planned): absorbs CF-J1's og-card layout and the edge option.
CF-E0, CF-E1, CF-E3, CF-E4 only amend existing recipes and the checker; no ADR needed beyond a line in the 1.8 scope
ADR.

---

## 5. Presets

A preset is a **name for a bundle of layers**, documented by the theme and implemented by the companion. The theme
never changes output because of the preset name alone; it reads the per-layer keys, and the preset only supplies
their defaults in docs and in the companion's generated config. Absent `modootoday.cloudflare` = plain GitHub Pages.

```yaml
# _config.yml (all keys optional; nothing here is needed for GitHub Pages)
modootoday:
  csp: strict
  cloudflare:
    preset: open-docs            # documentation label; the companion reads the same name
    endpoint: /api               # same-origin route (proxied) or https://<name>.<account>.workers.dev
    feedback: true               # CF-W1: helpful yes/no posts to <endpoint>/feedback
    forms: true                  # CF-W2: honeypot + #mt-sent/#mt-error notices on contact and subscribe
    turnstile: {sitekey: ...}    # CF-W2: opt-in third-party script, only on pages with a form
    og: {base: /og}              # CF-J1: edge-rendered og:image; omit for build-time /assets/og/
    downloads: {via: /dl}        # CF-R3
    # push lives under modootoday.pwa.push from 1.9 (CF-P1)
```

`modootoday-check` rules (all warnings): `endpoint` set while a meta CSP in `_includes/head-custom.html` lacks the
endpoint origin in `connect-src`/`form-action` (separate-origin case); `turnstile` set without `forms`;
`subscribe.action` or `form.action` pointing elsewhere while `forms: true`; `og.base` set while J2's fallback image is
missing.

| Preset | Tier | Layers | Theme keys | Owner deploys | Secrets | Fallback when removed |
|---|---|---|---|---|---|---|
| `edge-basic` | open | L1: CF-E0, CF-E1, CF-E3, CF-E2, CF-E4 | none (optional `csp_header: true`) | zone rules (JSON/Terraform from the companion's `rules/`), Bulk Redirect CSV from `modootoday-stubs --redirects=csv` | zone-scoped API token in Actions for purge | DNS-only record: meta CSP, redirect stubs, GitHub caching |
| `open-docs` | open | `edge-basic` + CF-W1 feedback + CF-W3 rebuild cron + CF-E5 (optional) | `cloudflare.endpoint`, `feedback` | companion Worker with route `/api/*`, D1 `feedback`, Cron Trigger | GitHub dispatch token, export token | remove keys → rebuild → 1.7 prefilled-issue links return; delete Worker |
| `open-blog` | open | `edge-basic` + CF-W2 forms (contact, "notify me" list, owner mail) + CF-W1 reactions-style feedback + CF-W3 | `endpoint`, `forms`, `feedback` | Worker, D1 `forms`, `send_email` binding to a verified address, Email Routing on the domain | export token, (Turnstile secret if used) | remove keys → forms fall back to `subscribe.action` / `form.action` if set, else text only |
| `free-community` | free (card on file) | `open-blog` + CF-A2 Access on admin routes + CF-R2-ready R2 bucket for attachments-free exports | as `open-blog` | Worker, D1, Access application (one-time PIN or GitHub IdP), R2 bucket with code-side cap, budget alert at $1 | Access service token for Actions | as `open-blog`; Access app deleted last |
| `paid-product` | paid | `free-community` + double opt-in email + CF-J1 edge OG images + CF-R3 downloads + CF-P1 edge push sending (from 1.9) + optional CF-S1 AI Search | `endpoint`, `forms`, `og.base`, `downloads.via`, (`pwa.push` in 1.9), (`search.endpoint` 1.9+) | Workers Paid, Browser Run binding, Queues, Email Sending domain onboarding (SPF/DKIM/DMARC), AI Search instance | VAPID private key, email sender config, dispatch token | each key removed independently; OG falls back to J2 image after rebuild; downloads link straight to GitHub |

**Mapping to starters.** The starter catalog (`example/starters.yml`: docs, blog, landing; planned site groups from
the recipes: product, company, documentation, personal, community, system) maps as:

| Starter | Suggested preset | Why |
|---|---|---|
| docs (and documentation group) | `open-docs` | headers, redirects for moved pages, helpful counts, rebuilds |
| blog, personal | `open-blog` | contact and notify-me forms; OG images via build-time first |
| landing, product, company | `edge-basic` → `paid-product` | downloads and release surfaces (R1/R3), OG images, double opt-in |
| community | `free-community` | moderation/export behind Access |
| system (status, error pages) | `edge-basic` | headers and cache only; no endpoints on error pages |

Rendered starters stay GitHub-Pages-only by default; `rake starters:render` can add a commented `cloudflare:` block
and a `docs/cloudflare.md` pointer, never a Worker.

**Mapping to `modootoday.csp`.** `csp: strict` is unchanged and remains the base. Presets declare only additions,
and `modootoday-check --csp-policy` prints the final policy:

| Preset / key | Addition to the strict base |
|---|---|
| any preset, same-origin endpoint | none (`'self'` covers `connect-src` and `form-action`) |
| separate-origin endpoint | `connect-src <origin>`, `form-action 'self' <origin>` |
| `turnstile` | `script-src https://challenges.cloudflare.com`, `frame-src https://challenges.cloudflare.com` |
| CF-E5 reports | `report-to csp` + `Reporting-Endpoints: csp="/api/csp-report"` (header only) |
| CF-E1 headers | `frame-ancestors 'none'` (header only), `upgrade-insecure-requests` |
| Web Analytics (not recommended) | `script-src https://static.cloudflareinsights.com`, `connect-src https://cloudflareinsights.com` (manual setup) |

---

## 6. Dependencies on 1.7 and 1.8 items

| Cloudflare item | Depends on |
|---|---|
| CF-E3 `sw.js` bypass | 1.7 15b service worker |
| CF-E4 header rules | 1.8 B5 |
| CF-W1 | 1.7 C3 footer links (fallback) |
| CF-W2 | existing `c: subscribe`, `contact` layout |
| CF-W3 | 1.7 R6/G6 starter workflow triggers |
| CF-J1 | 1.7 J2 (alt, size, fallback), 1.8 J1 |
| CF-R3 | 1.8 R3 |
| CF-P1 | 1.7 15b worker in the field, 16b install section (iOS hint) |
| CF-S1 | 1.8 B2 index shape |
| CF-E2 | 1.6 alias planner; any 1.7 recipes regroup that moves URLs |

---

## 7. How the theme should package Cloudflare companions

- **One companion repository**, separate from the gem: `jekyll-theme-modootoday-cloudflare` (name to be decided in the
  ADR). One Worker with feature modules (`feedback`, `forms`, `rebuild`, `downloads`, `og`, `csp-report`, later
  `push`, `search`), each enabled by its binding or variable being present, so an owner deploys one Worker and one
  route. Per-feature repositories would multiply routes, secrets and versions for the same small site.
- Inside it: `rules/` (zone rules as JSON for the dashboard import and as Terraform), `presets/<name>.jsonc` (Wrangler
  config fragments), `schema/` (D1 migrations), `templates/` (owner mails in en/ko/ja), a Deploy to Cloudflare button
  (https://developers.cloudflare.com/workers/platform/deploy-buttons/ via the template binding descriptions).
- **Versioning.** The theme defines and documents an **edge endpoint contract** (`reference/edge-contract` in the docs:
  paths, methods, fields, status codes, the 303 + fragment convention, CORS for the separate-origin case). The
  contract has its own version (`edge v1`). The companion's major version equals the contract version it implements;
  the theme's public API policy (adr 20261029204501) covers the contract like any other public API: additive in
  minors, breaking only in a theme major. The theme tests the **client side** against a fixture server that
  implements the contract (no Cloudflare in theme CI); the companion's CI runs its Worker in local Workers runtime
  against the theme's example site.
- **GitHub Pages stays first-class.** No theme feature requires a layer; every `modootoday.cloudflare` key is off by
  default; every feature has a documented GitHub Pages floor (meta CSP, redirect stubs, prefilled links, form
  services, build-time OG images, direct downloads); docs QA keeps running on plain GitHub Pages and adds one job
  against the fixture server; the docs site never depends on Cloudflare (and, on its `github.io` host, cannot).
- **Docs placement.** One recipe "Run Cloudflare in front of GitHub Pages" (layers, tiers, presets, enable/disable
  order) in the regrouped recipes sidebar (1.7 ordering item, so it counts against the 12-entry cap there), plus one
  section each in the CSP, search, blog and download docs. Public wording names the products, never an account.

---

## 8. Rejected

| Idea | Reason |
|---|---|
| Move hosting to Cloudflare Pages or Workers static assets (`_headers`, `_redirects`, preview deployments) | Replaces the origin instead of layering; operator rule keeps GitHub Pages as origin and default. Keep as a documented alternative only: it would give `_headers`/`_redirects` (2,100 redirects, 100 header rules, https://developers.cloudflare.com/workers/static-assets/redirects/) and previews, but L1 rules already give headers and redirects in front of GitHub Pages |
| Zaraz | Loads and proxies third-party tools; contrary to no-third-party default |
| Web Analytics beacon as a default | Third-party script and endpoint for manual setup; automatic setup still injects a script from Cloudflare's host; zone analytics need no client code |
| Automatic RUM injection, Rocket Loader, Email Address Obfuscation | Inject scripts or rewrite HTML; break strict CSP and byte-exact guarantees (CF-E0 turns them off) |
| Access as "private docs" for a GitHub Pages site | The `github.io` URL and the public repository expose the same content; Access protects a hostname, not the origin |
| Self-hosted comments on Workers + D1 | An application (identity, moderation, spam, deletion, mail), not a layer; G7 covers the demand |
| Runtime GitHub Releases proxy | Releases are rendered at build time and refreshed by R6; a runtime fetch adds a request per view for data already in the page |
| Workers AI translation drafts or summaries in the theme | Conflicts with localisation rules and the linted style guide; generated text in `llms.txt` would misdescribe the site; at most site tooling |
| Durable Objects live counters or presence | Overkill; D1 or zone analytics suffice |
| Link checking at the edge | 50 external subrequests per invocation on Free; Actions and L1 (1.7) are the right place |
| Snippets for header logic | Not on the Free plan's published limits (Pro and above in the 2025 limits change); Transform Rules cover the need |
| Turnstile on by default for forms | Third-party script; default abuse controls are honeypot, timing, Origin check and rate limits; Turnstile stays an explicit key |
| A Satori/resvg OG renderer on Workers Free | 10 ms CPU and multi-MB CJK fonts; the og-card + Browser Run route or build-time rendering instead |
| Bot Fight Mode on a strict-CSP theme site without a header nonce | JavaScript Detections need a nonce from a CSP header; with a meta CSP they cause violations |

---

## 9. Spikes before committing

1. GitHub Pages custom domain behind a proxied record: certificate renewal, "Enforce HTTPS", SSL mode (CF-E1..E4).
2. `Speculation-Rules` header pointing at a GitHub-Pages-served JSON with a Content-Type rewrite; whether Speed Brain
   treats a Transform-Rule header as origin-sent (CF-E4).
3. Whether a Transform-Rule `Link` header feeds Early Hints (CF-E6).
4. Free-plan counts for Transform, Cache and rate limiting rules in the current dashboard (§2.1).
5. Whether enabling R2 prompts for a payment method on an account with none (§2.2).
6. D1 FTS5 and the `trigram` tokenizer for CJK (CF-S1).
7. WebCrypto cost per push message (ECDH + HKDF + AES-GCM) against the 10 ms Free CPU limit (CF-P1).
8. Browser Run screenshot of an og-card page with Korean, Japanese, Arabic and Hebrew titles at 1200 × 630, time per
   image against 10 browser-minutes/day (CF-J1).
9. Turnstile language coverage against the theme's 23 languages and its behaviour in RTL pages (CF-W2).

## 10. Sources

Cloudflare (developers.cloudflare.com): Workers limits and pricing (/workers/platform/limits/,
/workers/platform/pricing/), Wrangler limits (/workers/wrangler/configuration/#limits), KV pricing
(/kv/platform/pricing/), D1 pricing and free-tier enforcement (/d1/platform/pricing/,
/changelog/post/2026-09-01-d1-free-tier-limit-enforcement/), Durable Objects pricing
(/durable-objects/platform/pricing/), Queues pricing and free plan (/queues/platform/pricing/,
/changelog/post/2026-02-04-queues-free-plan/), R2 pricing (/r2/pricing/), Basin SQL note on R2 subscription and card
(/basin-sql/platform/pricing/), Workers AI pricing and paid-only models (/workers-ai/platform/pricing/,
/changelog/post/2026-07-28-models-require-workers-paid/), Browser Run limits and pricing (/browser-run/limits/,
/changelog/post/2025-07-28-br-pricing/), Images pricing (/images/pricing/), AI Search limits and pricing
(/ai-search/platform/limits-pricing/), Email Service pricing, limits and destination addresses
(/email-service/platform/pricing/, /email-service/platform/limits/,
/email-service/configuration/email-routing-addresses/), Turnstile (/turnstile/,
/turnstile/get-started/client-side-rendering/, /turnstile/get-started/server-side-validation/), Transform Rules and
response headers (/rules/transform/, /rules/transform/response-header-modification/), duplicate CSP header guidance
(/client-side-security/troubleshooting/), Redirects availability (/rules/url-forwarding/), Bulk Redirects
(/rules/url-forwarding/bulk-redirects/create-api/), Rules limits change (/changelog/post/2025-02-12-rules-upgraded-limits/),
Speed Brain (/speed/optimization/content/speed-brain/), Web Analytics FAQ (/web-analytics/faq/), Bot Fight Mode
(/bots/get-started/bot-fight-mode/), Zero Trust setup (/cloudflare-one/setup/), Access application types
(/cloudflare-one/access-controls/applications/choose-application-type/), budget alerts
(/changelog/post/2026-06-15-budget-alerts-default-on/,
/changelog/post/2026-04-13-billable-usage-dashboard-and-budget-alerts/), static assets redirects
(/workers/static-assets/redirects/), Deploy buttons (/workers/platform/deploy-buttons/).

Web platform and GitHub: as listed in the 1.7 research (Push API, RFC 8030/8291/8292, WebKit web push for Home Screen
apps, Speculation Rules API, GitHub Actions events and secrets, scheduled workflow inactivity, release asset digests).

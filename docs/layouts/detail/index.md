---
title: Detail pages
description: One page per project, case study, job, event or podcast episode, with a facts list, one call to action and structured data.
nav_order: 30
---
# Detail pages

A detail page shows one item: a header, a list of facts read from front matter, the body and one call to action. These layouts load `modootoday-detail.css` only on their own pages and add no JavaScript. Each one prints a schema.org main entity built from the same front matter; a `schema:` map overrides any property.

| Layout | Facts | Call to action | Structured data | Demo |
|---|---|---|---|---|
| `project` | client, role, year, stack, links | `cta` | CreativeWork | [Project](/jekyll-theme-modootoday/layouts/detail/project/) |
| `case-study` | client, role, year, stack, links | `cta` | Article | [Case study](/jekyll-theme-modootoday/layouts/detail/case-study/) |
| `job` | location, employment, salary, posted, deadline | Apply (`apply`) | JobPosting | [Job](/jekyll-theme-modootoday/layouts/detail/job/) |
| `event` | starts, ends, venue, online | Tickets and an .ics file | Event | [Event](/jekyll-theme-modootoday/layouts/detail/event/) |
| `episode` | season and episode, posted, duration; audio player | `cta` | PodcastEpisode | [Episode](/jekyll-theme-modootoday/layouts/detail/episode/) |

## Job

```yaml
---
layout: job
title: Technical writer
description: Write and maintain the product documentation.
date: 2026-10-01          # datePosted
deadline: 2026-12-01      # validThrough
employment: full-time     # full-time, part-time, contractor, temporary, intern, volunteer, per-diem, other
location: Seoul           # or remote: South Korea (the country applicants must live in)
salary: {min: 50000, max: 70000, currency: USD, unit: year}
apply: mailto:jobs@example.com
---
```

The hiring organization is the site publisher (`modootoday.schema.publisher`). `modootoday-check` reports a job without `date`, without `location` or `remote`, or with an unknown `employment`.

## Event

```yaml
---
layout: event
title: Theme meetup
starts: 2026-11-20 19:00:00 +0900
ends: 2026-11-20 21:00:00 +0900
venue: Hall A             # a place, an online URL, or both
address: 1 Main St, Seoul
online: https://example.com/live
tickets: https://example.com/tickets
---
```

The calendar link is an .ics file in a `data:` URL, so it works without a server.

## Episode

```yaml
---
layout: episode
title: Pilot
date: 2026-10-10
season: 1
episode: 3
duration: 42              # minutes
audio: /media/ep3.mp3
transcript: /podcast/3/transcript/
---
```

The player is the browser's own `<audio controls>`; it loads nothing until it is played.

## Project and case study

```yaml
---
layout: project           # or case-study (an Article with author and dates)
title: Atlas
client: ACME
role: Design and build
year: 2026
stack: [Jekyll, Sass]
links:
  - {label: Repository, url: "https://example.com/atlas"}
cta: {label: Contact us, url: /contact/}
---
```

## Accessibility

The article is labelled by its heading, facts are a description list, and links that repeat (Apply, Tickets) name the page for screen readers. Print hides the call to action and the player.

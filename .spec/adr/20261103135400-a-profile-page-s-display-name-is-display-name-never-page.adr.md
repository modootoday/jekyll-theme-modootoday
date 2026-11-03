---
id: adr:modootoday/20261103135400
title: "A profile page's display name is display_name, never page.name"
status: active
created: 2026-11-03T13:54:00Z
updated: 2026-11-03T13:54:16Z
rel:
  governs: [_includes/modootoday/profile/name.html]
---

# A profile page's display name is display_name, never page.name

## Context

The `resume` and `links` docs told users to set `name:`, and `_layouts/resume.html` and `_includes/modootoday/jsonld/profile.html` read `page.name`. For a page, Jekyll puts its file name in `name` after the front matter (`ATTRIBUTES_FOR_LIQUID` on Jekyll 3.10 and 4), so the heading and the JSON-LD `name` were `resume.md` (`resume.ko.md` in a translation) in every language and on both builders. Liquid cannot read the front matter value on a page at all. On a collection document, Jekyll keeps a front matter `name`.

## Decision

- The key is `display_name:`. Jekyll does not shadow it, and it fits both a Person and an Organization (`profile: organization` on a links page), which `person.name` or `author_name` would not.
- `_includes/modootoday/profile/name.html` owns the rule and sets `mt_profile_name`; the resume heading and the ProfilePage `mainEntity` read only that. The order is `display_name`, then a `name` that differs from the last part of `page.path` (a value Jekyll kept, on a collection document), then the title. The file name is never used.
- `lib/modootoday/check/layouts/profile.rb` owns the checker side for the same layouts (`resume`, `links`): a page with `name:` gets a rename warning, a page with neither key a warning that the title is shown. A `resume` with neither `display_name:` nor a title stays an error (the old message named `name:`).
- No plugin copies `name:` into `display_name:`: the classic GitHub Pages builder would not run it, and the two builders would print different names.

## Consequences

Sites that followed the old docs now see their title instead of the file name, and a checker warning until they rename the key. The docs demo pages and their translations change their heading and JSON-LD name from the file name to the person's or organization's name.

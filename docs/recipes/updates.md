---
nav_order: 28
title: Tell readers about updates
description: Feeds, GitHub release notifications, an email form and the app's notice tell readers what changed; rebuild the site when a release is published.
---
# Tell readers about updates

A static site cannot reach its readers on its own, so the theme gives readers ways to pick up the news when they want it. Choose the channels that suit your readers; each one works without the others.

| Channel | Who it suits | What you set up |
|---|---|---|
| Atom feed | readers with a feed reader, and tools that watch sites | a `feed.xml` page per language |
| GitHub release notifications | people who use your project on GitHub | nothing beyond publishing releases on GitHub |
| Email form | readers who want an email when something ships | a `c: subscribe` section and a mail service |
| Update notice | readers of the installed app | `modootoday.pwa` |

## Feeds

Add a `feed.xml` page with `layout: feed` in each language folder; every page then links its language's feed in the head, so a feed reader finds it from any page address. See [Authors and feeds](../../layouts/blog-news/#authors-and-feeds). A feed is a file on your site: nobody signs up, and you learn nothing about who reads it.

When you publish releases on GitHub, GitHub keeps a feed of them at `https://github.com/OWNER/REPO/releases.atom`. Link it from your changelog or news page for readers who want releases only.

## GitHub release notifications

Readers with a GitHub account can open your repository, choose Watch, then Custom, and tick Releases. GitHub then tells them about each release you publish, on GitHub or by email, as they set in their [notification settings](https://docs.github.com/en/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/configuring-notifications). Say so on your install or changelog page.

## An email form

A `c: subscribe` section prints your text and an email form that posts to your mail service (`modootoday.subscribe.action`). The service keeps the addresses and sends the emails; the theme only draws the form. See [Subscribe](../../components/#subscribe).

## The installed app

With `modootoday.pwa` on, an open app shows a short notice when a deploy changes the theme files, and pages always come from the network first. See [Updates](../pwa/#updates) in the installable site recipe. The notice reaches only readers who have the site open; it is not a notification.

## Why there is no push

Push notifications need a server that keeps every reader's subscription, a permission prompt, and a push service run by the browser vendor. A theme for static sites has no server, and it sends nothing anywhere, so it ships no push. The channels above need no server of yours, and a reader can leave any of them without asking you.

## Rebuild when a release is published

GitHub Pages builds your site when you push. Data the build reads from GitHub, such as releases or repository details in `site.github`, therefore stays as it was at the last push: publishing a release does not rebuild the site.

The starters' Pages workflow (`.github/workflows/pages.yml`) rebuilds the default branch when a release is published, and it carries a weekly rebuild you turn on by uncommenting `schedule`. In your own [Pages workflow](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages), add the same triggers:

```yaml
on:
  push:
    branches: [main]
  release:
    types: [published]
  schedule:
    - cron: "17 3 * * 1"   # Mondays at 03:17 UTC
```

- A release run starts on the release's tag, and the `github-pages` environment usually lets only the default branch deploy. The starters' workflow therefore starts itself again on the default branch (`gh workflow run pages.yml --ref main`, which needs `permissions: actions: write`) instead of building the tag.
- GitHub turns a scheduled workflow off after 60 days without activity in a public repository. Turn it back on in the Actions tab.
- A site that GitHub builds from a branch (Settings, Pages, Deploy from a branch) has no workflow to add triggers to. Push a commit after the release, or switch the Pages source to GitHub Actions.

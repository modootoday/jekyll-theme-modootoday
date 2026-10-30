---
nav_order: 10
title: Install
description: Add the theme to a GitHub Pages or Jekyll 4 site.
sections:
  - {c: tabs, name: methods}
  - minimal
  - check
  - {c: cta, name: next}
---
# Install

Pick the build you already use. All three read the same Markdown.

## Choose a method

### GitHub Pages

```yaml
# _config.yml (classic GitHub Pages build, no Gemfile needed)
remote_theme: modootoday/jekyll-theme-modootoday@v1.1.1
plugins: [jekyll-remote-theme]
```

### Jekyll 4

```ruby
# Gemfile
source "https://rubygems.org"
gem "jekyll", "~> 4.4"
gem "jekyll-theme-modootoday", "~> 1.1"
```

### github-pages gem

```ruby
# Gemfile (reproduce GitHub Pages locally)
source "https://rubygems.org"
gem "github-pages", "~> 232", group: :jekyll_plugins
```

## Minimal configuration

Use pretty permalinks and the `doc` layout for every page:

```yaml
theme: jekyll-theme-modootoday
lang: en
permalink: pretty
markdown: kramdown
kramdown: {input: GFM}
defaults:
  - {scope: {path: ""}, values: {layout: doc}}
```

> [!TIP]
> With `remote_theme`, replace the `theme:` line with the two `remote_theme` lines from the GitHub Pages tab.

## Verify the build

```sh
bundle exec jekyll build
bundle exec modootoday-check . _site --twins
```

The checker reports any syntax that would not render the same on github.com.

A `remote_theme` site has no Gemfile entry for the theme. Install the gem once to get the checker, then run it on the built site:

```sh
gem install jekyll-theme-modootoday
modootoday-check . _site --twins
```

If the shell cannot find `modootoday-check` after `gem install`, the gem's bin directory is not on `PATH`: run `ruby -S modootoday-check . _site --twins`, or call `"$(gem env gemdir)/bin/modootoday-check"`; `gem contents jekyll-theme-modootoday | grep bin/` shows where the script is.

In GitHub Actions, add the same two lines as a step after the build, for example `run: gem install jekyll-theme-modootoday && modootoday-check docs docs/_site --twins`.

Two warnings from the `github-pages` gem are harmless: `To use retry middleware with Faraday v2.0+, install faraday-retry gem` (the remote theme download still works), and Sass notices about `@import`. GitHub Pages uses an older Sass that does not read the Sass silencing option, so the notices appear even when your `_config.yml` sets it. The build output is correct either way.

## Next

[Write your first page](../first-page/) [Back to home](../../)

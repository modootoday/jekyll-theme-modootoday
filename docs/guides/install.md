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
remote_theme: modootoday/jekyll-theme-modootoday@v1.4.1
plugins: [jekyll-remote-theme]
```

### Jekyll 4

```ruby
# Gemfile
source "https://rubygems.org"
gem "jekyll", "~> 4.4"
gem "jekyll-theme-modootoday", "~> 1.4"
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

A `remote_theme` site has no Gemfile entry for the theme, so `bundle exec modootoday-check` is not available. Install the gem once, at the same minor version as the theme tag, and run the checker on the built site:

```sh
gem install jekyll-theme-modootoday -v '~> 1.4'
modootoday-check . _site --twins
```

If the shell cannot find `modootoday-check`, the gem's bin directory is not on `PATH`: run `ruby -S modootoday-check . _site --twins`. If it stops with `can't find gem jekyll-theme-modootoday (Gem::GemNotFoundException)`, the script on `PATH` belongs to another gem location (another Ruby, or `GEM_HOME`/`GEM_PATH` set by a version manager). Point Ruby at the place `gem install` used:

```sh
GEM_PATH="$(gem env gemdir)" ruby -S modootoday-check . _site --twins
```

Without installing a gem, run the checker from the release source. It needs only Ruby:

```sh
curl -sL https://github.com/modootoday/jekyll-theme-modootoday/archive/refs/tags/v1.4.1.tar.gz | tar xz -C /tmp
ruby /tmp/jekyll-theme-modootoday-1.4.1/exe/modootoday-check . _site --twins
```

Use the tag your `remote_theme` line names.

In GitHub Actions, add the same two lines as a step after the build, for example `run: gem install jekyll-theme-modootoday -v '~> 1.4' && modootoday-check docs docs/_site --twins`.

Two warnings from the `github-pages` gem are harmless: `To use retry middleware with Faraday v2.0+, install faraday-retry gem` (the remote theme download still works), and Sass notices about `@import`. GitHub Pages uses an older Sass that does not read the Sass silencing option, so the notices appear even when your `_config.yml` sets it. The build output is correct either way.

## Next

[Write your first page](../first-page/) [Back to home](../../)

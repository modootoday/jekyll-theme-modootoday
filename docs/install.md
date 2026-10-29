---
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
remote_theme: modootoday/jekyll-theme-modootoday
plugins: [jekyll-remote-theme]
```

### Jekyll 4

```ruby
# Gemfile
source "https://rubygems.org"
gem "jekyll", "~> 4.4"
gem "jekyll-theme-modootoday"
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

## Next

[Write your first page](../first-page/) [Back to home](../)

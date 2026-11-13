---
nav_order: 10
title: Install
description: Add the theme to a classic GitHub Pages site or a Jekyll 4 site, start from a starter template, and check the build with the theme's checker.
sections:
  - requirements
  - {c: tabs, name: methods}
  - minimal
  - check
  - starters
  - next
---
# Install

Pick the build you already use. All three read the same Markdown.

## Requirements

- GitHub Pages with `remote_theme`: the classic build (`github-pages` 232, Jekyll 3.10).
- Jekyll 4.4 with the theme gem, on Ruby 3.3 or 3.4.
- The oldest Jekyll the tests run on is 3.9.

## Choose a method

### GitHub Pages

```yaml
# _config.yml (to build locally, see the github-pages gem tab)
remote_theme: modootoday/jekyll-theme-modootoday@v1.7.0
plugins: [jekyll-remote-theme]
```

### Jekyll 4

```ruby
# Gemfile
source "https://rubygems.org"
gem "jekyll", "~> 4.4"
gem "jekyll-theme-modootoday", "~> 1.7"
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
sass: {silence_deprecations: [import, global-builtin]}   # Jekyll 4: no Dart Sass @import notices
defaults:
  - {scope: {path: ""}, values: {layout: doc}}
```

> [!TIP]
> With `remote_theme`, replace the `theme:` line with the two `remote_theme` lines from the GitHub Pages tab.
>
> To build that site on your machine with the github-pages gem, also add `repository: <owner>/<name>` (your GitHub repository), or set the environment variable `PAGES_REPO_NWO=<owner>/<name>`. Without either, outside a clone with a GitHub `origin` remote, the build stops with "No repo name found. Specify using PAGES_REPO_NWO environment variables, 'repository' in your configuration, or set up an 'origin' git remote pointing to your github.com repository." GitHub Pages itself sets it.

The `sass:` line keeps a Jekyll 4 build from printing thousands of Dart Sass notices about `@import`; the output is the same either way.

## Verify the build

`--twins` also checks the files the theme publishes for AI agents ([AI agents](../agents/)): a Markdown twin of each page, and `llms.txt` and `llms-full.txt`. On Jekyll 4, add `plugins: [jekyll-theme-modootoday]` and the build makes them. On classic GitHub Pages, run `modootoday-stubs . --twins --write` once to add a twin stub beside each page, and add two files at the site root that hold only front matter: `llms.txt` with `layout: llms` and `llms-full.txt` with `layout: llms-full`. Error pages (`layout: error`, such as `404.md`) never get a twin; any other page that should not have one sets `twin: false`. To check only the Markdown, leave `--twins` out.

```sh
bundle exec jekyll build
bundle exec modootoday-check . _site --twins
```

The checker reports any syntax that would not render the same on github.com.

Add `--links` to also check the built site's links: same-site links to missing pages and `#` links to missing anchors. It needs the nokogiri gem, which the `github-pages` bundle already includes; elsewhere add `gem "nokogiri"` to the Gemfile, or run `gem install nokogiri` next to the checker. Without nokogiri, `--links` fails the run with an error that says to add `gem "nokogiri"`.

A `remote_theme` site has no Gemfile entry for the theme, so `bundle exec modootoday-check` is not available. Install the gem once, at the same minor version as the theme tag, and run the checker on the built site:

```sh
gem install jekyll-theme-modootoday -v '~> 1.7'
modootoday-check . _site --twins
```

If the shell cannot find `modootoday-check`, the gem's bin directory is not on `PATH`: run `ruby -S modootoday-check . _site --twins`. If it stops with `can't find gem jekyll-theme-modootoday (Gem::GemNotFoundException)`, the script on `PATH` belongs to another gem location (another Ruby, or `GEM_HOME`/`GEM_PATH` set by a version manager). Point Ruby at the place `gem install` used:

```sh
GEM_PATH="$(gem env gemdir)" ruby -S modootoday-check . _site --twins
```

Without installing a gem, run the checker from the release source. It needs only Ruby:

```sh
curl -sL https://github.com/modootoday/jekyll-theme-modootoday/archive/refs/tags/v1.7.0.tar.gz | tar xz -C /tmp
ruby /tmp/jekyll-theme-modootoday-1.7.0/exe/modootoday-check . _site --twins
```

Use the tag your `remote_theme` line names.

In GitHub Actions, add the same two lines as a step after the build, for example `run: gem install jekyll-theme-modootoday -v '~> 1.7' && modootoday-check docs docs/_site --twins`.

Two warnings from the `github-pages` gem are harmless: `To use retry middleware with Faraday v2.0+, install faraday-retry gem` (the remote theme download still works), and Sass notices about `@import`. GitHub Pages uses an older Sass that does not read the `sass: silence_deprecations` option, so the notices appear even when your `_config.yml` sets it. The build output is correct either way.

## Starter sites

The theme has three starter sites, each a template repository on GitHub with its own live demo: [docs](https://github.com/modootoday/jekyll-theme-modootoday-docs-starter) (a guide, pages from data, Korean and Japanese in `ko/` and `ja/`), [blog](https://github.com/modootoday/jekyll-theme-modootoday-blog-starter) (posts, a news article, an author page and a feed) and [landing](https://github.com/modootoday/jekyll-theme-modootoday-landing-starter) (a hero, pricing and a legal page). To start from one, open its repository, choose **Use this template** and turn on GitHub Pages with GitHub Actions as the source. The copy loads the theme with `remote_theme` and has a `Gemfile`, a `README.md`, the stubs, and a Pages workflow that builds the site, runs `modootoday-check` and deploys it. It also has `_config.demo.yml`, the settings of that starter's own live demo (the [showcase](../../reference/showcase/) bar or pill and `noindex`). The workflow merges them into the build only in the starter's own repository, so your copy builds without them, and you can delete the file. For Jekyll 4 with the theme gem, run `bundle exec rake starters:render` in a clone of the theme repository (with `--recurse-submodules`) and copy `pkg/starters/jekyll4/<name>/` instead.

## Try the next release

This is optional. To try changes that are on the main branch but not released yet, point the theme at `main` instead of a release.

```ruby
# Gemfile
gem "jekyll-theme-modootoday", git: "https://github.com/modootoday/jekyll-theme-modootoday", branch: "main"
```

```yaml
# _config.yml with remote_theme
remote_theme: modootoday/jekyll-theme-modootoday@main
```

Run `bundle install`, and later `bundle update jekyll-theme-modootoday` to move to the newest commit. With the Gemfile line, `bundle exec modootoday-check` runs the checker from the same commit. The main branch can change at any time, so pin a release again before you publish the site.

# frozen_string_literal: true
# Pins the complete modootoday-check output (every message, its order, the exit status) on small sites,
# so a refactor of lib/modootoday/check cannot change what users see. Refresh on purpose: SNAPSHOT_UPDATE=1.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class MessagesSnapshotTest < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)
  SNAPSHOTS = File.expand_path("../fixtures/checker", __dir__)
  CORPUS = File.expand_path("../fixtures/md", __dir__)
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  # Keys are listed out of the order the checker reports them, so the report order is pinned too.
  CONFIG_BAD = <<~YAML
    modootoday:
      tokens: [primary]
      tokens_dark: red
      math: {enabled: true, engine: mathjax, integrity: x, inline: maybe, colour: red, src: "http://cdn.example/katex.js", css: "https://cdn.example/katex@latest/katex.css"}
      mermaid: {enabled: maybe, theme: pink, colour: red}
      components: callout
      sidebar: left
      banner: {url: /x/}
      header: {compact_title: maybe}
      css: inline
      loading: maybe
      back_to_top: maybe
      page_actions: maybe
      feed: maybe
      hreflang: maybe
      seo: maybe
      badges: maybe
      css_layers: 1
      edit_url: github.com/x
      archive: [tags]
      lists: {link_chips: true, other: true}
      full_languages: ko
      languages: [en, Korean]
      csp: loose
      color_scheme: blue
      twins: maybe
  YAML

  CONFIG_NESTED = <<~YAML
    modootoday:
      mermaid: on
      math: {enabled: true}
      tokens_dark: {primary: '#fb923c}x', bogus: ''}
      tokens: {primary: '#c2410c', accent: '#zz0000', foo: '1rem', ring: 'a;b', muted: '#abcd'}
      components: [callout, carousel, code-copy, slider]
      banner: {text: Hi}
      feed: true
      archive: {tags: tags/, categories: /c/}
      lists: {link_chips: true, titled_items: 1}
      full_languages: [ko, ja]
      languages: [en, ko]
      twins: true
  YAML

  CONFIG_OK = <<~YAML
    plugins: [jekyll-feed]
    modootoday:
      twins: true
      color_scheme: auto
      csp: strict
      languages: [en, ko]
      full_languages: [ko]
      lists: {link_chips: true, titled_items: false}
      header: {compact_title: false}
      archive: {tags: /tags/, categories: /categories/}
      edit_url: https://git.example/o/r/edit/main/
      css_layers: true
      badges: false
      seo: true
      hreflang: true
      feed: true
      page_actions: false
      back_to_top: true
      loading: false
      css: bundle
      banner: {text: Hi, url: /x/}
      sidebar: auto
      components: [callout, code-copy]
      tokens: {primary: '#c2410c', radius: 0.5rem}
      tokens_dark: {primary: 'oklch(0.6 0.2 40)'}
      mermaid: {enabled: true, src: /assets/mermaid.js, theme: dark}
      math: {enabled: true, inline: true, src: "https://cdn.example/katex@0.16.11/katex.min.js", css: "https://cdn.example/katex@0.16.11/katex.min.css", integrity: {js: sha384-AAAA, css: sha384-BBBB}, auto_render_src: /assets/auto.js}
  YAML

  RENDERERS = <<~YAML
    modootoday:
      mermaid: {enabled: true, src: "https://cdn.example/mermaid@11.4.1/mermaid.min.js", integrity: sha384-MMMM}
      math: {enabled: true, src: /assets/katex.js, css: /assets/katex.css, integrity: {js: nope}}
  YAML

  M = "https://cdn.example/mermaid@11.4.1/mermaid.min.js"

  SITES = {
    "config-bad" => { src: { "_config.yml" => CONFIG_BAD, "index.md" => "---\n---\n# A\n" } },
    "config-nested" => { src: { "_config.yml" => CONFIG_NESTED, "index.md" => "---\n---\n# A\n\nPay $x$ now.\n" } },
    "config-ok" => { src: { "_config.yml" => CONFIG_OK, "index.md" => "---\n---\n# A\n\nInline $x$ math.\n" }, flags: ["--strict"] },
    "config-source" => {
      src: { "_config.yml" => "optional_front_matter: {remove_originals: true}\nrequire_front_matter: true\nmodootoday: {twins: source}\n",
             "index.md" => "# Home\n", "guide.md" => "# Guide\n", "kept.md" => "---\ntitle: K\n---\n# K\n", "kept.md.txt" => "---\nlayout: twin\n---\n" },
      site: { "index.html" => "<p>x</p>", "index.md" => "# Home\n", "guide.md" => "# Changed\n", "llms.txt" => "# S\n", "llms-full.txt" => "# Home\n" },
      flags: ["--twins"],
    },
    "config-not-a-map" => { src: { "_config.yml" => "modootoday: [a]\n", "index.md" => "---\n---\n# A\n" } },
    "renderers" => {
      src: { "_config.yml" => RENDERERS, "a.md" => "---\n---\n# A\n\nCosts $5 or $x+1$.\n\n```math\nx\n```\n" },
      site: { "a/index.html" => %(<script src="#{M}" integrity="sha384-MMMM" crossorigin="anonymous"></script><script src="#{M}" integrity="sha384-OTHER"></script>) +
                                %(<script src="https://evil.example/x.js"></script><link rel="stylesheet" href="//fonts.example/f.css"><link rel="preconnect" href="https://x.example">) +
                                %(<script src="#{M}"></script>) },
    },
    "pages" => {
      src: {
        "_config.yml" => "modootoday: {blog: {variant: cards, per_page: ten, colour: red, share: maybe}, news: {sections: world}}\n",
        "_data/authors.yml" => "kim: {url: example.com}\n",
        "_data/components.yml" => "features: {params: {cols: {allowed: [2, 3], required: true}}, slots: {items: {min: 3, max: 2}}, colour: red}\n" \
                                  "tabs: {i18n: [tabs.label, hero.cta], slots: {panels: {min: 2}}}\ncta: {slots: {actions: {required: true}, bogus: {}}, parts: [.mt-cta, .mt-gone]}\n",
        "_data/i18n/en.yml" => "skip: Skip\ntoc: {label: On this page}\nhero: {cta: Start}\n",
        "_data/i18n/ko.yml" => "skip: 건너뛰기\ntoc: {lable: 목차}\n",
        "a.md" => "---\nsections: [{c: features, cols: 4}, {c: nope}, {c: tabs}, {c: cta}]\n---\n# A\n\n## F\n\n- one\n\n## N\n\n## Tabs\n\n### Only\n\n## Next\n\nNo links.\n",
        "b.md" => "---\n---\n`status:done` `tag:two words` `since:1.0` `kbd:a b` `progress:120`\n\n![](x.png)\n\n[here](https://x.example)\n\n> [! NOTE]\n> x\n",
        "ko/a.md" => "---\n---\n# A\n", "ko/c.md" => "---\n---\n# C\n",
        "api.md" => "---\n---\n# API\n\n## Component structure\n\n| C | Parts |\n|---|---|\n| CTA | `.mt-cta` |\n",
        "e.md" => "---\nlayout: error\nstatus: 403\n---\n# E\n", "r.md" => "---\nlayout: redirect\n---\n# R\n",
        "h.md" => "---\nlayout: home\nhero: {actions: [{label: Go}]}\n---\n# H\n",
        "blog.md" => "---\nlayout: blog\nvariant: tiles\n---\n# Blog\n", "authors/x.md" => "---\nlayout: author\n---\n",
        "_posts/2026-10-01-a.md" => "---\ntitle: A\nauthor: lee\nbreaking: yes please\nsources: Agency\n---\n# A\n",
      },
      site: { "a/index.html" => %(<section class="mt-section mt-cta" data-c="cta"></section>) },
    },
    "build" => {
      src: { "index.md" => "---\ntitle: T\n---\n# T\n", "index.md.txt" => "---\nlayout: doc\n---\n", "g.md" => "---\n---\n# G\n",
             "Gemfile.lock" => "GEM\n  specs:\n    github-pages (231)\n",
             "_sass/x.scss" => "// @use 'ok';\n@use 'sass:map';\n@forward 'y';\n@supports selector(:has(a)) { a { b: c } }\n" },
      site: {
        "index.md" => "# T changed\n", "llms.txt" => "no heading\n", "llms-full.txt" => "# T\n",
        "a.css" => "@use \"x\";\n:root { --mt-a: 1px; --mt-b: $v; }\na { margin: var(--mt-a); color: var(--mt-missing); }\n",
        "p/index.html" => %(<html lang="ko"><meta property="og:title" content="B"><p>[!NOTE]</p><code>status:available</code>) +
                          %(<a href="https://x.example" target="_blank">x</a><div class="mt-illustration">d</div>) +
                          %(<script type="application/ld+json">{"@context":"https://schema.org","@graph":[{"@type":"WebPage","@id":"#a","url":"/a/","name":"A","inLanguage":"en","colour":"x"},{"@type":"Webpage"}]}</script>),
      },
      flags: ["--twins", "--github-pages", "--schema-recommended"],
    },
  }.freeze

  def corpus
    Dir.glob("#{CORPUS}/*.md").sort.to_h { |f| [File.basename(f), "---\n---\n" + File.binread(f)] }.merge("nofm.md" => "# No front matter\n")
  end

  def run_site(name, spec)
    Dir.mktmpdir do |dir|
      { "src" => spec[:src], "_site" => spec.fetch(:site, {}) }.each do |root, files|
        FileUtils.mkdir_p(File.join(dir, root))
        files.each do |rel, text|
          path = File.join(dir, root, rel)
          FileUtils.mkdir_p(File.dirname(path))
          File.binwrite(path, text)
        end
      end
      o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, "#{dir}/src", "#{dir}/_site", *spec.fetch(:flags, []))
      "#{(o + e).gsub(dir, '$TMP')}exit #{st.exitstatus}\n"
    end
  end

  # Built-part checks run only with Nokogiri; where they add output, <name>.nokogiri.txt is that variant.
  NOKOGIRI = Open3.capture3(CLEAN_ENV, RbConfig.ruby, "-e", "require 'nokogiri'")[2].success?

  def snapshot_path(name)
    variant = File.join(SNAPSHOTS, "#{name}.nokogiri.txt")
    NOKOGIRI && File.file?(variant) ? variant : File.join(SNAPSHOTS, "#{name}.txt")
  end

  def assert_snapshot(name, spec)
    got = run_site(name, spec)
    path = snapshot_path(name)
    File.write(path, got) if ENV["SNAPSHOT_UPDATE"] == "1"
    assert File.file?(path), "no snapshot #{path}; run with SNAPSHOT_UPDATE=1"
    assert_equal File.read(path), got, "checker output changed for #{name}"
  end

  SITES.each { |name, spec| define_method("test_snapshot_#{name.tr('-', '_')}") { assert_snapshot(name, spec) } }

  def test_snapshot_corpus = assert_snapshot("corpus", { src: corpus })
end

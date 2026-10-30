# frozen_string_literal: true
# Optional renderers (modootoday.mermaid): script tags only on pages with a fence, SRI + crossorigin, opt-out, checker.
require "minitest/autorun"
require_relative "site"

class RenderersBuildTest < Minitest::Test
  include LayoutSite

  MM = "https://cdn.example.test/mermaid@11.4.1/dist/mermaid.min.js"
  SRI = "sha384-AAAAbbbbCCCCdddd0123456789+/AAAAbbbbCCCCdddd0123456789+/AAAAbbbbCC"
  FENCE = "# D\n\n```mermaid\ngraph TD\n  A --> B\n```\n"
  PAGES = {
    "d.md" => ["title: D\n", FENCE],
    "off.md" => ["title: Off\nmermaid: false\n", FENCE],
    "p.md" => ["title: P\n", "# P\n\nMentions language-mermaid and ```mermaid in text only.\n"],
  }.freeze

  def cfg(mermaid) = "modootoday:\n  mermaid: #{mermaid}\n"

  def test_cdn_with_integrity
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES, config: cfg(%({enabled: true, src: "#{MM}", integrity: "#{SRI}", theme: auto})))
      h = html(s, "d.md")
      assert_includes h, %(<script src="#{MM}" integrity="#{SRI}" crossorigin="anonymous" defer></script>)
      assert_match(%r{<script src="[^"]*/assets/js/modootoday-mermaid\.js" data-mt-theme="auto" defer></script>}, h)
      assert_includes h, '<code class="language-mermaid">', "the fence stays as the no-JS fallback"
      refute_includes html(s, "off.md"), "modootoday-mermaid.js"
      refute_includes html(s, "p.md"), "modootoday-mermaid.js"
      refute_includes html(s, "p.md"), MM
      assert File.exist?("#{s}/assets/js/modootoday-mermaid.js")
      o, = check(src, s)
      refute_match(/mermaid|external script/, o)
    end
  end

  def test_without_integrity_nothing_loads_and_checker_errors
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES, config: cfg(%({enabled: true, src: "#{MM}"})))
      refute_includes html(s, "d.md"), MM
      refute_includes html(s, "d.md"), "modootoday-mermaid.js"
      o, st = check(src, s)
      refute st.success?
      assert_includes o, "integrity (an SRI hash such as sha384-…) is required"
    end
  end

  def test_self_hosted_and_default_off
    Dir.mktmpdir do |d|
      _, s = build_site(d, PAGES, config: cfg("{enabled: true, src: /assets/mermaid/mermaid.min.js}"))
      h = html(s, "d.md")
      assert_match(%r{<script src="[^"]*/assets/mermaid/mermaid\.min\.js" defer></script>}, h)
      refute_includes h, "crossorigin"
    end
    Dir.mktmpdir do |d|
      _, s = build_site(d, PAGES)
      refute_includes html(s, "d.md"), "modootoday-mermaid.js"
    end
  end

  K = "https://cdn.example.test/katex@0.16.11/dist/"
  MATH = %({enabled: true, engine: katex, src: "#{K}katex.min.js", css: "#{K}katex.min.css", integrity: {js: "#{SRI}", css: "#{SRI}"}, auto_render_src: "#{K}contrib/auto-render.min.js", auto_render_integrity: "#{SRI}"})
  MATH_PAGES = {
    "fence.md" => ["title: F\n", "# F\n\n```math\nx^2\n```\n"],
    "block.md" => ["title: B\n", "# B\n\n$$\nE=mc^2\n$$\n"],
    "none.md" => ["title: N\n", "# N\n\nNo math, a price of $5.\n"],
    "off.md" => ["title: O\nmath: false\n", "# O\n\n$$\nE=mc^2\n$$\n"],
    "inl.md" => ["title: I\n", "# I\n\nEnergy $E=mc^2$ here.\n"],
  }.freeze

  def test_math_tags_only_where_needed
    Dir.mktmpdir do |d|
      src, s = build_site(d, MATH_PAGES, config: "modootoday:\n  math: #{MATH}\n")
      %w[fence.md block.md].each do |n|
        h = html(s, n)
        assert_includes h, %(<link rel="stylesheet" href="#{K}katex.min.css" integrity="#{SRI}" crossorigin="anonymous">), n
        assert_includes h, %(<script src="#{K}katex.min.js" integrity="#{SRI}" crossorigin="anonymous" defer></script>), n
        assert_includes h, %(<script src="#{K}contrib/auto-render.min.js" integrity="#{SRI}" crossorigin="anonymous" defer></script>), n
        assert_match(%r{modootoday-math\.js" data-mt-inline="false" defer}, h)
      end
      assert_includes html(s, "block.md"), "\\[E=mc^2\\]", "kramdown (math_engine mathjax, the default) prints $$ blocks as \\[ … \\]"
      %w[none.md off.md inl.md].each { |n| refute_includes html(s, n), "katex", n }
      o, = check(src, s)
      refute_match(/external (script|stylesheet)/, o)
      assert_match(/inl\.md:\d+: inline \$…\$ stays plain text/, o)
    end
  end

  def test_math_inline_opt_in_and_missing_integrity
    Dir.mktmpdir do |d|
      _, s = build_site(d, MATH_PAGES, config: "modootoday:\n  math: #{MATH.delete_suffix("}")}, inline: true}\n")
      assert_match(%r{modootoday-math\.js" data-mt-inline="true" defer}, html(s, "inl.md"))
    end
    Dir.mktmpdir do |d|
      src, s = build_site(d, MATH_PAGES, config: "modootoday:\n  math: #{MATH.sub(%(css: "#{SRI}"), "css: null")}\n")
      refute_includes html(s, "fence.md"), "katex"
      o, st = check(src, s)
      refute st.success?
      assert_includes o, "integrity.css (an SRI hash such as sha384-…) is required"
    end
  end
end

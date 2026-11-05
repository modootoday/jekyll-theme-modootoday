# frozen_string_literal: true
# Static diagrams (front matter diagrams:): the n-th mermaid fence becomes the n-th entry's committed SVG pair, the
# fence moves into a details element, and pages without the list keep their output.
require "minitest/autorun"
require_relative "../../support/layout_site"

class DiagramsTest < Minitest::Test
  include LayoutSite

  FIXTURE = File.join(LayoutSite::ROOT, "test/fixtures/sites/figures")
  MERMAID = "modootoday:\n  mermaid: {enabled: true, src: /assets/mermaid.js}\n"

  def self.sites = (@sites ||= {})

  def site(name, config)
    self.class.sites[name] ||= begin
      dir = Dir.mktmpdir
      Minitest.after_run { FileUtils.rm_rf(dir) }
      build_site(dir, {}, config: config, from: FIXTURE).last
    end
  end

  def read(s, rel) = File.read(File.join(s, rel))

  def test_the_first_fence_becomes_the_first_entry
    h = read(site(:pair, MERMAID), "index.html")
    fig = h[%r{<figure class="mt-figure mt-figure-svg mt-diagram">.*?</figure>}m]
    assert_includes fig, %(<div class="mt-figure-scroll" tabindex="0" role="region" aria-label="Writing comes first, then the check">)
    assert_includes fig, %(<img class="mt-diagram-light mt-no-filter" src="/assets/diagrams/flow.svg" alt="Writing comes first, then the check" width="240" height="60" loading="lazy" decoding="async">)
    assert_includes fig, %(<img class="mt-diagram-dark mt-no-filter" src="/assets/diagrams/flow.dark.svg" alt="Writing comes first, then the check" width="240" height="60")
    assert_includes fig, "<figcaption>The <em>two</em> steps.</figcaption>"
    assert_match %r{</figure><details class="mt-diagram-source"><summary>Diagram source</summary>(<div class="language-mermaid highlighter-rouge">|<pre><code class="language-mermaid">)flowchart LR\n  A\[Write\]}m, h
    assert_equal 1, h.scan("mt-diagram-source").size
    assert_match(/After the figure\.<\/p>\s*(<div class="language-mermaid highlighter-rouge">|<pre><code class="language-mermaid">)flowchart LR\n  C --&gt; D/m, h, "a fence with no entry stays a code block")
    assert_match %r{href="[^"]*/assets/css/modootoday/media/figure\.css}, h
    refute_includes h, "modootoday-mermaid.js", "the loader never runs on a page with diagrams:"
  end

  def test_a_page_without_the_list_keeps_its_fence_and_loader
    h = read(site(:pair, MERMAID), "plain/index.html")
    refute_includes h, "<figure"
    refute_includes h, "modootoday/media/figure.css"
    assert_includes h, "modootoday-mermaid.js"
    assert_match(/(<div class="language-mermaid highlighter-rouge">|<pre><code class="language-mermaid">)flowchart LR/, h)
  end

  def test_source_none_and_no_dark_twin
    h = read(site(:single, "modootoday:\n  diagrams: {dir: /assets/diagrams/, dark: false, source: none}\n"), "index.html")
    fig = h[%r{<figure class="mt-figure mt-figure-svg mt-diagram">.*?</figure>}m]
    assert_includes fig, %(<img class="mt-diagram-light" src="/assets/diagrams/flow.svg")
    refute_includes fig, "flow.dark.svg"
    refute_includes h, "mt-diagram-source"
    refute_match(/A\[Write\]/, h, "source: none drops the fence")
    assert_match(/C --&gt; D/, h)
  end

  def test_the_swap_lives_in_the_figure_sheet_only
    s = site(:pair, MERMAID)
    css = read(s, "assets/css/modootoday/media/figure.css").gsub(/\s+/, " ")
    assert_match(/@media \(prefers-color-scheme: dark\) \{ :root:not\(\[data-theme=["']?light["']?\]\) \.mt-diagram \.mt-diagram-dark \{ display: block; \}/, css)
    assert_match(/:root\[data-theme=["']?dark["']?\] \.mt-diagram \.mt-diagram-light:not\(:only-child\) \{ display: none; \}/, css)
    refute_includes read(s, "assets/css/modootoday.css"), ".mt-diagram"
  end

  def test_dropping_the_component_drops_only_its_rules
    s = site(:off, "modootoday:\n  components: [callout, code, figure, figure-svg]\n")
    refute_includes read(s, "assets/css/modootoday/media/figure.css"), ".mt-diagram"
    assert_includes read(s, "index.html"), %(<img class="mt-diagram-light mt-no-filter")
  end
end

# frozen_string_literal: true
# 1.0 content components (inline extras, loading/skeleton, c: filetree … subscribe) and the per-page sheets
# they pull in, built with the active bundle's Jekyll.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class ContentComponentsTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  PROBE = <<~MD
    ---
    title: Probe
    hero: {c: split, visual: pic, ratio: "5:7", scene: 9}
    sections: [{c: filetree, name: ft}, {c: faq, name: faq}, {c: params, name: p}, {c: quote, name: q}, {c: gallery, name: g}, {c: pricing, name: pr, recommended: 2}, {c: subscribe, name: sub}, {c: split, name: sp, visual: pic, side: start, ratio: "5:7", scene: 3}]
    ---
    # Probe

    `file:a.yml`

    ```yaml
    a: 1
    ```

    Done `progress:60` and `loading:spinner` then `skeleton:card`.

    `embed:https://example.com/v Video`

    ## Tree

    - docs
      - a.md

    ## FAQ

    ### Free?

    Yes.

    ## Params

    | Name | Type |
    |---|---|
    | `t` | `required` |

    ## Quote

    > Good.
    >
    > — Ann

    ## Gallery

    - ![One](/1.png)
    - ![Two](/2.png)

    ## Pricing

    ### A

    [Go](/a/)

    ### B

    [Go](/b/)

    ## Subscribe

    News.

    ## Split

    Text beside the picture.
  MD

  def self.build
    @b ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: S\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
                 "defaults: [{scope: {path: ''}, values: {layout: doc}}]\nmodootoday: {subscribe: {action: 'https://x.example/s'}}\n")
      File.write(File.join(src, "index.md"), "---\ntitle: Home\n---\n# Home\n")
      File.write(File.join(src, "probe.md"), PROBE)
      File.write(File.join(src, "_includes/sections/pic.html"), '<p class="pic">scene {{ include.section.scene }}</p>')
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      [File.read(File.join(dir, "_site/probe/index.html")), File.read(File.join(dir, "_site/index.html"))]
    end
  end

  def h = self.class.build[0]

  def test_inline_extras
    assert_match(/class="mt-code".*class="mt-code-title"/m, h)
    assert_match(/class="mt-progress".*<progress[^>]*value="60"/m, h)
    assert_match(/class="mt-embed"><iframe[^>]*title="Video"[^>]*loading="lazy"/m, h)
  end

  def test_loading_is_announced
    assert_match(/class="mt-spinner"[^>]*role="status"/, h)
    assert_match(/class="mt-skeleton mt-skeleton-card"[^>]*aria-busy="true"/, h)
    assert_includes h, "Loading"
  end

  def test_sections
    assert_match(/<ul aria-label="[^"]+"/, h)
    assert_includes h, "mt-c-faq"
    refute_includes h, "\"@type\":\"FAQPage\""
    assert_includes h, "mt-param-required"
    assert_match(/<figure class="mt-quote">.*<figcaption>/m, h)
    assert_match(/class="mt-gallery-thumb".*class="mt-lightbox"/m, h)
    assert_match(/mt-plan mt-plan-recommended/, h)
    assert_match(%r{<form class="mt-subscribe"[^>]*action="https://x.example/s"}, h)
  end

  def test_split_wraps_only_split
    sec = h[/<section class="mt-section mt-c-split[^"]*".*?<\/section>/m]
    assert_match(/mt-c-split mt-split-start mt-split-5-7/, sec)
    assert_match(%r{<div class="mt-section-in"><div class="mt-section-body"><h2 [^>]*>Split</h2>.*</div><div class="mt-section-visual"><p class="pic">scene 3</p></div></div>}m, sec)
    assert_equal 2, h.scan("mt-section-in").size
    assert_includes h, "modootoday/structure/split.css"
  end

  def test_split_hero
    hero = h[/<section class="mt-hero[^"]*".*?<\/section>/m]
    assert_match(/<section class="mt-hero mt-c-split mt-split-5-7">/, hero)
    assert_match(%r{<div class="mt-section-in"><div class="mt-section-body">\s*<h1[^>]*>Probe</h1>.*</div><div class="mt-section-visual"><p class="pic">scene 9</p></div></div>\s*</section>}m, hero)
    assert_equal 2, h.scan("mt-section-in").size
  end

  def test_sheets_per_page
    probe, home = self.class.build
    %w[loading.css showcase/gallery.css showcase/pricing.css structure/faq.css].each { |c| assert_includes probe, "modootoday/#{c}" }
    %w[loading.css gallery.css tabs.js].each { |c| refute_includes home, c }
  end
end

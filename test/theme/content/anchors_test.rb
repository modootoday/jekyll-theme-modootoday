# frozen_string_literal: true
# Heading anchor links (modootoday.heading_anchors, markdown/anchors.html), built with the active bundle's Jekyll: the
# GFM ids of non-Latin headings, where the link goes, the sections it skips and the TOC it leaves alone.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class AnchorsTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  PROBE = <<~MD
    ---
    title: Probe
    sections: [intro, {c: faq, name: faq}, {c: tabs, name: tabs}, {c: steps, name: steps}, scripts]
    ---
    # Probe

    ### Before the sections

    ## Intro

    ### Sub `code` here

    ### Sub `code` here

    ### Has [a link](/x/) inside

    ## FAQ

    ### Free?

    Yes.

    ## Tabs

    ### One

    ```sh
    a
    ```

    ### Two

    ```sh
    b
    ```

    ## Steps

    ### Install

    Run it.

    ## Scripts

    ### 한국어 제목

    ### 日本語の見出し

    ### 中文标题

    ### عنوان عربي

    ### כותרת עברית

    ### หัวข้อภาษาไทย
  MD
  PLAIN = "---\ntitle: Plain\n---\n# Plain\n\n## First part\n\nText.\n\n### A \"quoted\" title\n\n#### Deeper\n"
  IDS = %w[한국어-제목 日本語の見出し 中文标题 عنوان-عربي כותרת-עברית หัวข้อภาษาไทย].freeze

  def self.build(config)
    @builds ||= {}
    @builds[config] ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: S\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
                 "defaults: [{scope: {path: ''}, values: {layout: doc}}]\n#{config}")
      File.write(File.join(src, "probe.md"), PROBE)
      File.write(File.join(src, "plain.md"), PLAIN)
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      %w[probe plain].to_h { |p| [p, File.read(File.join(dir, "_site/#{p}/index.html"))] }
                     .merge("core" => File.read(File.join(dir, "_site/assets/css/modootoday.css")))
    end
  end

  def on(page = "probe") = self.class.build("modootoday: {heading_anchors: true}\n")[page]
  def article(page = "probe") = on(page)[%r{<article class="mt-doc">.*</article>}m]
  def section(name) = article[%r{<section class="mt-section[^"]*" data-section="#{name}".*?</section>}m]
  def anchor(id) = %(<a class="mt-anchor" href="##{id}" aria-label=")

  def test_non_latin_headings_keep_their_letters_in_the_id_and_get_a_link
    IDS.each do |id|
      assert_includes section("scripts"), %(<h3 id="#{id}">)
      assert_includes section("scripts"), anchor(id), id
    end
  end

  def test_the_link_ends_the_heading_and_names_it
    h = section("intro")
    assert_match(%r{<h2 id="intro">Intro<a class="mt-anchor" href="#intro" aria-label="Link to section: Intro"><svg [^>]*aria-hidden="true"[^>]*>.*?</svg></a></h2>}m, h)
    assert_includes h, %(<h3 id="sub-code-here">Sub <code class="language-plaintext highlighter-rouge">code</code> here<a class="mt-anchor" href="#sub-code-here" aria-label="Link to section: Sub code here">)
    assert_includes h, anchor("sub-code-here-1"), "a duplicate heading links to its own id"
    assert_match(%r{<a href="/x/">a link</a> inside<a class="mt-anchor"}, h, "a link in the heading closes before the anchor")
  end

  def test_hero_and_pages_without_sections
    assert_includes article[%r{<section class="mt-hero.*?</section>}m], anchor("before-the-sections")
    plain = article("plain")
    assert_includes plain, anchor("first-part")
    assert_match(/aria-label="Link to section: A [^"]{1,8}quoted[^"]{1,8} title"/, plain, "quotes never end the label")
    refute_match(/<h4[^>]*>[^<]*<a class="mt-anchor"/, plain, "only h2 and h3")
    refute_match(/<h1[^>]*>[^<]*<a class="mt-anchor"/, plain)
  end

  def test_component_sections_keep_their_headings
    %w[faq tabs steps].each { |s| refute_includes section(s), "mt-anchor", s }
  end

  def test_toc_text_and_the_sheet
    toc = on[%r{<aside class="mt-doc-aside".*?</aside>}m]
    assert_includes toc, %(<a href="#sub-code-here">Sub code here</a>)
    refute_includes toc, "mt-anchor"
    assert_includes on, "/assets/css/modootoday/content/anchor.css"
    refute_includes on("core"), ".mt-anchor"
  end

  def test_bundle_mode_folds_the_sheet_into_core
    b = self.class.build("modootoday: {heading_anchors: true, css: bundle}\n")
    assert_includes b["core"], ".mt-anchor"
    assert_includes b["probe"], anchor("intro")
    refute_includes b["probe"], "content/anchor.css"
  end

  def test_off_by_default_and_when_the_component_is_left_out
    ["", "modootoday: {heading_anchors: true, components: [toc, faq, tabs, steps]}\n"].each do |config|
      html = self.class.build(config)
      %w[probe plain].each do |p|
        refute_includes html[p], "mt-anchor", "#{config.inspect} #{p}"
        refute_includes html[p], "content/anchor.css"
      end
    end
  end
end

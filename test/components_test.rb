# frozen_string_literal: true
# v0.3 layout components (breadcrumb, TOC, figure, tag/since badges, accordion/steps sections, theme toggle)
# built with the active bundle's Jekyll.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class ComponentsTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  PROBE = <<~MD
    ---
    title: Probe
    sections: [{c: accordion, name: faq}, {c: steps, name: s}]
    ---
    # Probe

    Intro `tag:beta`, `since:0.3`, `tag:two words`.

    ![A cat](/cat.png)

    *A caption*

    ![Alone](/x.png)

    ## FAQ

    ### Question one?

    Answer one.

    ## Steps

    1. First
  MD

  def self.build(extra = "")
    (@b ||= {})[extra] ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(File.join(src, "guide"))
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: Site\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
                                                "defaults: [{scope: {path: ''}, values: {layout: doc}}]\n#{extra}")
      File.write(File.join(src, "index.md"), "---\ntitle: Home\n---\n# Home\n")
      File.write(File.join(src, "guide/index.md"), "---\ntitle: Guide\n---\n# Guide\n")
      File.write(File.join(src, "guide/probe.md"), PROBE)
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      File.read(File.join(dir, "_site/guide/probe/index.html"))
    end
  end

  def h = self.class.build

  def test_breadcrumb
    assert_match(%r{<nav class="mt-breadcrumb" aria-label="Breadcrumb"><ol>\s*<li><a href="/">Home</a></li>\s*<li><a href="/guide/">Guide</a></li>\s*<li><span aria-current="page">Probe</span></li>}, h)
  end

  def test_toc
    assert_match(%r{<nav class="mt-toc".*<a href="#faq">FAQ</a>.*mt-toc-h3"><a href="#question-one">Question one\?</a>.*<a href="#steps">Steps</a>}m, h)
  end

  def test_figure
    assert_includes h, '<figure class="mt-figure"><img src="/cat.png" alt="A cat" /><figcaption>A caption</figcaption></figure>'
    assert_includes h, '<p><img src="/x.png" alt="Alone" /></p>'
  end

  def test_tag_and_since_badges
    assert_includes h, '<span class="mt-badge mt-badge-tag" data-variant="tag">beta</span>'
    assert_includes h, '<span class="mt-badge mt-badge-since" data-variant="since">Since 0.3</span>'
    assert_includes h, ">tag:two words</code>"
  end

  def test_sections_and_scripts
    assert_includes h, 'data-c="accordion"'
    assert_includes h, "mt-c-steps"
    assert_includes h, "accordion.js"
    assert_includes h, '<button class="mt-theme-toggle"'
    assert_includes h, 'localStorage.getItem("mt-theme")'
  end

  def test_components_can_be_disabled
    o = self.class.build("modootoday: {components: [callout], color_scheme: dark}\n")
    %w[mt-breadcrumb mt-toc mt-figure mt-badge-tag mt-theme-toggle accordion.js].each { |s| refute_includes o, s }
  end
end

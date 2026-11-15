# frozen_string_literal: true
# Footnotes as kramdown writes them, after markdown/inline.html: the noteref role sits on the link (DPUB-ARIA allows it
# there, not on sup) and the back-link carries its label.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class FootnotesTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  PAGE = "---\ntitle: Notes\n---\n# Notes\n\nA claim.[^1] Another.[^two]\n\n[^1]: The first note.\n[^two]: The second note.\n"

  def self.html
    @html ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: S\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
                 "defaults: [{scope: {path: ''}, values: {layout: doc}}]\n")
      File.write(File.join(src, "notes.md"), PAGE)
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      File.read(File.join(dir, "_site/notes/index.html"))
    end
  end

  def test_the_noteref_role_is_on_the_link_not_on_sup
    html = self.class.html
    refute_match(/<sup[^>]*role="doc-noteref"/, html)
    # Older kramdown (the GitHub Pages stack) puts the role on sup, newer kramdown on the link itself.
    assert_equal 2, html.scan(%r{<sup id="fnref:[^"]+"><a [^>]*role="doc-noteref"[^>]*>}).size
  end

  def test_the_back_link_keeps_its_role_and_label
    assert_equal 2, self.class.html.scan(/class="reversefootnote" role="doc-backlink" aria-label="[^"]+"/).size
  end
end

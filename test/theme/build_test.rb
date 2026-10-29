# frozen_string_literal: true
# Builds the audit fixtures (test/fixtures/md, from the v1 standards audit) with the
# theme's layouts/includes in-process, using whichever Jekyll the active bundle provides.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class BuildTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  FIX = File.join(ROOT, "test/fixtures/md")
  CONVERTED = %w[a01-note:note a02-tip:tip a03-important:important a04-warning:warning a05-caution:caution
                 a06-lowercase:note a07-mixedcase:note a09-multipara:note a14-crlf:note a16-lazy-continuation:note
                 a17-blank-gt-after:note a19-code-inside:note a21-inline-first-body:note a22-no-space:note
                 a23-indented-3sp:note a24-list-first-body:note a27-heading-first:note a28-trailing-spaces:note].freeze
  UNCONVERTED = %w[a08-unknown-type a10-trailing-text a11-nested a12-in-list a13-in-table a20-bold-title-line a26-space-inside].freeze
  SECTIONS = { "a29-h2-in-alert-sections" => 1, "s03-hash-in-quote" => 1, "s09-h2-in-list" => 1, "s02-hash-in-fence" => 1,
               "s04-trailing-hashes" => 2, "s08-fence-4backticks" => 1 }.freeze

  def self.site
    @site ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "markdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
                                                "defaults: [{scope: {path: ''}, values: {layout: doc}}]\n")
      Dir.glob("#{FIX}/*.md").each do |f|
        n = File.basename(f, ".md")
        secs = SECTIONS[n] ? "sections: [#{(1..SECTIONS[n]).map { |i| "s#{i}" }.join(', ')}]\n" : ""
        File.binwrite(File.join(src, "#{n}.md"), "---\n#{secs}---\n" + File.binread(f))
      end
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process } # Jekyll 3 also looks for _layouts in the cwd
      at_exit { FileUtils.rm_rf(dir) }
      File.join(dir, "_site")
    end
  end

  def html(n) = File.read(File.join(self.class.site, n, "index.html"))[%r{<article.*</article>}m]

  CONVERTED.each do |pair|
    n, type = pair.split(":")
    define_method("test_alert_#{n.tr('-', '_')}") do
      h = html(n)
      assert_includes h, %(class="mt-callout mt-callout-#{type}"), h
      refute_match(/\[!\w+\]/, h)
    end
  end

  UNCONVERTED.each do |n|
    define_method("test_not_alert_#{n.tr('-', '_')}") { refute_includes html(n), "mt-callout" }
  end

  def test_alert_body_keeps_block_content
    assert_match(%r{mt-callout-title"><svg class="mt-icon mt-icon-note"[^>]*>.*?</svg>Note</p>\s*<div class="language-sh}, html("a19-code-inside"))
    assert_match(%r{mt-callout-title"><svg [^>]*>.*?</svg>Note</p>\s*<ul>}, html("a24-list-first-body"))
    assert_match(%r{mt-callout-title"><svg [^>]*>.*?</svg>Note</p><p>Body\.</p>}, html("a28-trailing-spaces"))
    assert_match(%r{mt-callout-title"><svg [^>]*>.*?</svg>Note</p>\s*<p>Body after blank\.</p>}, html("a17-blank-gt-after"))
    h = html("a25-two-adjacent")
    assert_includes h, "mt-callout-note"
    assert_includes h, "mt-callout-tip"
  end

  SECTIONS.each do |n, count|
    define_method("test_sections_#{n.tr('-', '_')}") do
      h = html(n)
      assert_equal count, h.scan('<section class="mt-section').size, h
      h.scan(%r{<blockquote.*?</blockquote>}m) { |q| refute_includes q, "<section", h }
      h.scan(%r{<li.*?</li>}m) { |q| refute_includes q, "<section", h }
    end
  end
end

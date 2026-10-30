# frozen_string_literal: true
# ref:-based links (modootoday/link.html ref=), ref-linked hreflang and language switcher, and decor: ornaments.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class RefLinksTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)

  def self.build
    @b ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: S\nlang: en\nurl: https://x.example\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
                 "defaults: [{scope: {path: ''}, values: {layout: doc}}, {scope: {path: ko}, values: {lang: ko}}]\n" \
                 "modootoday: {languages: [en, ko], language_switcher: header}\n")
      FileUtils.mkdir_p(File.join(src, "ko"))
      FileUtils.mkdir_p(File.join(src, "_includes/sections"))
      File.write(File.join(src, "_includes/sections/orn.html"), '<svg class="orn"></svg>')
      File.write(File.join(src, "index.md"), "---\ntitle: Home\n---\n# Home\n")
      File.write(File.join(src, "ko/index.md"), "---\ntitle: 홈\n---\n# 홈\n")
      File.write(File.join(src, "guide.md"), "---\ntitle: Guide\nref: guide\n---\n# Guide\n\n[CLI]({% include modootoday/link.html ref=\"cli\" %})\n")
      File.write(File.join(src, "ko/annae.md"), "---\ntitle: 안내\nref: guide\n---\n# 안내\n\n[CLI]({% include modootoday/link.html ref=\"cli\" %}) [Guide]({% include modootoday/link.html ref=\"guide\" %})\n")
      File.write(File.join(src, "cli.md"), "---\ntitle: CLI\nref: cli\nsections: [{name: a, decor: orn}]\nhero: {decor: orn}\n---\n# CLI\n\nLead.\n\n## A\n\nText.\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      %w[guide ko/annae cli].to_h { |p| [p, File.read(File.join(dir, "_site/#{p}/index.html"))] }
    end
  end

  def page(p) = self.class.build[p]

  def test_ref_link_uses_this_language_then_falls_back
    assert_includes page("guide"), '<a href="/cli/">CLI</a>'
    assert_includes page("ko/annae"), '<a href="/cli/">CLI</a>'
    assert_includes page("ko/annae"), '<a href="/ko/annae/">Guide</a>'
  end

  def test_hreflang_and_switcher_follow_ref
    g = page("guide")
    assert_includes g, '<link rel="alternate" hreflang="ko" href="https://x.example/ko/annae/">'
    assert_includes g, '<link rel="alternate" hreflang="x-default" href="https://x.example/guide/">'
    assert_match(%r{<a href="/ko/annae/" lang="ko"}, g)
    c = page("cli")
    refute_includes c, 'hreflang="ko" href='
    assert_match(%r{<a href="/ko/" lang="ko"}, c)
  end

  def test_decor_is_hidden_ornament
    c = page("cli")
    assert_match(/<section class="mt-hero mt-has-decor">.*<div class="mt-section-decor" aria-hidden="true"><svg class="orn"><\/svg><\/div><\/section>/m, c)
    assert_match(/<section class="mt-section mt-has-decor" data-section="a">.*<div class="mt-section-decor" aria-hidden="true">/m, c)
  end
end

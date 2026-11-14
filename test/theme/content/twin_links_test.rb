# frozen_string_literal: true
# Twins and llms-full.txt point a link that names a source file at its target's site URL (adr:modootoday/20261114115001),
# built with the active bundle's Jekyll and stubs only: an English page, its .ko.md translation, a subfolder page, a
# post, an image, a page without a twin, and the links and code that stay as they are.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "jekyll"

class TwinLinksTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  B = "https://example.org/b"
  INSTALL = <<~MD
    # Install

    See [Upgrade](upgrade.md#upgrading), [Deep](../sub/deep/page.md) and [Plain](plain.md).
    ![Logo](../img/logo.svg) [Post](../_posts/2026-01-02-hello.md) [Ref][r]

    ```` ```md ```` opens no fence, so [Again](upgrade.md#ok) is a link, and `` `[No](upgrade.md)` `` is code.

    Kept: [URL](../upgrade/), [Root](/x/), [Ext](https://example.com/a.md), [Top](#top), [Missing](missing.md), `[Code](upgrade.md)`.

    ```md
    [Fenced](upgrade.md)
    ```

    [r]: upgrade.md
      "new-window"
  MD
  PAGES = {
    "index.md" => "---\ntitle: Home\n---\n# Home\n\n[Install](guides/install.md#verify)\n",
    "guides/install.md" => "---\ntitle: Install\n---\n#{INSTALL}",
    "guides/install.ko.md" => "---\ntitle: 설치\nlang: ko\npermalink: /ko/guides/install/\n---\n# 설치\n\n[업그레이드](upgrade.ko.md#소개)와 [English](install.md).\n",
    "guides/upgrade.md" => "---\ntitle: Upgrade\n---\n# Upgrade\n",
    "guides/upgrade.ko.md" => "---\ntitle: 업그레이드\nlang: ko\npermalink: /ko/guides/upgrade/\n---\n# 업그레이드\n",
    "guides/plain.md" => "---\ntitle: Plain\ntwin: false\n---\n# Plain\n",
    "sub/deep/page.md" => "---\ntitle: Deep\n---\n# Deep\n\n[Back](../../guides/install.md)\n"
  }.freeze
  STUBS = { "index" => "/", "guides/install" => "/guides/install/", "guides/install.ko" => "/ko/guides/install/",
            "guides/upgrade" => "/guides/upgrade/", "guides/upgrade.ko" => "/ko/guides/upgrade/", "sub/deep/page" => "/sub/deep/page/" }.freeze

  def self.site
    @site ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: Site\nurl: https://example.org\nbaseurl: /b\npermalink: pretty\n")
      files = PAGES.merge("img/logo.svg" => "<svg xmlns=\"http://www.w3.org/2000/svg\"/>\n",
                          "_posts/2026-01-02-hello.md" => "---\ntitle: Hello\n---\nHi.\n",
                          "llms.txt" => "---\nlayout: llms\npermalink: /llms.txt\n---\n",
                          "llms-full.txt" => "---\nlayout: llms-full\npermalink: /llms-full.txt\n---\n",
                          "llms-full.ko.txt" => "---\nlayout: llms-full\nlang: ko\npermalink: /ko/llms-full.txt\n---\n")
      STUBS.each { |s, url| files["#{s}.md.txt"] = "---\nlayout: twin\ntwin_of: #{File.basename(s)}.md\npermalink: #{url}index.md\n---\n" }
      files.each do |rel, text|
        FileUtils.mkdir_p(File.dirname(File.join(src, rel)))
        File.write(File.join(src, rel), text)
      end
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      [src, File.join(dir, "_site")]
    end
  end

  def out(path) = File.read(File.join(self.class.site[1], path))

  def test_file_links_reach_twins_pages_posts_and_files_and_the_rest_stays_byte_for_byte
    want = INSTALL.sub("(upgrade.md#upgrading)", "(#{B}/guides/upgrade/index.md#upgrading)")
                  .sub("(../sub/deep/page.md)", "(#{B}/sub/deep/page/index.md)")
                  .sub("(plain.md)", "(#{B}/guides/plain/)")
                  .sub("(../img/logo.svg)", "(#{B}/img/logo.svg)")
                  .sub("(../_posts/2026-01-02-hello.md)", "(#{B}/2026/01/02/hello/)")
                  .sub("(upgrade.md#ok)", "(#{B}/guides/upgrade/index.md#ok)")
                  .sub("[r]: upgrade.md", "[r]: #{B}/guides/upgrade/index.md")
    assert_equal want, out("guides/install/index.md")
  end

  def test_translation_and_subfolder_links
    assert_equal "# 설치\n\n[업그레이드](#{B}/ko/guides/upgrade/index.md#소개)와 [English](#{B}/guides/install/index.md).\n", out("ko/guides/install/index.md")
    assert_equal "# Deep\n\n[Back](#{B}/guides/install/index.md)\n", out("sub/deep/page/index.md")
    assert_equal "# Home\n\n[Install](#{B}/guides/install/index.md#verify)\n", out("index.md")
  end

  def test_llms_full_carries_the_same_links
    assert_includes out("llms-full.txt"), out("guides/install/index.md")
    assert_includes out("llms-full.txt"), out("sub/deep/page/index.md")
    assert_includes out("ko/llms-full.txt"), out("ko/guides/install/index.md")
  end

  def test_checker_accepts_the_links_and_names_one_that_reaches_nothing
    src, site = self.class.site
    run = -> { Open3.capture2e(RbConfig.ruby, "#{ROOT}/exe/modootoday-check", src, site, "--twins", chdir: ROOT) }
    o, st = run.call
    assert st.success?, o
    Dir.mktmpdir do |d|
      FileUtils.cp_r("#{site}/.", d)
      f = "#{d}/sub/deep/page/index.md"
      File.write(f, File.read(f).sub("/guides/install/index.md", "/guides/gone/index.md"))
      o, st = Open3.capture2e(RbConfig.ruby, "#{ROOT}/exe/modootoday-check", src, d, "--twins", chdir: ROOT)
      refute st.success?
      assert_includes o, "link #{B}/guides/gone/index.md (from sub/deep/page.md) reaches no file in the site"
    end
  end
end

# frozen_string_literal: true
# Every language of the example site has the guide page with a byte-identical twin, an llms.txt entry
# and its own navigation.
require "minitest/autorun"
require "tmpdir"
require "open3"

class ExampleGuidesTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  EXAMPLE = File.join(ROOT, "example")

  def test_guide_in_every_language
    Dir.mktmpdir do |d|
      out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", EXAMPLE, "-d", "#{d}/s", chdir: ROOT)
      assert st.success?, out
      { "" => "Guide", "ko/" => "가이드", "ja/" => "ガイド" }.each do |pre, title|
        src = File.read("#{EXAMPLE}/#{pre}guide.md").sub(/\A---\n.*?\n---\n/m, "")
        assert_equal src, File.read("#{d}/s/#{pre}guide/index.md"), "#{pre}guide twin"
        assert_includes File.read("#{d}/s/#{pre}llms.txt"), "(/#{pre}guide/index.md)"
        html = File.read("#{d}/s/#{pre}guide/index.html")
        assert_includes html, "<h1"
        assert_includes html, title
        assert_includes html, %(href="/#{pre}guide/") if pre != ""
        assert_equal 5, html.scan(/class="mt-callout /).size, "#{pre}guide alerts"
      end
    end
  end
end

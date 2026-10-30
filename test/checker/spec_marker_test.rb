# frozen_string_literal: true
# specfold value markers (<!-- spec:name --> / <!-- /spec:name -->) and cols: 4. Run: bundle exec rake test
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class SpecMarkerTest < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def setup
    @dir = Dir.mktmpdir
    @src = File.join(@dir, "src")
    @site = File.join(@dir, "_site")
    FileUtils.mkdir_p([@src, @site])
  end

  def teardown = FileUtils.rm_rf(@dir)
  def page(name, text) = write(File.join(@src, name), text)
  def write(path, text) = FileUtils.mkdir_p(File.dirname(path)) && File.write(path, text)

  def check
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, @src, @site)
    [o + e, st.exitstatus]
  end

  def body(text) = page("a.md", "---\ntitle: A\n---\n# A\n\n#{text}\n")
  def comment_error?(o) = o.include?("HTML comment <!-- -->")

  def test_accepts_own_line_inline_and_closing_forms
    body "<!-- spec:graph -->\n\nThere are <!-- spec:count -->12<!-- /spec:count --> rules.\n\n" \
         "- Item <!-- spec:docs.index_v2-x:sub -->3<!-- /spec:docs.index_v2-x:sub -->\n\n<!-- /spec:graph -->\n" \
         "<!-- spec:toc:begin -->\n<!-- spec:toc:end -->"
    o, code = check
    assert_equal 0, code, o
  end

  def test_rejects_malformed_and_other_comments
    { "<!-- spec:Count -->" => "uppercase", "<!-- spec: -->" => "empty name", "<!-- spec:count\n-->" => "multi-line",
      "<!-- note -->" => "plain comment", "<!-- spec:count ## B -->" => "## inside" }.each do |c, why|
      body "Text #{c} end."
      o, code = check
      assert_equal 1, code, "#{why}: #{o}"
      assert comment_error?(o), "#{why}: #{o}"
    end
  end

  def test_comments_in_code_stay_ignored
    body "`<!-- note -->`\n\n```text\n<!-- spec:Count -->\n```"
    o, code = check
    assert_equal 0, code, o
  end

  def test_cols_4_allowed
    write File.join(@src, "_data/components.yml"), "features: {params: {cols: {allowed: [2, 3, 4], required: true}}}\n"
    page "a.md", "---\ntitle: A\nsections:\n  - {c: features, name: f, cols: 4}\n---\n# A\n\n## F\n\n- **A** — a\n- **B** — b\n"
    o, code = check
    assert_equal 0, code, o
    page "a.md", "---\ntitle: A\nsections:\n  - {c: features, name: f, cols: 5}\n---\n# A\n\n## F\n\n- **A** — a\n"
    o, code = check
    assert_equal 1, code, o
  end
end

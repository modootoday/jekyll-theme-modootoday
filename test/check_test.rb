# frozen_string_literal: true
# Tests for exe/modootoday-check. Run: bundle exec rake test
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class CheckTest < Minitest::Test
  CHECK = File.expand_path("../exe/modootoday-check", __dir__)

  def setup
    @dir = Dir.mktmpdir
    @src = File.join(@dir, "src")
    @site = File.join(@dir, "_site")
    FileUtils.mkdir_p([@src, @site])
  end

  def teardown = FileUtils.rm_rf(@dir)

  def page(name, text) = write(File.join(@src, name), text)
  def out(name, text) = write(File.join(@site, name), text)

  def write(path, text)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, text)
  end

  def check(*flags)
    o, e, st = Open3.capture3({ "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }, RbConfig.ruby, CHECK, @src, @site, *flags)
    [o + e, st.exitstatus]
  end

  def test_ok_page
    page "a.md", "---\ntitle: A\n---\n# A\n\n> [!NOTE]\n> hi\n"
    o, code = check
    assert_equal 0, code, o
    assert_match(/OK \(1 pages\)/, o)
  end

  def test_missing_front_matter_is_an_error
    page "a.md", "# A\n"
    o, code = check
    assert_equal 1, code
    assert_match(/a\.md: missing front matter/, o)
  end

  def test_empty_front_matter_is_fine
    page "a.md", "---\n---\n# A\n"
    assert_equal 0, check[1]
  end

  def test_forbidden_syntax
    page "a.md", "---\n---\n<div>x</div>\n{{ x }}\n{: .c}\n## H {#id}\n: def\n- > [!NOTE]\n```\n<div>ok in code</div>\n```\n"
    o, code = check
    assert_equal 1, code
    %w[raw\ HTML Liquid IAL {\#id} definition nested].each { |w| assert_includes o, w.delete("\\") }
    refute_match(/a\.md:10:/, o)
  end

  def test_status_vocabulary
    page "a.md", "---\n---\n`status:done` `status:available`\n"
    o, code = check
    assert_equal 1, code
    assert_match(/unregistered status value `status:done`/, o)
  end

  def test_sections_count
    page "a.md", "---\nsections: [a, b]\n---\n# T\n\n## A\n"
    o, code = check
    assert_equal 1, code
    assert_match(/has 2 item\(s\) but body has 1/, o)
  end

  def test_components_registry
    write File.join(@src, "_data/components.yml"), "features: {params: {cols: {allowed: [2, 3], required: true}}}\ntabs: {i18n: [tabs.label]}\n"
    write File.join(@src, "_data/i18n/en.yml"), "callout: {}\n"
    page "a.md", "---\nsections: [{c: features, cols: 4}, {c: nope}]\n---\n## A\n## B\n"
    o, = check
    assert_match(/cols=4 not in/, o)
    assert_match(/unknown component 'nope'/, o)
    assert_match(/missing key 'tabs.label'/, o)
  end

  def test_build_residue
    page "a.md", "---\n---\n# A\n"
    out "a/index.html", "<p>[!NOTE]</p><code>status:available</code>"
    o, code = check
    assert_equal 1, code
    assert_match(/unconverted alert marker/, o)
    assert_match(/unconverted status badge/, o)
  end

  def test_unknown_alert_type_warns_but_passes
    page "a.md", "---\n---\n> [!FOO]\n> x\n"
    o, code = check
    assert_equal 0, code
    assert_match(/warning: .*unknown alert type \[!FOO\]/, o)
    o, code = check("--strict")
    assert_equal 1, code, o
  end

  def test_github_pages_is_optional
    page "a.md", "---\n---\n# A\n"
    assert_equal 0, check[1]
    o, code = check("--github-pages")
    assert_equal 1, code
    assert_match(/no Gemfile.lock with github-pages/, o)
    write File.join(@src, "Gemfile.lock"), "GEM\n  specs:\n    github-pages (231)\n"
    assert_match(/github-pages 231 != 232/, check("--github-pages")[0])
    assert_equal 0, check("--github-pages=231")[1]
  end

  def test_twins
    page "index.md", "---\ntitle: T\n---\n# T\n"
    page "index.md.txt", "---\nlayout: twin\ntwin_of: index.md\npermalink: /index.md\n---\n"
    page "g.md", "---\n---\n# G\n"
    out "index.md", "# T\n"
    out "llms.txt", ""
    out "llms-full.txt", ""
    o, code = check("--twins")
    assert_equal 1, code
    assert_match(/g\.md: no twin stub/, o)
    refute_match(/index\.md: twin/, o)
    out "index.md", "# T changed\n"
    assert_match(/not byte-identical/, check("--twins")[0])
  end

  def test_usage
    _, _, st = Open3.capture3(RbConfig.ruby, CHECK)
    refute st.success?
    o, st = Open3.capture2(RbConfig.ruby, CHECK, "--help")
    assert st.success?
    assert_match(/usage: modootoday-check/, o)
  end
end

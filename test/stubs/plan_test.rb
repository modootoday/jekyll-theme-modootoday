# frozen_string_literal: true
# modootoday-stubs plans: twin stubs, alias stubs, conflicts and pruning. Run: bundle exec rake test
require_relative "stubs_case"

class StubsPlanTest < StubsCase
  def test_twin_stubs_for_pages_with_front_matter
    file "index.md", "---\ntitle: Home\n---\n# Home\n"
    file "guides/install.md", "---\n---\n# Install\n"
    file "guides/raw.md", "# No front matter\n"
    file "off.md", "---\ntwin: false\n---\n# Off\n"
    file "README.md", "---\n---\n# Readme\n"
    file "_drafts/d.md", "---\n---\n# D\n"
    file "vendor/v.md", "---\n---\n# V\n"
    assert_equal({ "guides/install.md.txt" => "create", "index.md.txt" => "create" }, plan("--twins"))
    stubs("--twins", "--write")
    assert_equal "---\nlayout: twin\ntwin_of: install.md\npermalink: /guides/install/index.md\n---\n", read("guides/install.md.txt")
    assert_equal "---\nlayout: twin\ntwin_of: index.md\npermalink: /index.md\n---\n", read("index.md.txt")
  end

  def test_twin_stub_follows_a_directory_permalink_and_honours_exclude
    config "exclude: [drafts, \"*.tmp.md\"]\n"
    file "a.md", "---\npermalink: /start/\n---\n# A\n"
    file "drafts/x.md", "---\n---\n# X\n"
    file "b.tmp.md", "---\n---\n# B\n"
    stubs("--twins", "--write")
    assert_includes read("a.md.txt"), "permalink: /start/index.md\n"
    refute exist?("drafts/x.md.txt")
    refute exist?("b.tmp.md.txt")
  end

  def test_alias_stubs
    config "modootoday: {aliases: {md: true, html: true}}\n"
    file "index.md", "---\n---\n# Home\n"
    file "guides/index.md", "---\n---\n# Guides\n"
    file "guides/install.md", "---\n---\n# Install\n"
    file "404.md", "---\npermalink: /404.html\n---\n# Gone\n"
    file "off.md", "---\ntwin: false\n---\n# Off\n"
    stubs("--aliases", "--write")
    assert_equal "---\nlayout: twin\ntwin_of: install.md\npermalink: /guides/install.md\n---\n", read("guides/install.flat.md.txt")
    assert_equal "---\nlayout: redirect\nredirect_to: /guides/install/\npermalink: /guides/install.html\nsitemap: false\n---\n", read("guides/install.html.md.txt")
    assert_includes read("guides/index.flat.md.txt"), "permalink: /guides.md\n"
    assert_includes read("guides/index.html.md.txt"), "redirect_to: /guides/\npermalink: /guides.html\n"
    refute exist?("index.flat.md.txt"), "the home page already has /index.md"
    refute exist?("404.html.md.txt"), "no alias for a page without a directory URL"
    refute exist?("off.flat.md.txt"), "twin: false has no md alias"
    assert exist?("off.html.md.txt")
  end

  def test_only_the_declared_alias_kinds
    config "modootoday: {aliases: {html: true}}\n"
    file "a.md", "---\n---\n# A\n"
    assert_equal({ "a.html.md.txt" => "create" }, plan("--aliases"))
  end

  def test_alias_conflicts_are_data_errors
    config "modootoday: {aliases: {md: true}}\n"
    file "a/index.md", "---\n---\n# A\n"
    file "b.md", "---\npermalink: /a/\n---\n# B\n"
    _, e, code = stubs("--aliases")
    assert_equal 3, code
    assert_match(%r{b\.md: alias /a\.md is also the alias of a/index\.md}, e)
    FileUtils.rm(File.join(@src, "b.md"))
    file "a.md", "# A raw copy\n"
    _, e, code = stubs("--aliases")
    assert_equal 3, code
    assert_match(%r{a/index\.md: alias /a\.md would overwrite a\.md}, e)
  end

  def test_unsafe_permalink_is_a_data_error
    file "a.md", "---\npermalink: \"/a: b/\"\n---\n# A\n"
    _, e, code = stubs("--twins")
    assert_equal 3, code
    assert_match(/a\.md: unsafe permalink/, e)
  end

  def test_prune_deletes_orphans_unless_no_prune
    config "modootoday: {aliases: {md: true, html: true}}\n"
    file "a.md", "---\n---\n# A\n"
    stubs("--twins", "--aliases", "--write")
    config "modootoday: {aliases: {md: true}}\n"
    file "gone.md.txt", "---\nlayout: twin\ntwin_of: gone.md\npermalink: /gone/index.md\n---\n"
    file "gone.flat.md.txt", "---\nlayout: twin\n---\n"
    want = { "a.html.md.txt" => "delete", "gone.flat.md.txt" => "delete", "gone.md.txt" => "delete" }
    assert_equal want, plan("--twins", "--aliases")
    assert_empty plan("--twins", "--aliases", "--no-prune")
    stubs("--twins", "--aliases", "--write")
    assert exist?("a.md.txt")
    assert exist?("a.flat.md.txt")
    refute exist?("a.html.md.txt")
    refute exist?("gone.md.txt")
  end
end

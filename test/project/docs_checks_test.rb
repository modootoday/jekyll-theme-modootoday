# frozen_string_literal: true
# The docs checks that need no built site run with the tests, so every push runs them; each script also runs alone.
require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"
require_relative "../system/docs/rules/pages"
require_relative "../system/docs/rules/links"

class DocsChecksTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  def run_check(*args) = Open3.capture2e(RbConfig.ruby, *args, chdir: ROOT)

  def test_docs_structure
    out, st = run_check("test/system/docs/structure.rb")
    assert st.success?, out
  end

  # An empty site directory keeps a stale local docs/_site out of it; the docs QA job checks the built pages.
  def test_kitchen_sink_coverage_of_the_sources
    Dir.mktmpdir do |site|
      out, st = run_check("test/system/docs/coverage.rb", site)
      assert st.success?, out
    end
  end

  def test_component_order
    out, st = run_check("test/system/docs/order.rb")
    assert st.success?, out
  end

  def test_docs_consistency_rules
    out, st = run_check("test/system/docs/rules.rb")
    assert st.success?, out
  end

  def test_docs_follow_the_code_registries
    out, st = run_check("test/system/docs/registries.rb")
    assert st.success?, out
  end

  def test_relative_links_name_a_file_that_opens_on_github
    Dir.mktmpdir do |root|
      write = lambda do |rel, text|
        FileUtils.mkdir_p(File.dirname("#{root}/#{rel}"))
        File.write("#{root}/#{rel}", text)
      end
      write.call("_config.yml", "modootoday: {languages: [en, ko]}\n")
      write.call("_data/sections.yml", "- {id: guides, title: {en: Guides}}\n")
      write.call("guides/b.md", "---\ntitle: B\n---\n# B\n")
      write.call("guides/a.md", "---\ntitle: A\n---\n# A\n\n[file](b.md#x) [folder](./) [url](../b/) [titled](b.md \"new-window\") [ref][r]\n" \
                                "[site](https://example.com/) [here](#a) [root](/x/) `[code](nope.md)`\n\n```markdown\n[fence](nope.md)\n```\n\n" \
                                "[r]: b.md\n  \"new-window\"\n")
      write.call("_posts/2026-01-01-p.md", "---\ntitle: P\n---\n[gone](../guides/c.md)\n")
      write.call("404.md", "---\nlayout: error\n---\n[home](/base/)\n")
      found = DocsRules::Links.call(DocsRules::Pages.new(root))[DocsRules::Links::RESOLVE]
      folder = "names no file in docs/ (a folder or a site URL does not open on GitHub)"
      assert_equal ["_posts/2026-01-01-p.md:4: ../guides/c.md #{folder}", "guides/a.md:6: ./ #{folder}", "guides/a.md:6: ../b/ #{folder}",
                    "guides/a.md:6: b.md has its title on the same line, which jekyll-relative-links skips; use a reference definition with the title on the next line",
                    "guides/a.md:7: /x/ is root-absolute; name the file relative to this one"], found
    end
  end
end

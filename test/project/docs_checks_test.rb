# frozen_string_literal: true
# The docs checks that need no built site run with the tests, so every push runs them; each script also runs alone.
require "minitest/autorun"
require "open3"
require "tmpdir"

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
end

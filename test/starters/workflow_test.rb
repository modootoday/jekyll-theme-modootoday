# frozen_string_literal: true
require "minitest/autorun"
require "yaml"

# The starters' Pages workflow uses the same action versions as the theme's own CI wherever both use an action.
class StarterWorkflowTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  USES = %r{^\s*(?:-\s+)?uses:\s*([\w.-]+/[\w.-]+)@(\S+)}

  def uses(text) = text.scan(USES).group_by(&:first).transform_values { |v| v.map(&:last).uniq }

  def test_action_versions_match_the_theme_ci
    starter = uses(File.read(File.join(ROOT, "script/starters/templates/pages.yml.erb")))
    theme = uses(Dir[File.join(ROOT, ".github/workflows/*.yml")].map { |f| File.read(f) }.join("\n"))
    shared = starter.keys & theme.keys
    assert_includes shared, "actions/checkout"
    assert_includes shared, "actions/jekyll-build-pages"
    shared.each { |a| assert_equal theme[a], starter[a], a }
  end
end

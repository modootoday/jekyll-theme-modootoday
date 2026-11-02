# frozen_string_literal: true
# Component names live twice: mt_all_components in config.html (Liquid cannot read a data file from a gem theme)
# and the checker's COMPONENTS. This keeps the two lists equal.
require "minitest/autorun"
require_relative "../../lib/modootoday/check"

class ComponentNamesTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  # Sheet parts the theme turns on by name that modootoday.components does not accept yet. Each needs a reason.
  LIQUID_ONLY = { "figure-svg" => "figure sheet part; the checker does not list it as a component name" }.freeze

  def liquid
    src = File.read(File.join(ROOT, "_includes/modootoday/config.html"))
    src[/assign mt_all_components = "([^"]+)"/, 1].to_s.split(",")
  end

  # Found by constant, not file path, so moving checker files does not break the test.
  def checker
    lists = constants_named(Modootoday::Check, :COMPONENTS)
    assert_equal 1, lists.size, "expected one COMPONENTS constant under Modootoday::Check"
    lists.first
  end

  def test_config_and_checker_name_the_same_components
    refute_empty liquid
    assert_equal (liquid - LIQUID_ONLY.keys).sort, checker.sort
    assert_equal liquid.uniq, liquid, "duplicate names in mt_all_components"
  end

  def test_liquid_only_list_is_current
    assert_empty LIQUID_ONLY.keys - liquid, "no longer in config.html: remove from LIQUID_ONLY"
    assert_empty LIQUID_ONLY.keys & checker, "the checker accepts it now: remove from LIQUID_ONLY"
  end

  private

  def constants_named(mod, name, seen = {})
    return [] if seen[mod]
    seen[mod] = true
    mod.constants(false).flat_map do |c|
      v = mod.const_get(c)
      next [v] if c == name
      v.is_a?(Module) && v.name.to_s.start_with?("#{mod.name}::") ? constants_named(v, name, seen) : []
    end
  end
end

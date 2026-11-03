# frozen_string_literal: true
# Component names live in several homes that cannot read one data file yet: config.html (mt_all_components,
# mt_core_partials, mt_section_sheets), the _sass/modootoday.scss imports, the checker's COMPONENTS, the asset
# registry and docs/_data/components.yml. This pins them to each other.
require "minitest/autorun"
require "yaml"
require_relative "../../lib/modootoday/check"

class ComponentNamesTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  PARTIALS = "_sass/modootoday/components"
  # Sheet parts the theme turns on by name that modootoday.components does not accept yet. Each needs a reason.
  LIQUID_ONLY = {}.freeze

  def config = @config ||= File.read(File.join(ROOT, "_includes/modootoday/config.html"))
  def config_list(name) = config[/assign #{name} = "([^"]+)"/, 1].to_s.split(",")
  def liquid = config_list("mt_all_components")
  def core_partials = config_list("mt_core_partials")
  def section_sheets = config_list("mt_section_sheets").to_h { |s| s.split(":", 2) }
  def name_of(partial) = partial.split("/").last

  # Partial paths under components/, without the underscore and extension ("core/inline/callout").
  def partials
    Dir.glob("**/_*.scss", base: File.join(ROOT, PARTIALS)).map { |f| f.sub(%r{_([^/]+)\.scss\z}, '\1') }.sort
  end

  def bundle_imports = File.read(File.join(ROOT, "_sass/modootoday.scss")).scan(%r{@import "modootoday/components/([^"]+)"}).flatten

  # Sass parts of the optional sheets (fifth column of assets/registry.html).
  def registry_parts
    rows = File.read(File.join(ROOT, "_includes/modootoday/assets/registry.html"))[/capture _mta_rows -%}\n(.*?)\{%- endcapture/m, 1]
    rows.to_s.lines.flat_map { |r| r.chomp.split("|")[4].to_s.split }.uniq
  end

  def docs_components = YAML.safe_load(File.read(File.join(ROOT, "docs/_data/components.yml"))).keys

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

  def test_every_component_has_a_partial_and_every_partial_names_a_component
    assert_equal liquid.sort, partials.map { |p| name_of(p) }.uniq.sort
  end

  def test_core_partials_exist
    refute_empty core_partials
    assert_empty core_partials - partials, "mt_core_partials names a partial that is not under #{PARTIALS}"
  end

  def test_section_sheets_match_the_docs_registry
    assert_equal docs_components.sort, section_sheets.keys.sort, "mt_section_sheets keys vs docs/_data/components.yml"
    assert_empty section_sheets.values.map { |v| "section/#{v}" } - partials, "a section sheet with no partial"
  end

  def test_bundle_imports_every_core_and_section_partial
    imports = bundle_imports
    assert_equal imports.uniq, imports, "duplicate imports in _sass/modootoday.scss"
    assert_empty imports - partials, "_sass/modootoday.scss imports a partial that does not exist"
    assert_empty core_partials - imports, "core partial missing from _sass/modootoday.scss"
    assert_empty section_sheets.values.map { |v| "section/#{v}" } - imports, "section sheet missing from _sass/modootoday.scss"
  end

  def test_partials_outside_the_core_and_section_sheets_are_registry_parts
    rest = partials - core_partials - section_sheets.values.map { |v| "section/#{v}" }
    assert_empty rest.map { |p| name_of(p) } - registry_parts, "a component partial no sheet links (assets/registry.html)"
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

# frozen_string_literal: true
# The asset registry (_includes/modootoday/assets/registry.html) owns the theme's CSS and JS files: one row per file, each
# with its source and a gzip cap (qa/audit/budgets/modules.mjs measures it), and no theme file without a row.
require "minitest/autorun"
require_relative "../../support/asset_registry"

class RegistryTest < Minitest::Test
  ROOT = AssetRegistry::ROOT
  KINDS = { false => %w[css section js module], true => %w[sheet script import] }.freeze
  IMPORT = /^\s*(?:import|export)\s*(?:[\w$*{}\s,]+from\s*)?["'](\.{1,2}\/[^"']+)["']/

  def rows = AssetRegistry.rows

  def test_one_row_per_file
    paths = rows.map(&:path)
    assert_equal paths.uniq, paths, "a file has one row; list several triggers in one row, separated by ^"
  end

  def test_rows_have_a_kind_a_source_and_a_cap
    rows.each do |r|
      assert_includes KINDS[r.fixed], r.kind, r.path
      assert File.file?(r.source), "#{r.path}: no source #{r.source.delete_prefix("#{ROOT}/")}"
      assert r.cap&.positive?, "#{r.path}: no cap (gzip bytes; qa/audit/budgets/modules.mjs prints the value to use)"
      assert_equal 0, r.cap % 128, "#{r.path}: a cap is a multiple of 128"
    end
  end

  def test_every_theme_file_has_a_row
    sources = Dir.glob("assets/{css/modootoday*.scss,css/modootoday/**/*.scss,js/modootoday*.js,js/modootoday/**/*.js}", base: ROOT)
    listed = rows.map { |r| r.source.delete_prefix("#{ROOT}/") }
    assert_empty sources - listed, "add a row (with a cap) to the asset registry"
  end

  def test_deps_are_the_static_imports_of_each_script
    rows.select { |r| r.path.end_with?(".js") }.each do |r|
      dir = File.dirname(r.path)
      imports = File.read(r.source).scan(IMPORT).flatten.map { |i| File.expand_path(i, dir) }
      assert_equal imports.sort, r.deps.sort, "#{r.path}: deps column vs import statements"
      r.deps.each { |d| assert rows.any? { |x| x.path == d }, "#{r.path}: dep #{d} has no row" }
    end
  end

  def test_section_rows_name_one_section_each
    sections = rows.select { |r| r.kind == "section" }.map { |r| r.triggers }
    assert(sections.all? { |t| t.size == 1 }, "a section row's trigger is one sections: name")
    assert_equal sections.flatten.uniq, sections.flatten
  end
end

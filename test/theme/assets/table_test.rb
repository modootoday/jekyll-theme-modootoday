# frozen_string_literal: true
# Body tables: links/content.html wraps each in div.mt-table, c: params tables get mt-table--stack, the table sheets
# are linked by their body probes, and the Korean line-breaking rule sits on the lang element.
require "minitest/autorun"
require_relative "../../support/layout_site"

class TableTest < Minitest::Test
  include LayoutSite

  TABLE = "| Key | Default |\n|---|---|\n| `badges` | `true` |\n"
  PARAMS = "| Name | Type | Default | Description |\n|---|---|---|---|\n| `title` | string | `required` | Page title |\n"
  PAGES = {
    "t/table.md" => ["title: T\n", "# T\n\n#{TABLE}\nText.\n\n#{TABLE}"],
    "t/params.md" => ["title: P\nsections: [{c: params, name: p}]\n", "# P\n\nLead.\n\n## Options\n\n#{PARAMS}"],
    "t/plain.md" => ["title: N\n", "# N\n\nText.\n"],
    "t/prose.md" => ["title: M\n", "# M\n\nAdd `table.mt-table--stack` or `{: .mt-table--dl}`.\n\n#{TABLE}"],
  }.freeze

  def built(config = "")
    self.class.instance_variable_get(:@built)&.dig(config) || begin
      d = Dir.mktmpdir
      Minitest.after_run { FileUtils.rm_rf(d) }
      site = build_site(d, PAGES, config: config)[1]
      (self.class.instance_variable_get(:@built) || self.class.instance_variable_set(:@built, {}))[config] = site
    end
  end

  def main(name) = html(built, name)[%r{<main.*</main>}m]
  def sheet(name) = %r{<link rel="stylesheet" href="/assets/css/modootoday/#{name}\.css\?v=[^"]+">}

  def test_every_body_table_is_wrapped_once
    m = main("t/table.md")
    assert_equal 2, m.scan('<div class="mt-table"><table>').size
    assert_equal 2, m.scan("</table></div>").size
    refute_includes m, '<div class="mt-table"><div class="mt-table">'
  end

  def test_params_tables_stack
    m = main("t/params.md")
    assert_includes m, '<div class="mt-table"><table class="mt-table--stack">'
    assert_includes m, '<th scope="col">Name</th>'
  end

  def test_sheets_follow_the_body
    assert_match sheet("data/table"), html(built, "t/table.md")
    refute_match sheet("data/table-stack"), html(built, "t/table.md")
    refute_match sheet("data/table-stack"), html(built, "t/prose.md"), "the class named in prose is no probe"
    p = html(built, "t/params.md")
    assert_match sheet("data/table"), p
    assert_match sheet("data/table-stack"), p
    assert_includes p, "/assets/js/modootoday/data/table-stack.js"
    refute_includes html(built, "t/table.md"), "table-stack.js"
    refute_includes html(built, "t/prose.md"), "table-stack.js"
    plain = html(built, "t/plain.md")
    refute_includes plain, "table.css"
    refute_includes plain, "scroll-region.js"
  end

  def test_sheets_hold_the_table_rules_and_the_core_only_a_fallback
    css = ->(f) { File.read("#{built}/assets/css/#{f}").gsub(/\s+/, "") }
    core = css.("modootoday.css")
    assert_match(/\[lang\|="?ko"?\]\{word-break:keep-all;overflow-wrap:break-word;?\}/, core)
    refute_includes core, ":lang(ko){word-break"
    refute_includes core, ".mt-table"
    table = css.("modootoday/data/table.css")
    assert_includes table, ".mt-table>table:has(th:nth-child(4))"
    assert_includes table, "max(100%,36rem)"
    assert_includes table, "position:sticky"
    stack = css.("modootoday/data/table-stack.css")
    assert_includes stack, "[data-mt-labelled]"
    assert_includes stack, "mt-table--fixed"
  end

  def test_bundle_mode_folds_both_sheets_into_the_core
    site = built("modootoday: {css: bundle}\n")
    core = File.read("#{site}/assets/css/modootoday.css").gsub(/\s+/, "")
    assert_includes core, ".mt-table>table"
    assert_includes core, "[data-mt-labelled]"
    refute_match sheet("table"), html(site, "t/params.md")
  end
end

# frozen_string_literal: true
# Stale diagram SVGs (page/figures/freshness.rb) and the modootoday-check SRC --diagrams list.
# Run: bundle exec rake test
require "json"
require_relative "../../checker_case"
require_relative "../../../../lib/modootoday/figures"

class CheckFreshnessTest < CheckerCase
  MD = File.expand_path("../../../fixtures/md", __dir__)
  SVGS = File.expand_path("../../../fixtures/sites/figures/assets/diagrams", __dir__)
  DIGESTS = File.expand_path("../../../fixtures/figures/digests.json", __dir__)
  ENTRY = "{name: flow, alt: \"Writing comes first, then the check\", width: 240, height: 60}"

  def fixture(name, fm = "diagrams: [#{ENTRY}]\n") = page("a.md", "---\n#{fm}---\n" + File.read(File.join(MD, "#{name}.md")))

  def svgs(*names, src: nil)
    names.each do |n|
      svg = File.read(File.join(SVGS, n))
      page("assets/diagrams/#{n}", src ? svg.sub(/data-mt-src="[^"]*"/, src) : svg)
    end
  end

  def list
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, @src, "--diagrams")
    [JSON.parse(o), e, st.exitstatus]
  end

  def test_an_svg_drawn_from_another_fence_is_stale
    fixture "d01-diagram-ok"
    svgs "flow.svg"
    svgs "flow.dark.svg", src: 'data-mt-src="sha256-0000"'
    o, code = check
    assert_equal 1, code
    assert_includes o, "a.md: diagrams[0] (flow): stale diagram: assets/diagrams/flow.dark.svg was drawn from another fence than the one at line 6 (#{Modootoday::Figures.digest("flowchart LR\n  A[Write] --> B[Check]")}); render it again"
  end

  def test_an_svg_without_the_attribute_is_not_tracked
    fixture "d01-diagram-ok"
    svgs "flow.svg", "flow.dark.svg", src: ""
    o, code = check("--strict")
    assert_equal 0, code, o
    assert_equal [[], 0], list.values_at(0, 2)
  end

  def test_the_list_names_missing_and_stale_renders
    fixture "d01-diagram-count", "diagrams: [#{ENTRY}, {name: second, alt: Two}]\n"
    svgs "flow.svg", "flow.dark.svg", src: 'data-mt-src="sha256-0000"'
    items, err, code = list
    assert_equal 1, code
    assert_empty err
    assert_equal [%w[flow stale], %w[second missing]], items.map { |i| [i["name"], i["reason"]] }
    first = items.first
    assert_equal %w[page name line fence digest files reason], first.keys
    assert_equal ["a.md", 6, "flowchart LR\n  A[Write] --> B[Check]"], first.values_at("page", "line", "fence")
    assert_equal Modootoday::Figures.digest(first["fence"]), first["digest"]
    assert_equal({ "default" => "assets/diagrams/flow.svg", "dark" => "assets/diagrams/flow.dark.svg" }, first["files"])
    assert_equal "  C --> D", items.last["fence"].lines.last
  end

  def test_the_list_follows_the_settings_and_needs_no_site
    page "_config.yml", "modootoday:\n  diagrams: {dir: /img/, dark: false}\n"
    fixture "d01-diagram-ok"
    items, _, code = list
    assert_equal 1, code
    assert_equal({ "default" => "img/flow.svg" }, items.first["files"])
    page "img/flow.svg", File.read(File.join(SVGS, "flow.svg"))
    assert_equal [[], 0], list.values_at(0, 2)
  end

  # The same cases test/js/figures/digest.test.js runs through script/figures/digest.mjs.
  def test_the_digest_rule_matches_the_shared_cases
    JSON.parse(File.read(DIGESTS)).each { |c| assert_equal c["digest"], Modootoday::Figures.digest(c["body"]), c["body"].inspect }
    assert_equal Modootoday::Figures.src_of(File.read(File.expand_path("../../../../docs/assets/diagrams/recipes/flow.svg", __dir__))),
                 JSON.parse(File.read(DIGESTS)).first["digest"]
  end
end

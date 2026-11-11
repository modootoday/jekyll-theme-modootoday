# frozen_string_literal: true
# Front matter diagrams: (page/figures/diagrams.rb) and modootoday.diagrams (config/keys/figures/diagrams.rb), on the
# d01 corpus fixtures. Run: bundle exec rake test
require_relative "../../checker_case"
require_relative "../../../../lib/modootoday/figures"

class CheckDiagramsTest < CheckerCase
  MD = File.expand_path("../../../fixtures/md", __dir__)
  SVGS = File.expand_path("../../../fixtures/sites/figures/assets/diagrams", __dir__)
  ENTRY = "{name: flow, alt: \"Writing comes first, then the check\", width: 240, height: 60}"

  def fixture(name, fm) = page("a.md", "---\n#{fm}---\n" + File.read(File.join(MD, "#{name}.md")))

  def svgs(*names) = names.each { |n| page("assets/diagrams/#{n}", File.read(File.join(SVGS, n))) }

  def test_a_listed_fence_with_its_pair_passes
    fixture "d01-diagram-ok", "diagrams: [#{ENTRY}]\n"
    svgs "flow.svg", "flow.dark.svg"
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_fences_and_entries_must_match
    fixture "d01-diagram-count", "diagrams: [#{ENTRY}]\n"
    svgs "flow.svg", "flow.dark.svg"
    o, code = check
    assert_equal 1, code
    assert_includes o, "a.md: diagrams: has 1 entry but the page has 2 ```mermaid fences (lines 6, 13); the n-th fence is the n-th entry"
  end

  def test_only_mermaid_fences_count_and_alt_is_required
    fixture "d01-diagram-alt", "diagrams: [{name: flow, width: 240, height: 60}]\n"
    svgs "flow.svg", "flow.dark.svg"
    o, code = check
    assert_equal 1, code
    assert_includes o, "a.md: diagrams[0] (flow) needs alt:"
    refute_includes o, "```mermaid fence"
  end

  def test_missing_files_and_the_dark_setting
    fixture "d01-diagram-ok", "diagrams: [#{ENTRY}]\n"
    svgs "flow.svg"
    o, = check
    assert_includes o, "a.md: diagrams[0]: assets/diagrams/flow.dark.svg not found"
    refute_includes o, "flow.svg not found"
    page "_config.yml", "modootoday:\n  diagrams: {dark: false}\n"
    o, code = check
    assert_equal 0, code, o
  end

  def test_no_size_warns_with_the_viewbox
    fixture "d01-diagram-ok", "diagrams: [{name: flow, alt: A flow}]\nmermaid: true\n"
    svgs "flow.svg", "flow.dark.svg"
    o, = check
    assert_includes o, "a.md: diagrams[0] has no width and height, so the page shifts when the image loads; its viewBox gives width: 240, height: 60"
    assert_includes o, "a.md: diagrams: and mermaid: true together"
  end

  def test_min_width_takes_one_of_the_sheet_steps
    fixture "d01-diagram-ok", "diagrams: [{name: flow, alt: A flow, width: 240, height: 60, min_width: 48}]\n"
    svgs "flow.svg", "flow.dark.svg"
    o, code = check("--strict")
    assert_equal 0, code, o
    fixture "d01-diagram-ok", "diagrams: [{name: flow, alt: A flow, width: 240, height: 60, min_width: 30rem}]\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "a.md: diagrams[0].min_width must be one of 24, 32, 40, 48: the width in rem below which the diagram scrolls sideways instead of shrinking (default 32; got \"30rem\")"
  end

  def test_entry_shapes
    fixture "d01-diagram-count", "diagrams: [{name: flow.svg, alt: x}, {name: f, alt: x, width: wide, height: 1, size: 2}]\n"
    o, = check
    assert_includes o, "a.md: diagrams[0].name must be a file name without .svg under /assets/diagrams/"
    assert_includes o, "a.md: diagrams[1]: unknown key size (name, alt, caption, width, height, min_width)"
    assert_includes o, "a.md: diagrams[1].width must be a whole number of pixels (got \"wide\")"
    fixture "d01-diagram-ok", "diagrams: flow\n"
    o, = check
    assert_includes o, "a.md: diagrams: must be a list of {name, alt, caption, width, height, min_width}"
  end

  def test_settings
    page "_config.yml", "modootoday:\n  diagrams: {dir: assets, dark: maybe, source: inline, theme: x}\n"
    page "a.md", "---\n---\n# A\n"
    o, = check
    assert_includes o, "_config.yml: modootoday.diagrams: unknown key 'theme' (known: dir, dark, source)"
    assert_includes o, "_config.yml: modootoday.diagrams.dir must be a site path like /assets/diagrams/"
    assert_includes o, "_config.yml: modootoday.diagrams.dark must be true or false"
    assert_includes o, "_config.yml: modootoday.diagrams.source must be details or none (got \"inline\")"
    page "_config.yml", "modootoday:\n  diagrams: [a]\n"
    o, = check
    assert_includes o, "_config.yml: modootoday.diagrams must be a map (dir:, dark:, source:)"
  end

  def test_the_digest_rule
    svg = File.read(File.join(SVGS, "flow.svg"))
    body = Modootoday::Figures.fences(File.read(File.join(MD, "d01-diagram-ok.md")), "mermaid").first[:body]
    assert_equal Modootoday::Figures.src_of(svg), Modootoday::Figures.digest(body)
    assert_equal Modootoday::Figures.digest("a\nb"), Modootoday::Figures.digest("a\r\nb\r\n\n")
    refute_equal Modootoday::Figures.digest("a\nb"), Modootoday::Figures.digest(" a\nb")
    assert_equal [240, 60], Modootoday::Figures.viewbox(svg)
  end
end

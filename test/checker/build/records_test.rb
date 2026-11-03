# frozen_string_literal: true
# modootoday.records (lib/modootoday/check/build/records.rb and config/keys/pages/twins.rb): the same verdict as
# modootoday-stubs --records --check, record: naming an unknown set, and the shape of each set.
require_relative "../checker_case"

class CheckRecordsTest < CheckerCase
  STUBS = File.expand_path("../../../exe/modootoday-stubs", __dir__)

  def setup
    super
    write File.join(@src, "_config.yml"), "modootoday:\n  records:\n    tools: {title: name, facts: [kind]}\n"
    page "index.md", "---\n---\n# Home\n"
    page "_data/tools.json", %([{"slug": "saw", "name": "Saw"}, {"slug": "awl", "name": "Awl"}]\n)
  end

  def record_errors = check[0].lines.grep(/record|modootoday\.records/).join

  def test_missing_stale_and_orphan_pages_match_the_stubs_check
    page "tools/saw.md", "---\nlayout: detail\ntitle: \"Old\"\nrecord: tools/saw\n---\n"
    page "tools/gone.md", "---\nlayout: detail\ntitle: \"Gone\"\nrecord: tools/gone\n---\n"
    o = record_errors
    assert_match(%r{tools/awl\.md: record page missing: run modootoday-stubs SRC --records --write}, o)
    assert_match(%r{tools/saw\.md: record page out of date}, o)
    assert_match(%r{tools/gone\.md: record page without a record}, o)
    _, _, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, STUBS, @src, "--records", "--write")
    assert st.success?
    assert_equal "", record_errors
  end

  def test_record_naming_no_set_and_data_errors
    page "x.md", "---\nrecord: nope/x\n---\n# X\n"
    page "y.md", "---\ntitle: Y\n---\n```yaml\nrecord: nope/y\n```\n"
    page "_data/tools.json", %([{"slug": "Saw!", "name": "Saw"}]\n)
    o = record_errors
    assert_match(%r{x\.md: record: nope/x names no set in modootoday\.records}, o)
    refute_match(/y\.md/, o, "record: in the body is not a record page")
    assert_match(/modootoday\.records: modootoday\.records\.tools: record 0: slug "Saw!" must match/, o)
  end

  def test_set_shapes
    write File.join(@src, "_config.yml"), "modootoday:\n  records:\n    a: {facts: kind, labels: [x], permalink: /a/, layout: doc, colour: red}\n    b: {facts: [kind], labels: {kind: Kind}, permalink: /b/:key/, layout: post}\n"
    o = check[0]
    assert_match(/modootoday\.records\.a must be a map of data, key, dir/, o)
    assert_match(/modootoday\.records\.b\.layout must be detail, reference or a detail layout/, o)
    refute_match(/records\.b\.(facts|labels|permalink)/, o)
    write File.join(@src, "_config.yml"), "modootoday: {records: [a]}\n"
    assert_match(/modootoday\.records must be a map of record sets/, check[0])
  end
end

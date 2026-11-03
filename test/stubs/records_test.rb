# frozen_string_literal: true
# modootoday-stubs --records: one page per record, its front matter, named sets, pruning, data errors and other kinds in one run.
require_relative "stubs_case"

class StubsRecordsTest < StubsCase
  SET = "modootoday:\n  records:\n    tools: {title: name, description: summary}\n"

  def setup
    super
    config SET
    file "_data/tools.json", %([{"slug": "saw", "name": "Saw \\"S\\"", "summary": "Cuts: wood"}, {"slug": "awl", "name": "Awl"}]\n)
  end

  def test_one_page_per_record
    assert_equal({ "tools/awl.md" => "create", "tools/saw.md" => "create" }, plan("--records"))
    stubs("--records", "--write")
    assert_equal "---\nlayout: detail\ntitle: \"Saw \\\"S\\\"\"\ndescription: \"Cuts: wood\"\npermalink: /tools/saw/\nrecord: tools/saw\nrecord_index: 0\ntwin: false\n---\n", read("tools/saw.md")
    assert_equal "---\nlayout: detail\ntitle: \"Awl\"\npermalink: /tools/awl/\nrecord: tools/awl\nrecord_index: 1\ntwin: false\n---\n", read("tools/awl.md")
    assert_equal({}, plan("--records", "--twins"), "record pages have no twin")
  end

  def test_settings_yaml_data_and_items_map
    config "modootoday:\n  records:\n    kit: {data: tools, key: id, dir: catalog/kit, layout: reference, permalink: /kit/:key.html, lang: ko}\n"
    FileUtils.rm(File.join(@src, "_data/tools.json"))
    file "_data/tools.yml", "items:\n  - {id: a1, title: A}\n"
    stubs("--records", "--write")
    assert_equal "---\nlayout: reference\ntitle: \"A\"\nlang: ko\npermalink: /kit/a1.html\nrecord: kit/a1\nrecord_index: 0\ntwin: false\n---\n", read("catalog/kit/a1.md")
  end

  def test_named_sets_and_pruning
    config "#{SET}    more: {data: tools, title: name}\n"
    assert_equal %w[tools/awl.md tools/saw.md], plan("--records=tools").keys
    stubs("--records", "--write")
    file "_data/tools.json", %([{"slug": "saw", "name": "Saw"}]\n)
    file "tools/notes.md", "---\ntitle: Notes\n---\n# Kept\n\n```yaml\nrecord: tools/notes\n```\n"
    assert_equal({ "more/awl.md" => "delete", "tools/awl.md" => "delete", "more/saw.md" => "update", "tools/saw.md" => "update" }, plan("--records"))
    assert_equal({ "tools/awl.md" => "delete", "tools/saw.md" => "update" }, plan("--records=tools"))
    assert_equal({ "tools/saw.md" => "update" }, plan("--records=tools", "--no-prune"))
    _, e, code = stubs("--records=nope")
    assert_equal 2, code
    assert_match(/no such set/, e)
    assert_equal 2, stubs("--records=")[2]
  end

  def test_data_errors_exit_3
    {
      %([{"name": "No key"}]) => /record 0 has no slug/,
      %([{"slug": "a", "name": "A"}, {"slug": "a", "name": "B"}]) => /record 1: slug a is also record 0/,
      %([{"slug": "../x", "name": "X"}]) => /slug "\.\.\/x" must match/,
      %([{"slug": "x"}]) => /\(x\) has no name for the page title/,
      %({"a": 1}) => /must be a list of records/,
      "[" => /_data\/tools\.json: /,
    }.each do |json, msg|
      file "_data/tools.json", json
      _, e, code = stubs("--records")
      assert_equal 3, code, json
      assert_match msg, e
    end
    file "_data/tools.json", %([{"slug": "saw", "name": "Saw"}])
    file "tools/saw.md", "---\ntitle: Mine\n---\n# Hand-written\n\nrecord: tools/saw\n"
    assert_match(/tools\/saw\.md: a page without record: is already there/, stubs("--records")[1])
  end

  def test_config_errors_exit_2
    { "" => /declare the record sets/, "modootoday: {records: {t: {data: ../x}}}\n" => /\.data: a file name/,
      "modootoday: {records: {t: {dir: _x}}}\n" => /\.dir: a folder/, "modootoday: {records: {t: {permalink: /t/}}}\n" => /:key/,
      "modootoday: {records: {t: {colour: red}}}\n" => /must be a map of data, key/ }.each do |yaml, msg|
      config yaml
      _, e, code = stubs("--records")
      assert_equal 2, code, yaml
      assert_match msg, e
    end
  end

  def test_aliases_for_new_record_pages_in_the_same_run
    config "#{SET}  aliases: {html: true}\n"
    assert_equal({ "tools/awl.html.md.txt" => "create", "tools/awl.md" => "create", "tools/saw.html.md.txt" => "create", "tools/saw.md" => "create" }, plan("--records", "--aliases"))
    stubs("--records", "--aliases", "--write")
    assert_equal [0, "modootoday-stubs: up to date\n"], stubs("--records", "--aliases", "--write").values_at(2, 0)
    file "_data/tools.json", %([{"slug": "saw", "name": "Saw \\"S\\"", "summary": "Cuts: wood"}]\n)
    assert_equal({ "tools/awl.html.md.txt" => "delete", "tools/awl.md" => "delete" }, plan("--records", "--aliases"))
  end
end

# frozen_string_literal: true
# filter: on sections: items and pages (page/filter.rb), modootoday.search (config/keys/search.rb) and the search.json
# size warning (build/build_output.rb). Run: bundle exec rake test
require_relative "../checker_case"

class CheckFilterTest < CheckerCase
  TABLE = "| Tool | Kind |\n|---|---|\n| Rank | Free |\n"

  def test_valid_filters_pass
    page "a.md", "---\nfilter: true\n---\n# A\n\n- One\n- Two\n"
    page "b.md", "---\nsections: [{name: t, filter: {facet: 2}}, {name: l, filter: true}, {name: n, filter: false}]\n---\n" \
                 "# B\n\n## T\n\n#{TABLE}\n## L\n\n1. One\n\n## N\n\nText.\n"
    page "c.md", "---\nlayout: team\nfilter: group\nfilter_text: true\nitems: [{title: A, group: x}]\n---\nIntro.\n"
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_values_and_targets
    page "a.md", "---\nfilter: yes please\n---\n# A\n\n- One\n"
    page "b.md", "---\nfilter: true\n---\n# B\n\nNo list here.\n"
    page "c.md", "---\nsections: [{name: l, filter: {facet: 1}}, {name: t, filter: {facet: 3}}, {name: x, filter: {column: 1}}]\n---\n" \
                 "# C\n\n## L\n\n- One\n\n## T\n\n#{TABLE}\n## X\n\n- One\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "a.md: page.filter must be true, false or {facet: <column number from 1>} (got \"yes please\")"
    assert_includes o, "b.md: page.filter needs a list or table at the top level of its Markdown"
    assert_includes o, "c.md: sections[0].filter.facet needs a table (a list has no columns)"
    assert_includes o, "c.md: sections[1].filter.facet is 3 but the table has 2 columns"
    assert_includes o, "c.md: sections[2].filter must be true, false or {facet: <column number from 1>}"
  end

  def test_page_filter_with_sections_split_and_directory
    page "a.md", "---\nfilter: true\nsections: [{name: l, filter: true}]\n---\n# A\n\n## L\n\n- One\n"
    page "b.md", "---\nsections: [{c: split, name: s, visual: code, filter: true}]\n---\n# B\n\n## S\n\n- One\n\n```sh\nx\n```\n"
    page "c.md", "---\nlayout: directory\nfilter_text: maybe\nitems: [{title: A}]\n---\nIntro.\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "a.md: filter: on the page applies only without sections:; set it on the sections: item"
    refute_includes o, "a.md: sections[0]"
    assert_includes o, "b.md: sections[0]: filter: does not go with c: split"
    assert_includes o, "c.md: filter_text must be true or false"
  end

  def test_search_settings
    page "_config.yml", "collections: {skills: {output: true}, notes: {}}\nmodootoday:\n  search:\n" \
                        "    {words: -1, results: 0, match: fuzzy, compact: 1, fields: [a b], exclude: [v1], collections: [skills, notes, posts, nope], sort: x}\n"
    o, code = check
    assert_equal 1, code
    ["words must be a whole number, 0 for no limit (got -1)", "results must be a whole number from 1 (got 0)",
     "match must be substring or terms (got \"fuzzy\")", "compact must be true or false", "fields must be a list of front matter keys",
     "exclude must be a list of URL prefixes that start with /", "collections: notes needs output: true",
     "collections: posts are always indexed", "collections: nope is not in collections: of _config.yml",
     "search: unknown key sort"].each { |m| assert_includes o, "_config.yml: modootoday.search.#{m}".sub("search.search:", "search:") }
    page "_config.yml", "collections: {skills: {output: true}}\nmodootoday:\n  search: {words: 0, results: 12, match: terms, compact: true, " \
                        "fields: [description, tags], exclude: [/v1/], collections: [skills], fallback: false}\n"
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_large_search_index_warns
    out "search.json", "[" + ("x" * 1_600_000) + "]"
    o, code = check
    assert_equal 0, code, o
    assert_match %r{warning: .*search\.json: 1\.6 MB is over 1\.5 MB}, o
    out "search.json", "[]"
    refute_includes check[0], "search.json"
  end
end

# frozen_string_literal: true
# Page source rules (lib/modootoday/check/page/): front matter, forbidden syntax, values, sections. Run: bundle exec rake test
require_relative "../checker_case"

class CheckPageRulesTest < CheckerCase
  def test_missing_front_matter_is_an_error
    page "a.md", "# A\n"
    o, code = check
    assert_equal 1, code
    assert_match(/a\.md: missing front matter/, o)
  end

  def test_files_and_folders_named_in_exclude_are_not_pages
    page "_config.yml", "exclude: [README.md, drafts/]\n"
    page "README.md", "# Repo readme with `status:done`\n"
    page "drafts/a.md", "# A\n"
    page "docs/README.md", "# Not excluded\n"
    o, code = check
    assert_equal 1, code
    assert_equal ["docs/README.md: missing front matter"], o.lines.grep(/\.md:/).map { |l| l.strip[/\A\S+\.md: missing front matter/] }
  end

  def test_empty_front_matter_is_fine
    page "a.md", "---\n---\n# A\n"
    assert_equal 0, check[1]
  end

  def test_forbidden_syntax
    page "a.md", "---\n---\n<div>x</div>\n{{ x }}\n{: .c}\n## H {#id}\n: def\n- > [!NOTE]\n```\n<div>ok in code</div>\n```\n"
    o, code = check
    assert_equal 1, code
    %w[raw\ HTML Liquid IAL {\#id} definition nested].each { |w| assert_includes o, w.delete("\\") }
    refute_match(/a\.md:10:/, o)
  end

  def test_status_vocabulary
    page "a.md", "---\n---\n`status:done` `status:available`\n"
    o, code = check
    assert_equal 1, code
    assert_match(/unregistered status value `status:done`/, o)
  end

  def test_sections_count
    page "a.md", "---\nsections: [a, b]\n---\n# T\n\n## A\n"
    o, code = check
    assert_equal 1, code
    assert_match(/has 2 item\(s\) but body has 1/, o)
  end

  def test_unknown_alert_type_is_an_error
    page "a.md", "---\n---\n> [!FOO]\n> x\n"
    o, code = check
    assert_equal 1, code
    assert_match(/unregistered alert type \[!FOO\]/, o)
  end

  def test_tag_values_since_rejected_and_image_alt
    page "a.md", "---\n---\n`tag:beta` `since:1.0` `tag:two words` `![](ok-in-code)`\n\n![](x.png)\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "`tag:two words` badge value"
    assert_includes o, "`since:1.0` is not supported before 1.1"
    refute_includes o, "`tag:beta`"
    assert_includes o, "image without alt text"
  end

  def test_kbd_value_format
    page "a.md", "---\n---\n`kbd:Ctrl+K` `kbd:a b` `kbd:Ctrl++`\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "`kbd:a b` must be keys"
    assert_includes o, "`kbd:Ctrl++` must be keys"
    refute_includes o, "`kbd:Ctrl+K` must"
  end
end

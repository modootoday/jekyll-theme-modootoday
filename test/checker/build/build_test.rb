# frozen_string_literal: true
# Built site rules (lib/modootoday/check/build/): residue, built parts, CSS, twins. Run: bundle exec rake test
require_relative "../checker_case"

class CheckBuildTest < CheckerCase
  def test_parts_exist_in_built_html
    _, _, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, "-e", "require 'nokogiri'")
    skip "nokogiri not installed for this Ruby" unless st.success?
    write File.join(@src, "_data/components.yml"), "cta: {slots: {actions: {min: 1}}, parts: [.mt-cta, .mt-gone, '[role=button]']}\n"
    page "p.md", "---\nsections: [{c: cta}]\n---\n# P\n\n## Go\n\n[Start](/)\n"
    out "p/index.html", %(<section class="mt-section mt-cta" data-c="cta"><a href="/">Start</a></section><p class="mt-gone"></p>)
    o, code = check
    assert_equal 1, code
    assert_match(/cta.parts: '.mt-gone' not found in the built HTML of p.md/, o)
    refute_match(/'.mt-cta' not found/, o)
    refute_match(/role=button/, o) # runtime attributes are left to docs QA
    out "p/index.html", %(<section class="mt-section mt-cta" data-c="cta"><a class="mt-gone" href="/">Start</a></section>)
    o, code = check
    assert_equal 0, code, o
  end

  def test_build_residue
    page "a.md", "---\n---\n# A\n"
    out "a/index.html", "<p>[!NOTE]</p><code>status:available</code>"
    o, code = check
    assert_equal 1, code
    assert_match(/unconverted alert marker/, o)
    assert_match(/unconverted status badge/, o)
  end

  def test_residue_ignores_code_and_matches_any_case
    page "a.md", "---\n---\n# A\n"
    out "a/index.html", "<pre><code>[!NOTE]</code></pre><p>`<code>[!TIP]</code>`</p>"
    assert_equal 0, check[1]
    out "a/index.html", "<p>[!note]</p>"
    assert_match(/unconverted alert marker \[!note\]/, check[0])
  end

  def test_built_css_portability_and_undefined_tokens
    out "a.css", "@use \"x\";\n:root { --mt-a: 1px; --mt-b: $v; }\na { margin: var(--mt-a); color: var(--mt-missing); }\n"
    out "i.html", "<style id=\"mt-tokens\">:root{--mt-inline:red}</style><style>a{}</style>"
    out "b.css", "b { color: var(--mt-inline); width: var(--mt-hook, 2rem); }"
    o, code = check
    assert_equal 1, code
    assert_includes o, "@use/@forward left in built CSS"
    assert_includes o, "literal Sass variable"
    assert_includes o, "var(--mt-missing) is never defined"
    refute_includes o, "--mt-inline) is never"
    refute_includes o, "var(--mt-a) is never"
    refute_includes o, "var(--mt-hook) is never", "a var() with a fallback is a hook"
  end

  def test_twins
    page "index.md", "---\ntitle: T\n---\n# T\n"
    page "index.md.txt", "---\nlayout: twin\ntwin_of: index.md\npermalink: /index.md\n---\n"
    page "g.md", "---\n---\n# G\n"
    page "h.md", "---\ntwin: false\n---\n# H\n"
    out "index.md", "# T\n"
    out "llms.txt", ""
    out "llms-full.txt", "# T\n"
    o, code = check("--twins")
    assert_equal 1, code
    assert_match(/g\.md: twin missing at .*g\/index\.md: add a stub g\.md\.txt .*plugins: \[jekyll-theme-modootoday\]/, o)
    assert_match(/llms\.txt: must start with an H1/, o)
    assert_match(/llms-full\.txt: does not contain the body of g\.md/, o)
    refute_match(/index\.md: twin|h\.md/, o)
    out "g/index.md", "# G\n"
    out "llms.txt", "# Site\n"
    out "llms-full.txt", "# T\n\n# G\n"
    assert_equal ["", 0], [check("--twins")[0][/^(?!md-components).*$/].to_s, check("--twins")[1]]
    out "index.md", "# T changed\n"
    assert_match(/not byte-identical/, check("--twins")[0])
  end

  def test_twin_with_package_table
    page "p.md", "---\nlayout: reference\npackages_position: after\npackages: [{name: core}]\n---\n# P\n"
    out "p/index.md", "# P\n"
    out "llms.txt", "# Site\n"
    out "llms-full.txt", "# P\n"
    assert_match(/p\/index\.md: twin must be the body of p\.md with its packages: table after it/, check("--twins")[0])
    out "p/index.md", "# P\n\n| Name | Version | Links |\n| --- | --- | --- |\n| `core` |  |  |\n"
    refute_match(/p\/index\.md/, check("--twins")[0])
  end

  def test_twins_of_sibling_and_directory_translations
    write File.join(@src, "_data/i18n/ko.yml"), "skip: 건너뛰기\n"
    write File.join(@src, "_data/i18n/ja.yml"), "skip: スキップ\n"
    page "g.md", "---\n---\n# G\n"
    page "g.ko.md", "---\nlang: ko\npermalink: /ko/g/\n---\n# 지\n"
    page "ja/g.md", "---\nlang: ja\n---\n# ジ\n"
    { "" => "# G\n", "ko/" => "# 지\n", "ja/" => "# ジ\n" }.each do |l, body|
      out "#{l}g/index.md", body
      out "#{l}llms.txt", "# Site\n"
      out "#{l}llms-full.txt", body
    end
    o, code = check("--twins")
    assert_equal 0, code, o
    File.delete(File.join(@site, "ko/llms-full.txt"))
    File.delete(File.join(@site, "ko/g/index.md"))
    o, = check("--twins")
    assert_match(%r{g\.ko\.md: twin missing at .*/ko/g/index\.md: add a stub g\.ko\.md\.txt with front matter `layout: twin`, `twin_of: g\.ko\.md` and `permalink: /ko/g/index\.md`}, o)
    assert_match(%r{ko/llms-full\.txt: missing: add ko/llms-full\.txt with only front matter `layout: llms-full` and `lang: ko` and no body}, o)
  end

  def test_stub_must_use_twin_layout
    page "a.md", "---\n---\n# A\n"
    page "a.md.txt", "---\nlayout: doc\n---\n"
    assert_match(/a\.md\.txt: stub must set layout: twin/, check("--twins")[0])
  end
end

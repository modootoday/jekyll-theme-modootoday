# frozen_string_literal: true
# JSON-LD types built from page content and front matter: FAQPage from c: faq sections (schema.faq: auto), DefinedTerm
# pages linked to their glossary, LearningResource. Each site is built, then run through modootoday-check.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "json"
require "cgi"

class JsonldTypesTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  CONFIG = "title: T\ntheme: jekyll-theme-modootoday\nurl: https://example.org\nbaseurl: /d\nmarkdown: kramdown\n" \
           "kramdown: {input: GFM, syntax_highlighter: rouge}\npermalink: pretty\ndefaults: [{scope: {path: \"\"}, values: {layout: doc}}]\n"
  FAQ_BODY = <<~MD
    # Questions page

    Lead.

    ## Questions

    Text before the first question.

    ### Is it "free" & open?

    Yes, under the MIT license: `a < b` and **bold**.

    ```sh
    gem install x
    ```

    After the code, [a link](/x/).

    ### Which lists?

    - one
    - two

    ## More

    ### Not a question

    A details section is not FAQ content.
  MD
  FAQ_SECTIONS = "sections: [{c: faq, name: faq}, {c: details, name: more}]\n"
  EMPTY_FAQ = "---\ntitle: Empty\nsections: [{c: faq, name: faq}]\n---\n# Empty\n\n## Questions\n\nNo question yet.\n"

  def build(dir, cfg, pages)
    src = "#{dir}/src"
    FileUtils.mkdir_p(src)
    File.write("#{src}/_config.yml", CONFIG + cfg)
    pages.each { |n, text| File.write("#{src}/#{n}", text) }
    out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", src, "-d", "#{dir}/s", chdir: ROOT)
    assert st.success?, out
    [src, "#{dir}/s"]
  end

  def check(src, site) = Open3.capture2e(RbConfig.ruby, "#{ROOT}/exe/modootoday-check", src, site, "--schema-recommended", chdir: ROOT)
  def html(s, name) = File.read("#{s}/#{name}/index.html")
  def graph(s, name) = JSON.parse(html(s, name)[%r{<script type="application/ld\+json">(.*?)</script>}m, 1])["@graph"]
  def node(s, name, id) = graph(s, name).find { |n| n["@id"].end_with?(id) }

  # What a reader sees in each FAQ details, as textContent: summary, then the answer without code blocks.
  def visible_faq(page)
    page.scan(%r{<section class="mt-section mt-c-faq.*?</section>}m).flat_map do |sec|
      sec.scan(%r{<details class="mt-details"><summary>(.*?)</summary>(.*?)</details>}m).map { |q, a| [text(q), text(a.gsub(%r{<pre.*?</pre>}m, " "))] }
    end
  end

  def text(h) = CGI.unescapeHTML(h.gsub(/<[^>]*>/, "")).split.join(" ")

  def test_faq_auto_on_a_page_matches_the_visible_questions
    Dir.mktmpdir do |d|
      src, s = build(d, "", {
        "faq.md" => "---\ntitle: FAQ\nschema: {faq: auto}\n#{FAQ_SECTIONS}---\n#{FAQ_BODY}",
        "plain.md" => "---\ntitle: Plain\n#{FAQ_SECTIONS}---\n#{FAQ_BODY}",
      })
      g = graph(s, "faq")
      assert_equal 1, g.count { |n| n["@type"] == "FAQPage" }
      faq = node(s, "faq", "#webpage")
      assert_equal "FAQPage", faq["@type"]
      refute faq.key?("faq")
      got = faq["mainEntity"].map { |q| [q["name"], q["acceptedAnswer"]["text"]] }
      assert_equal visible_faq(html(s, "faq")), got
      assert_equal ["Is it “free” & open?", "Yes, under the MIT license: a < b and bold. After the code, a link."], got[0]
      assert_equal ["Which lists?", "one two"], got[1]
      assert_equal %w[WebSite Organization WebPage TechArticle BreadcrumbList], graph(s, "plain").map { |n| n["@type"] }
      out, st = check(src, s)
      assert st.success?, out
    end
  end

  def test_site_faq_auto_with_a_page_opt_out_and_an_empty_faq
    Dir.mktmpdir do |d|
      src, s = build(d, "modootoday: {schema: {faq: auto}}\n", {
        "on.md" => "---\ntitle: On\n#{FAQ_SECTIONS}---\n#{FAQ_BODY}",
        "off.md" => "---\ntitle: Off\nschema: {faq: false}\n#{FAQ_SECTIONS}---\n#{FAQ_BODY}",
        "typed.md" => "---\ntitle: Typed\nschema: {type: TechArticle}\n#{FAQ_SECTIONS}---\n#{FAQ_BODY}",
        "empty.md" => EMPTY_FAQ,
      })
      assert_equal 2, node(s, "on", "#webpage")["mainEntity"].size
      refute_includes html(s, "off"), "FAQPage"
      refute_includes html(s, "typed"), "FAQPage"
      out, st = check(src, s)
      refute st.success?
      assert_equal 1, out.lines.count { |l| l.include?("lacks required mainEntity") }, out
      assert_includes out, "empty/index.html: JSON-LD FAQPage"
    end
  end

  def test_defined_term_page_and_learning_resource
    Dir.mktmpdir do |d|
      src, s = build(d, "", {
        "glossary.md" => "---\ntitle: Glossary\nlayout: glossary\nterms: [{term: Token, text: A value., url: /token/}, {term: Bundle, text: A sheet.}]\n---\nTerms.\n",
        "token.md" => "---\ntitle: Token\ndescription: A value.\nschema: {type: DefinedTerm}\nterm_set: /glossary/\nterm_code: 7\n---\n# Token\n",
        "outside.md" => "---\ntitle: Outside\nschema: {type: DefinedTerm}\nterm_set: https://other.example/terms/\n---\n# Outside\n",
        "learn.md" => "---\ntitle: Learn\nschema: {type: LearningResource}\nlevel: Beginner\nminutes: 25\nteaches: Publishing\nresource_type: tutorial\n---\n# Learn\n",
      })
      term = node(s, "token", "#main")
      assert_equal({ "@id" => "https://example.org/d/glossary/#main" }, term["inDefinedTermSet"])
      assert_equal "7", term["termCode"]
      assert_equal "https://other.example/terms/", node(s, "outside", "#main")["inDefinedTermSet"]
      set = node(s, "glossary", "#main")["hasDefinedTerm"]
      assert_equal ["https://example.org/d/token/", nil], set.map { |t| t["url"] }
      learn = node(s, "learn", "#main")
      assert_equal %w[LearningResource Beginner PT25M Publishing tutorial https://example.org/d/#publisher],
                   [learn["@type"], learn["educationalLevel"], learn["timeRequired"], learn["teaches"], learn["learningResourceType"], learn["provider"]["@id"]]
      out, st = check(src, s)
      assert st.success?, out
      File.write("#{src}/token.md", File.read("#{src}/token.md").sub("/glossary/", "/glossary"))
      build(d, "", {})
      out, = check(src, s)
      assert_includes out, "DefinedTerm term_set https://example.org/d/glossary#main"
    end
  end
end

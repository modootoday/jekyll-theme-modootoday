# frozen_string_literal: true
# Check::StructuredData on hand-written built pages: each broken block yields its error.
require "minitest/autorun"
require_relative "../../lib/modootoday/check"

class StructuredDataTest < Minitest::Test
  Ctx = Struct.new(:errs, :warns, :argv) { def option?(o) = argv.include?(o) }

  def run_on(html, *argv)
    ctx = Ctx.new([], [], argv)
    Modootoday::Check::StructuredData.page(ctx, "p.html", html)
    ctx
  end

  def ld(obj) = %(<script type="application/ld+json">#{obj.is_a?(String) ? obj : JSON.generate(obj)}</script>)
  def g(*nodes) = { "@context" => "https://schema.org", "@graph" => nodes }

  WP = { "@type" => "WebPage", "@id" => "https://e.org/a/#webpage", "url" => "https://e.org/a/", "name" => "A" }.freeze

  def test_valid_graph_passes
    assert_empty run_on(%(<html lang="en">) + ld(g(WP.merge("inLanguage" => "en")))).errs
  end

  def test_errors
    {
      ld("{bad") => "not valid JSON",
      ld(g(WP)) + ld(g(WP)) => "2 JSON-LD blocks",
      ld({ "@context" => "https://example.com", "@type" => "WebPage" }) => "@context",
      ld(g(WP, WP)) => "used by 2 nodes",
      ld(g({ "@type" => "Webpage", "name" => "x" })) => "not in the schema.org vocabulary",
      ld(g(WP.merge("colour" => "x"))) => "not a schema.org property",
      ld(g(WP.merge("url" => "/a/"))) => "not an absolute URL",
      ld(g({ "@type" => "BlogPosting", "headline" => "h", "datePublished" => "2026/10/01" })) => "ISO 8601",
      ld(g({ "@type" => "Event", "name" => "E", "startDate" => "2026-10-01" })) => "lacks required location",
      ld(g({ "@type" => "JobPosting", "title" => "t", "description" => "d", "datePosted" => "2026-10-01", "hiringOrganization" => { "@type" => "Organization", "name" => "o" } })) => "jobLocation/applicantLocationRequirements",
      %(<meta property="og:title" content="B">) + ld(g(WP)) => "differs from og:title",
      %(<html lang="ko">) + ld(g(WP.merge("inLanguage" => "en"))) => "differs from <html lang",
    }.each { |html, msg| assert(run_on(html).errs.any? { |e| e.include?(msg) }, "#{msg}: #{run_on(html).errs}") }
  end

  def test_recommended_only_with_flag
    html = ld(g({ "@type" => "BlogPosting", "headline" => "h" }))
    assert_empty run_on(html).warns
    assert(run_on(html, "--schema-recommended").warns.any? { |w| w.include?("recommended author") })
  end

  SEO = ->(body) { "<!-- Begin Jekyll SEO tag v2.8.0 -->\n#{body}\n<!-- End Jekyll SEO tag -->\n" }

  def test_jekyll_seo_tag_block_is_a_warning_not_an_error
    seo = { "@context" => "https://schema.org", "@type" => "WebPage", "headline" => "A", "url" => "https://e.org/a/" }
    r = run_on(%(<html lang="en">) + SEO.(ld(seo)))
    assert_empty r.errs
    assert(r.warns.any? { |w| w.include?("jekyll-seo-tag") }, r.warns.inspect)
    # The kit's own block next to it is still checked, and not counted as a second block.
    r = run_on(SEO.(ld(seo)) + ld(g(WP.except("name"))))
    assert_equal 1, r.errs.size, r.errs.inspect
    assert_includes r.errs.first, "lacks required name"
    assert(run_on(SEO.(ld("{bad"))).errs.any? { |e| e.include?("jekyll-seo-tag JSON-LD is not valid JSON") })
    # Outside the seo-tag comments the same node is an error.
    assert(run_on(ld(seo)).errs.any? { |e| e.include?("lacks required name") })
  end
end

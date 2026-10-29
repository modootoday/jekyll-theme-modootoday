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
end

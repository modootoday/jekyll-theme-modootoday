# frozen_string_literal: true
# schema.org JSON-LD (modootoday/jsonld/*): the example site plus one page per entity type, built with a url,
# then parsed and run through modootoday-check (which validates every block).
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "json"
require "time"

class JsonldTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  PAGES = {
    "job.md" => "description: a < b\nschema:\n  type: JobPosting\n  description: \"<p>Build docs.</p>\"\n  datePosted: 2026-10-01\n  hiringOrganization: {type: Organization, name: Example}\n  jobLocation: {type: Place, address: {type: PostalAddress, addressCountry: KR}}\n",
    "event.md" => "schema:\n  type: Event\n  startDate: 2026-11-02 19:00:00 +0900\n  location: {type: Place, name: Hall, address: Seoul}\n",
    "course.md" => "description: Learn the kit.\nschema:\n  type: Course\n  provider: {type: Organization, name: Example, sameAs: 'https://example.com/'}\n",
    "app.md" => "schema:\n  type: SoftwareApplication\n  applicationCategory: DeveloperApplication\n  offers: {type: Offer, price: 0, priceCurrency: USD}\n",
    "terms.md" => "schema: {type: DefinedTermSet, hasDefinedTerm: [{type: DefinedTerm, name: Token}]}\n",
    "faq.md" => "schema:\n  type: FAQPage\n  mainEntity: [{type: Question, name: Why?, acceptedAnswer: {type: Answer, text: Because.}}]\n",
    "off.md" => "schema: false\n",
  }.freeze

  def build(dir, overlay)
    src = "#{dir}/src"
    FileUtils.cp_r("#{ROOT}/example", src)
    PAGES.each { |n, fm| File.write("#{src}/#{n}", "---\ntitle: T #{n} </script>\n#{fm}---\n# T\n") }
    File.write("#{dir}/o.yml", overlay)
    out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", src, "-d", "#{dir}/s",
                              "--config", "#{src}/_config.yml,#{dir}/o.yml", chdir: ROOT)
    assert st.success?, out
    [src, "#{dir}/s"]
  end

  def graph(file) = JSON.parse(File.read(file)[%r{<script type="application/ld\+json">(.*?)</script>}m, 1])["@graph"]

  def test_types_validate_and_escape
    Dir.mktmpdir do |d|
      src, s = build(d, "url: https://example.org\nbaseurl: /docs\n")
      types = PAGES.keys.to_h { |n| [n, graph("#{s}/#{n.delete_suffix(".md")}/index.html")&.map { |x| x["@type"] }] rescue [n, nil] }
      assert_equal %w[WebSite Organization WebPage JobPosting BreadcrumbList], types["job.md"]
      assert_includes types["faq.md"], "FAQPage"
      refute_includes File.read("#{s}/off/index.html"), "ld+json"
      job = graph("#{s}/job/index.html")
      assert_equal "https://example.org/docs/#website", job[0]["@id"]
      assert_equal "Organization", job[3]["hiringOrganization"]["@type"]
      assert_equal Time.utc(2026, 11, 2, 10), Time.iso8601(graph("#{s}/event/index.html")[3]["startDate"]).utc # same instant in any CI time zone
      assert_equal "https://example.com/", graph("#{s}/course/index.html")[3]["provider"]["sameAs"]
      assert_includes File.read("#{s}/job/index.html"), '"description":"a \u003c b"'
      out, st = Open3.capture2e(RbConfig.ruby, "#{ROOT}/exe/modootoday-check", src, s, chdir: ROOT)
      assert st.success?, out
    end
  end

  def test_off_without_url_and_by_config
    Dir.mktmpdir do |d|
      _, s = build(d, "x: 1\n")
      refute_includes File.read("#{s}/index.html"), "ld+json"
    end
    Dir.mktmpdir do |d|
      _, s = build(d, "url: https://example.org\nmodootoday: {schema: false}\n")
      refute_includes File.read("#{s}/index.html"), "ld+json"
    end
  end
end

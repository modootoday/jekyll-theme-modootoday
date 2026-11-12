# frozen_string_literal: true
# Front matter feed: (lib/modootoday/check/build/feeds.rb): false, or a site path to an .xml page in the build.
require_relative "../checker_case"

class CheckFeedsTest < CheckerCase
  def setup
    super
    page "index.md", "---\n---\n# Home\n"
    out "feed.xml", "<feed/>"
  end

  def errors = check[0]

  def test_a_feed_page_in_the_build_and_false_pass
    page "blog.md", "---\nfeed: /feed.xml\n---\n# Blog\n"
    page "quiet.md", "---\nfeed: false\n---\n# Quiet\n"
    refute_match(/feed:/, errors)
  end

  def test_a_missing_feed_page_is_an_error
    page "blog.md", "---\nfeed: /blog/feed.xml\n---\n# Blog\n"
    assert_match(%r{blog\.md: feed: /blog/feed\.xml is not in the build}, errors)
  end

  def test_a_value_that_is_not_a_site_path_to_xml_is_an_error
    page "blog.md", "---\nfeed: true\n---\n# Blog\n"
    assert_match(/blog\.md: feed: must be false or a site path to the page's Atom feed, such as \/blog\/feed\.xml \(got true\)/, errors)
    page "blog.md", "---\nfeed: feed.xml\n---\n# Blog\n"
    assert_match(/got "feed\.xml"/, errors)
  end

  def test_feed_source_names_data_or_a_built_page
    page "f.xml", "---\nlayout: feed\nfeed_source: /changes/\n---\n"
    assert_match(%r{f\.xml: feed_source: /changes/ is not in the build}, errors)
    out "changes/index.html", "<html></html>"
    refute_match(/feed_source/, errors)
    page "f.xml", "---\nlayout: feed\nfeed_source: changes\n---\n"
    assert_match(/feed_source: must be data or the URL of a layout: changelog page/, errors)
  end

  def test_a_built_feed_must_be_well_formed
    out "bad.xml", "<feed><entry></feed>"
    assert_match(/bad\.xml: the Atom feed is not well-formed XML/, errors)
  end
end

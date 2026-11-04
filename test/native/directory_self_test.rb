# frozen_string_literal: true
# Collection self-detail (directory/self.html): a collection document given a directory list layout (defaults or front
# matter) has no list source, so it draws as its family's detail page with that page's sheet and structured data,
# while a page with items: keeps the list. jekyll-default-layout never sets a collection document's layout.
require "minitest/autorun"
require_relative "../support/native_site"

class DirectorySelfTest < Minitest::Test
  include NativeSite

  CONFIG = "collections: {portfolio: {output: true}, events: {output: true}}\n" \
           "defaults: [{scope: {type: portfolio}, values: {layout: portfolio}}, {scope: {type: events}, values: {layout: events}}]\n"

  def test_collection_documents_draw_as_their_detail_page
    pages = {
      "_portfolio/atlas.md" => ["title: Atlas\nclient: Acme\n"],
      "_events/meetup.md" => ["title: Meetup\nstarts: 2026-03-01T18:00:00+00:00\nvenue: Hall\n"],
      "work.md" => ["title: Work\nlayout: portfolio\nitems: [{title: Atlas, url: /portfolio/atlas/}]\n"],
    }
    Dir.mktmpdir do |d|
      _src, site = build_minima(d, pages, config: CONFIG)
      atlas = html(site, "portfolio/atlas.md")
      assert_includes atlas, 'class="mt-main mt-detail"'
      assert_includes atlas, '<article class="mt-detail-page mt-detail-project"'
      assert_match(%r{<dd>Acme</dd>}, atlas)
      assert_includes atlas, "/assets/css/modootoday-detail.css"
      refute_includes atlas, "/assets/css/modootoday-directory.css"
      assert_equal "CreativeWork", main_type(atlas)
      meetup = html(site, "events/meetup.md")
      assert_includes meetup, "mt-detail-event"
      assert_equal "Event", main_type(meetup)
      work = html(site, "work.md")
      assert_includes work, "mt-dir-page"
      assert_includes work, "/assets/css/modootoday-directory.css"
      refute_includes work, "mt-detail-page"
    end
  end

  def main_type(html) = JSON.parse(html[%r{<script type="application/ld\+json">(.*?)</script>}m, 1])["@graph"].find { |n| n["@id"].to_s.end_with?("#main") }["@type"]
end

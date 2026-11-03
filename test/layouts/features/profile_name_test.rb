# frozen_string_literal: true
require "minitest/autorun"
require_relative "../../support/layout_site"

# The name of a resume or links page comes from display_name:, never from the file name Jekyll puts in page.name.
class ProfileNameTest < Minitest::Test
  include LayoutSite

  LINKS = "links: [{label: GitHub, url: 'https://github.com/ada'}]\n"
  PAGES = {
    "cv.md" => "title: CV\nlayout: resume\ndisplay_name: Ada Lovelace\n#{LINKS}",
    "cv.ko.md" => "title: 이력서\nlang: ko\npermalink: /ko/cv/\nlayout: resume\ndisplay_name: 에이다 러브레이스\n#{LINKS}",
    "old.md" => "title: Old CV\nlayout: resume\nname: Grace Hopper\n",
    "bare.md" => "title: Bare CV\nlayout: resume\n",
    "org.md" => "title: Org links\nlayout: links\nprofile: organization\ndisplay_name: Example Org\n#{LINKS}",
  }.freeze

  def heading(site, name) = html(site, name)[%r{<h1 id="mt-cv-name" class="p-name">(.*?)</h1>}, 1]

  def person(site, name) = graph(site, name).find { |n| n["@type"] == "ProfilePage" }["mainEntity"]

  def test_name_from_front_matter_in_page_and_json_ld
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES)
      assert_equal ["Ada Lovelace", "Ada Lovelace"], [heading(s, "cv.md"), person(s, "cv.md")["name"]]
      assert_equal ["에이다 러브레이스", "에이다 러브레이스"], [heading(s, "ko/cv.md"), person(s, "ko/cv.md")["name"]]
      assert_equal ["Old CV", "Old CV"], [heading(s, "old.md"), person(s, "old.md")["name"]]
      assert_equal ["Organization", "Example Org"], person(s, "org.md").values_at("@type", "name")
      assert_equal ["Bare CV", "Bare CV"], [heading(s, "bare.md"), person(s, "bare.md")["name"]]
      out, st = check(src, s)
      assert st.success?, out
      assert_includes out, "old.md: layout resume: rename name: to display_name:"
      assert_includes out, "bare.md: layout resume: set display_name: (the title is shown as the name)"
      %w[cv.md cv.ko.md org.md].each { |n| refute_includes out, "#{n}: layout" }
    end
  end

  # Jekyll keeps name: on a collection document, so an older page there still shows it, with the rename warning.
  def test_legacy_name_on_a_collection_document
    Dir.mktmpdir do |d|
      pages = { "_people/ada.md" => "title: Ada page\nlayout: resume\nname: Ada Lovelace\n" }
      _, s = build_site(d, pages, config: "collections: {people: {output: true}}\n")
      page = File.read(Dir["#{s}/people/ada{.html,/index.html}"].fetch(0))
      assert_includes page, '<h1 id="mt-cv-name" class="p-name">Ada Lovelace</h1>'
    end
  end

  def test_resume_needs_display_name_or_title
    Dir.mktmpdir do |d|
      src, s = build_site(d, { "x.md" => "layout: resume\nname: Ada\n" })
      out, st = check(src, s)
      refute st.success?
      assert_includes out, "x.md: layout resume: set display_name: (or a title)"
    end
  end
end

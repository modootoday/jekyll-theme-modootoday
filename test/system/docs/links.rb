# frozen_string_literal: true
# Internal links of the built docs site: the link scan of modootoday-check --links (lib/modootoday/check/build/links.rb),
# failing on any problem, plus the docs rule that the header brand link goes to the page's language home.
# Usage: ruby test/system/docs/links.rb SITE_DIR [BASEURL] [--external]
# External links are NOT fetched; --external lists them for a manual review.
require "nokogiri"
require_relative "../../../lib/modootoday/check/build/links"

site = File.expand_path(ARGV[0] || "docs/_site")
baseurl = (ARGV[1] || "/jekyll-theme-modootoday").chomp("/")
brand_errors = []

found = Modootoday::Check::Links.scan(site, baseurl) do |rel, doc|
  brand = doc.at_css("a.mt-site-title")
  next unless brand
  lang = doc.at_css("html")&.[]("lang").to_s
  home = File.file?(File.join(site, lang, "index.html")) && lang != "en" ? "#{baseurl}/#{lang}/" : "#{baseurl}/"
  brand_errors << "#{rel}: brand link #{brand["href"]} is not the language home #{home}" unless brand["href"] == home
end

errors = brand_errors + found[:problems]
puts found[:external].map { |u| "external (not checked): #{u}" } if ARGV.include?("--external")
puts errors
puts "links: #{errors.size} error(s), #{found[:external].size} external URL(s) skipped"
exit(errors.empty? ? 0 : 1)

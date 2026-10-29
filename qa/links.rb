# frozen_string_literal: true
# Internal link checker for a built Jekyll site (html-proofer equivalent, no extra gems).
# Usage: ruby qa/links.rb SITE_DIR [BASEURL]
# Checks every <a href>, <link href>, <img src>, <script src> and <source srcset> that points
# inside the site: target file must exist, and "#fragment" must match an id/name on the target page.
# External links (http/https/mailto/other schemes, other hosts) are NOT fetched: they are flaky
# in CI and outside our control. They are listed with --external for a manual review.
require "nokogiri"
require "cgi"

site = File.expand_path(ARGV[0] || "docs/_site")
baseurl = (ARGV[1] || "/jekyll-theme-modootoday").chomp("/")
list_external = ARGV.include?("--external")
ids = Hash.new { |h, f| h[f] = Nokogiri::HTML(File.read(f)).css("[id],a[name]").map { |n| n["id"] || n["name"] } }
errors = []
external = []

def resolve(site, path)
  path = CGI.unescape(path)
  full = File.join(site, path)
  return full if File.file?(full)
  return File.join(full, "index.html") if File.file?(File.join(full, "index.html"))
  return "#{full}.html" if File.file?("#{full}.html")
  nil
end

Dir.glob(File.join(site, "**/*.html")).sort.each do |file|
  rel = file.delete_prefix(site)
  doc = Nokogiri::HTML(File.read(file))
  doc.css("a[href], link[href], img[src], script[src], source[srcset]").each do |n|
    url = n["href"] || n["src"] || n["srcset"].split(/\s+/).first
    next if url.nil? || url.empty?
    url = url.strip
    if url.match?(%r{\A[a-z][a-z0-9+.-]*:|\A//}i)
      external << url
      next
    end
    upath, frag = url.split("#", 2)
    upath = upath.to_s.split("?", 2).first.to_s
    if upath.empty?
      target = file
    else
      page_dir = File.dirname("#{baseurl}#{rel}")
      path = upath.start_with?("/") ? upath : File.expand_path(upath, page_dir)
      path += "/" if upath.end_with?("/") && !path.end_with?("/")
      unless path.start_with?("#{baseurl}/") || path == baseurl || baseurl.empty?
        errors << "#{rel}: #{url} is outside baseurl #{baseurl}"
        next
      end
      target = resolve(site, path.delete_prefix(baseurl))
      unless target
        errors << "#{rel}: broken link #{url}"
        next
      end
    end
    next if frag.nil? || frag.empty? || !target.end_with?(".html")
    errors << "#{rel}: missing anchor #{url}" unless ids[target].include?(CGI.unescape(frag))
  end
end

puts external.uniq.sort.map { |u| "external (not checked): #{u}" } if list_external
puts errors
puts "links: #{errors.size} error(s), #{external.uniq.size} external URL(s) skipped"
exit(errors.empty? ? 0 : 1)

# frozen_string_literal: true
# Plain Jekyll conventions in the checker (check/native/): a layout no site or theme file provides is an error that
# names the replacement for another theme's layout; a collection whose documents would get a theme list layout from
# jekyll-default-layout is a warning (self-detail) or an error (no detail).
require "yaml"
require_relative "../checker_case"

class NativeCheckTest < CheckerCase
  def test_unknown_layouts_in_pages_and_defaults
    page("_config.yml", "defaults:\n  - {scope: {path: docs}, values: {layout: splash}}\n  - {scope: {path: \"\"}, values: {layout: doc}}\n")
    page("about.markdown", "---\nlayout: single\ntitle: About\n---\nText.\n")
    page("plain.html", "---\nlayout: nope\n---\n<p>x</p>\n")
    page("ok.md", "---\nlayout: page\n---\n# Ok\n")
    page("raw.md", "---\nlayout: none\n---\n# Raw\n")
    page("_layouts/docs/endpoint.html", "---\nlayout: doc\n---\n{{ content }}\n")
    page("api.md", "---\nlayout: docs/endpoint\n---\n# Api\n")
    o, st = check
    assert_equal 1, st
    assert_includes o, "_config.yml: defaults[0]: layout splash does not exist in the site or the theme, so Jekyll writes the page without one; use home with sections (Minimal Mistakes)"
    assert_includes o, "about.markdown: layout single does not exist in the site or the theme, so Jekyll writes the page without one; use doc or post (Minimal Mistakes)"
    assert_match(/^plain\.html: layout nope does not exist .* without one$/, o)
    refute_match(/^(ok|raw|api)\.md:/, o)
  end

  def test_collections_named_like_theme_list_layouts
    page("_config.yml", "collections:\n  portfolio: {output: true}\n  feed: {output: true}\n  jobs: {output: true}\n  notes: {output: true}\n" \
                        "defaults:\n  - {scope: {type: jobs}, values: {layout: job}}\n")
    %w[portfolio feed jobs notes].each { |c| page("_#{c}/a.md", "---\ntitle: A\n---\nText.\n") }
    page("_portfolio/b.md", "---\ntitle: B\nlayout: project\n---\nText.\n")
    o, st = check
    assert_equal 1, st
    assert_includes o, "warning: _config.yml: collections.portfolio: 1 document(s) without a layout get the portfolio layout from jekyll-default-layout, which draws each as a project page; set defaults: [{scope: {type: portfolio}, values: {layout: project}}] in _config.yml"
    assert_includes o, "_config.yml: collections.feed: 1 document(s) without a layout get the feed layout from jekyll-default-layout, which cannot show one document"
    refute_match(/collections\.(jobs|notes)/, o)
  end

  def test_compat_maps_name_existing_layouts
    Dir.glob(File.join(ROOT, "lib/modootoday/schema/compat/*.yml")).each do |f|
      YAML.safe_load(File.read(f))["layouts"].each_value do |to|
        to.split(" or ").map { |t| t.split.first }.each do |name|
          assert File.file?(File.join(ROOT, "_layouts/#{name}.html")), "#{File.basename(f)}: #{to}"
        end
      end
    end
  end
end

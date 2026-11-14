# frozen_string_literal: true
# banner: {release: latest} (lib/modootoday/check/build/release_banner.rb): a build with no release banner on its home page warns.
require_relative "../checker_case"

class CheckReleaseBannerTest < CheckerCase
  HEAD = %(<html><head><link rel="stylesheet" href="/assets/css/modootoday.css"></head><body>)
  BANNER = %(<div class="mt-banner" role="region" aria-label="Announcement"><p>1.7.0 is out.</p></div>)
  WARNING = "warning: _config.yml: modootoday.banner.release: latest, but the build has no release banner"

  def setup
    super
    page "index.md", "---\n---\n# Home\n"
  end

  def config(banner, extra = "")
    write File.join(@src, "_config.yml"), "github: {repository_url: https://github.com/o/r}\nmodootoday:\n  banner: #{banner}\n#{extra}"
  end

  def test_latest_without_a_release_in_the_build_warns
    config "{release: latest}"
    out "index.html", "#{HEAD}<h1>Home</h1></body></html>"
    o, code = check
    assert_equal 0, code, o
    assert_includes o, WARNING
    assert_includes o, "set github: {latest_release: {tag_name, html_url}} in _config.yml as a stand-in, or give release: {version, url}"
  end

  def test_the_site_github_warning_names_latest_release_for_the_banner
    stand_in = "set a github: map (latest_release: {tag_name, html_url}); without it no banner is shown"
    out "index.html", "#{HEAD}#{BANNER}</body></html>"
    config "{release: latest}"
    assert_includes check[0], stand_in, "a github: map without latest_release makes no banner"
    write File.join(@src, "_config.yml"), "github: {latest_release: {tag_name: v1.7.0}}\nmodootoday:\n  banner: {release: latest}\n"
    refute_includes check[0], "reads site.github"
  end

  def test_latest_with_the_banner_built_is_quiet
    config "{release: latest}"
    out "index.html", "#{HEAD}#{BANNER}</body></html>"
    refute_includes check[0], WARNING
  end

  def test_text_a_version_map_or_the_banner_component_off_are_not_checked
    out "index.html", "#{HEAD}</body></html>"
    config "{release: {version: 1.7.0, url: /changelog/}}"
    refute_includes check[0], WARNING
    config "{text: Hi, release: latest}"
    refute_includes check[0], WARNING
    config "{release: latest}", "  components: [toc]\n"
    refute_includes check[0], WARNING
  end

  def test_a_home_page_without_the_theme_is_not_judged
    config "{release: latest}"
    out "index.html", "<html><body>plain</body></html>"
    refute_includes check[0], WARNING
  end
end

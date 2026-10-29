# frozen_string_literal: true
# The gem's i18n/ catalogs: en.yml is the registry of theme strings; include fallbacks must match it,
# every starter catalog has exactly its keys, and the checker enforces .yml and init.
require "minitest/autorun"
require "yaml"
require "tmpdir"
require "open3"
require "rbconfig"
require "fileutils"

class I18nRegistryTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  def leaves(h, pre = nil) = h.is_a?(Hash) ? h.flat_map { |k, v| leaves(v, [pre, k].compact.join(".")) } : [[pre, h]]
  def reg = leaves(YAML.safe_load(File.read("#{ROOT}/i18n/en.yml"))).to_h

  def test_no_inline_english_and_generated_catalogs_in_sync
    src = Dir.glob("#{ROOT}/{_layouts,_includes}/**/*.html").map { |f| File.read(f) }.join("\n")
    assert_empty src.scan(/(?:_ui|_i18n|_pm_ui|i18n\[[^\]]+\])\.[a-z_.]+ \| default: ["'][^"']*["']/)
    o, st = Open3.capture2e(RbConfig.ruby, "#{ROOT}/script/i18n-build", "--check")
    assert st.success?, o
  end

  # Zero copy: the example without _data/i18n renders theme UI in every shipped language;
  # a site catalog overrides key by key; unknown languages fall back to English; pt -> pt-BR.
  def test_every_language_renders_without_site_catalogs_and_overrides_win
    Dir.mktmpdir do |d|
      FileUtils.cp_r("#{ROOT}/example/.", "#{d}/s")
      FileUtils.rm_rf(["#{d}/s/_data/i18n", "#{d}/s/_site"])
      FileUtils.mkdir_p(["#{d}/s/_data/i18n", "#{d}/s/zz"])
      File.write("#{d}/s/_data/i18n/de.yml", "nav:\n  label: Site-Navigation\n")
      langs = YAML.safe_load(File.read("#{ROOT}/i18n/languages.yml"))
      (langs.map { |l| l["code"] } + %w[pt xx]).each { |c| File.write("#{d}/s/zz/#{c}.md", "---\nlang: #{c}\ntitle: T\n---\n\n## A\n\nx\n") }
      o, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", "#{d}/s", "-d", "#{d}/o", chdir: ROOT)
      assert st.success?, o
      page = ->(c) { File.read("#{d}/o/zz/#{c}/index.html") }
      langs.each do |l|
        c = l["code"]; cat = YAML.safe_load(File.read("#{ROOT}/i18n/#{c}.yml")); html = page[c]
        dir = l["dir"] == "rtl" ? ' dir="rtl"' : (c == "ur-Latn" ? ' dir="ltr"' : "")
        assert_match(/<html lang="#{c}"#{dir}[ >]/, html, c)
        assert_includes html, ">#{cat['skip']}</a>", c
        assert_includes html, %(data-mt-copy="#{cat['code']['copy']}"), c
        assert_includes html, %(aria-label="#{c == 'de' ? 'Site-Navigation' : cat['nav']['label']}"), c if html.include?('class="mt-nav"')
      end
      assert_includes page["de"], ">#{YAML.safe_load(File.read("#{ROOT}/i18n/de.yml"))['skip']}</a>"
      assert_includes page["pt"], ">#{YAML.safe_load(File.read("#{ROOT}/i18n/pt-BR.yml"))['skip']}</a>"
      assert_includes page["xx"], ">#{reg['skip']}</a>"
    end
  end

  def test_every_catalog_has_the_registry_keys
    langs = YAML.safe_load(File.read("#{ROOT}/i18n/languages.yml")).map { |l| l["code"] }
    assert_equal 23, langs.size
    langs.each do |l|
      assert_equal reg.keys.sort, leaves(YAML.safe_load(File.read("#{ROOT}/i18n/#{l}.yml"))).to_h.keys.sort, l
    end
    assert_equal "rtl", YAML.safe_load(File.read("#{ROOT}/i18n/ar.yml"))["direction"]
    assert_equal "ltr", YAML.safe_load(File.read("#{ROOT}/i18n/ur-Latn.yml"))["direction"]
  end

  def test_yaml_extension_rejected_and_init_copies
    Dir.mktmpdir do |d|
      FileUtils.mkdir_p("#{d}/_data/i18n")
      File.write("#{d}/_data/i18n/de.yaml", "skip: x\n")
      o, e, st = Open3.capture3(RbConfig.ruby, "#{ROOT}/exe/modootoday-check", d, d, "--i18n-init=fr")
      assert_equal 1, st.exitstatus
      assert_includes o + e, "rename to de.yml"
      assert File.exist?("#{d}/_data/i18n/fr.yml")
    end
  end
end

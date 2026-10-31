# frozen_string_literal: true
# Markdown twins and llms-full.txt carry a reference page's packages: table as Markdown (before the body, or after it
# with packages_position: after; packages_compact leaves out the text); pages without packages stay byte-identical.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class TwinPackagesTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  PKGS = <<~YML
    packages:
      - {name: "core", version: "1.0", text: "Parse | render\\nthe model.", url: "https://example.org/core", links: [{label: "Docs", url: "/docs/"}, {label: "Src", url: "#"}]}
      - {name: "cli"}
  YML
  PAGES = {
    "plain" => "---\ntitle: Plain\nlayout: reference\n---\n# Plain\n\nBody.\n",
    "before" => "---\ntitle: Before\nlayout: reference\npackages_title: \"Pkgs\"\n#{PKGS}---\nBody.\n",
    "after" => "---\ntitle: After\nlayout: reference\npackages_position: after\npackages_compact: true\n#{PKGS}---\nBody.\n",
    "docpage" => "---\ntitle: Doc\nlayout: doc\n#{PKGS}---\nBody.\n"
  }.freeze

  def self.out
    @out ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: Site\nurl: https://example.org\nbaseurl: /b\npermalink: pretty\n")
      PAGES.each do |n, t|
        File.write(File.join(src, "#{n}.md"), t)
        File.write(File.join(src, "#{n}.md.txt"), "---\nlayout: twin\ntwin_of: #{n}.md\npermalink: /#{n}/index.md\n---\n")
      end
      File.write(File.join(src, "llms-full.txt"), "---\nlayout: llms-full\npermalink: /llms-full.txt\n---\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      ->(p) { File.read(File.join(dir, "_site", p)) }
    end
  end

  def twin(n) = self.class.out.call("#{n}/index.md")

  def test_without_packages_twin_is_the_body
    assert_equal "# Plain\n\nBody.\n", twin("plain")
    assert_equal "Body.\n", twin("docpage") # only the reference layout shows the table
  end

  def test_table_before_body_with_title_and_text
    assert_equal <<~MD, twin("before")
      **Pkgs**

      | Name | Version | Links |
      | --- | --- | --- |
      | [`core`](https://example.org/core): Parse \\| render the model. | `1.0` | [Docs](/b/docs/), [Src](#) |
      | `cli` |  |  |

      Body.
    MD
  end

  def test_compact_table_after_body
    assert_equal <<~MD, twin("after")
      Body.

      | Name | Version | Links |
      | --- | --- | --- |
      | [`core`](https://example.org/core) | `1.0` | [Docs](/b/docs/), [Src](#) |
      | `cli` |  |  |
    MD
  end

  def test_llms_full_has_the_tables
    full = self.class.out.call("llms-full.txt")
    assert_includes full, twin("before")
    assert_includes full, twin("after")
    assert_includes full, "# Plain\n\nBody.\n"
  end
end

# frozen_string_literal: true
# Audit fixtures (test/fixtures/md): source -> expected checker messages ([] = clean). Run: bundle exec rake test
require_relative "../checker_case"

class CheckCorpusTest < CheckerCase
  FIX = File.expand_path("../../fixtures/md", __dir__)
  EXPECT = {
    "a01-note" => [], "a06-lowercase" => [], "a07-mixedcase" => [], "a09-multipara" => [], "a14-crlf" => [],
    "a16-lazy-continuation" => [], "a17-blank-gt-after" => [], "a19-code-inside" => [], "a21-inline-first-body" => [],
    "a22-no-space" => [], "a23-indented-3sp" => [], "a24-list-first-body" => [], "a25-two-adjacent" => [],
    "a28-trailing-spaces" => [], "a27-heading-first" => ["'##' inside a quote/alert"],
    "a08-unknown-type" => ["unregistered alert type [!FOO]"],
    "a10-trailing-text" => ["text after [!NOTE]"],
    "a11-nested" => ["alert nested"], "a12-in-list" => ["alert nested"], "a13-in-table" => ["alert nested"],
    "a15-tab-after-gt" => ["tab after '>'"],
    "a18-empty" => ["empty alert"],
    "a20-bold-title-line" => ["formatted alert marker"],
    "a29-h2-in-alert-sections" => ["'##' inside a quote/alert"],
    "s01-setext" => ["setext heading"],
    "s03-hash-in-quote" => ["'##' inside a quote/alert"],
    "s05-indented-hash" => ["indented '##'"],
    "s06-hash-in-html-comment" => ["HTML comment", "'##' inside an HTML comment"],
    "s09-h2-in-list" => ["'##' inside a list item"],
    "s02-hash-in-fence" => [], "s04-trailing-hashes" => [], "s07-no-space" => [], "s08-fence-4backticks" => [],
    "t01-tabs-backtick" => [], "t02-tabs-tilde" => [], "t03-tabs-indented" => [], "m01-mermaid" => [],
    "d01-diagram-ok" => [], "d01-diagram-count" => [], "d01-diagram-alt" => [],
    "t04-info-attrs" => ["info string must be a single language word"],
    "t05-info-space-attr" => ["info string must be a single language word"],
    "t06-info-lang-only-tilde-attr" => ["info string must be a single language word"],
    "f01-raw-html-in-code" => [], "f09-tasklist-strike" => [], "f10-footnote" => [], "f17-autolink-angle" => [],
    "f18-hard-break" => [], "g01-table" => [], "b01-badge" => [], "c01-cta" => [], "c02-cta-separator" => [], "c03-card-emdash" => [],
    "f02-html-comment" => ["HTML comment"], "f04-ial" => ["IAL"], "f05-header-id" => ["{#id}"], "f06-deflist" => ["definition list"],
    "f07-raw-details" => ["raw HTML"], "f08-autolink-email" => ["bare URL"], "f12-liquid-in-text" => ["Liquid"],
    "f13-kramdown-toc" => ["IAL"], "f14-abbr" => ["abbreviation"], "f16-tagfilter" => ["raw HTML"], "f19-html-inline-kbd" => ["raw HTML"]
  }.freeze
  SECS = { "a29-h2-in-alert-sections" => 1, "s02-hash-in-fence" => 1, "s03-hash-in-quote" => 1, "s04-trailing-hashes" => 2,
           "s06-hash-in-html-comment" => 1, "s08-fence-4backticks" => 1, "s09-h2-in-list" => 1, "s01-setext" => 1 }.freeze

  EXPECT.each do |name, msgs|
    define_method("test_fixture_#{name.tr('-', '_')}") do
      secs = SECS[name] ? "sections: [#{(1..SECS[name]).map { |i| "s#{i}" }.join(', ')}]\n" : ""
      write File.join(@src, "#{name}.md"), "---\n#{secs}---\n" + File.binread(File.join(FIX, "#{name}.md"))
      o, code = check
      if msgs.empty?
        assert_equal 0, code, o
      else
        assert_equal 1, code, o
        msgs.each { |m| assert_includes o, m }
      end
    end
  end

  def test_every_fixture_has_an_expectation
    covered = EXPECT.keys + %w[a02-tip a03-important a04-warning a05-caution a26-space-inside b02-badge-double-backtick
                               f03-liquid-in-code f11-math-dollar f15-smart-quotes]
    assert_empty Dir.children(FIX).map { |f| File.basename(f, ".md") } - covered
  end
end

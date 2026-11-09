# frozen_string_literal: true
# Every spec id cited outside .spec/ (CHANGELOG, docs, tests, scripts, code) names a committed .spec document.
# Drafts kept in the git-ignored local spec directory are never committed, so an id that lives only there fails.
require "minitest/autorun"

class SpecIdsTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  TYPES = %w[adr audit research sot change plan].freeze
  ID = %r{\b(#{TYPES.join("|")}):modootoday/([a-z0-9][a-z0-9-]*[a-z0-9])}

  def tracked = @tracked ||= Dir.chdir(ROOT) { `git ls-files -z`.split("\0") }
  def documents = @documents ||= tracked.select { |f| f.start_with?(".spec/") }.map { |f| f.delete_prefix(".spec/") }

  # Dated ids are the timestamp a document's file name starts with; other ids (sot slugs) are the whole name.
  def resolves?(type, id)
    want = id.match?(/\A\d{14}\z/) ? ->(n) { n.start_with?("#{id}-") } : ->(n) { n == "#{id}.#{type}.md" }
    documents.any? { |d| d.start_with?("#{type}/") && want.call(File.basename(d)) }
  end

  def cited
    tracked.reject { |f| f.start_with?(".spec/") }.each_with_object(Hash.new { |h, k| h[k] = [] }) do |f, acc|
      path = File.join(ROOT, f)
      next unless File.file?(path)

      src = File.binread(path)
      next if src.include?("\0")

      src.force_encoding(Encoding::UTF_8).scan(ID) { |type, id| acc["#{type}:modootoday/#{id}"] << f }
    end
  end

  def test_every_cited_id_names_a_committed_document
    ids = cited
    refute_empty ids, "the CHANGELOG and the tests cite ADRs"
    missing = ids.reject { |key, _| resolves?(*key.split(":modootoday/")) }
    assert_empty missing.transform_values(&:uniq), "commit the document under .spec/, or cite one that is committed"
  end

  def test_resolution_matches_dated_and_slug_ids
    dated = documents.find { |d| d.start_with?("adr/") }
    assert resolves?("adr", File.basename(dated)[/\A\d{14}/])
    refute resolves?("adr", "19990101000000")
    refute resolves?("research", "19990101000000"), "a local-only draft does not resolve"
    sot = documents.find { |d| d.start_with?("sot/") }
    assert resolves?("sot", File.basename(sot, ".sot.md"))
    refute resolves?("sot", File.basename(sot, ".sot.md")[0, 4])
  end
end

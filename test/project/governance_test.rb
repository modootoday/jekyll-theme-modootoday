# frozen_string_literal: true
# Community and release files: present, pointing at private reporting, without invented contacts.
require "minitest/autorun"
require "yaml"

class GovernanceTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  PVR = "https://github.com/modootoday/jekyll-theme-modootoday/security/advisories/new"
  def read(f) = File.read(File.join(ROOT, f))

  def test_files_exist
    %w[SECURITY.md CODE_OF_CONDUCT.md CONTRIBUTING.md RELEASING.md .github/pull_request_template.md
       .github/ISSUE_TEMPLATE/bug_report.yml .github/ISSUE_TEMPLATE/feature_request.yml .github/ISSUE_TEMPLATE/config.yml].each do |f|
      assert File.file?(File.join(ROOT, f)), f
    end
  end

  def test_private_reporting_and_no_email_contacts
    assert_includes read("SECURITY.md"), PVR
    assert_includes read("CODE_OF_CONDUCT.md"), PVR
    assert_includes read("CODE_OF_CONDUCT.md"), "version 2.1"
    %w[SECURITY.md CODE_OF_CONDUCT.md RELEASING.md].each do |f|
      refute_match(/[\w.+-]+@[\w-]+\.[\w.]+/, read(f), "#{f}: no e-mail addresses")
      refute_includes read(f), "INSERT", f
    end
    assert_equal PVR, YAML.safe_load(read(".github/ISSUE_TEMPLATE/config.yml"))["contact_links"].first["url"]
  end

  def test_dependabot_covers_actions_bundler_and_npm
    eco = YAML.safe_load(read(".github/dependabot.yml"))["updates"].map { |u| u["package-ecosystem"] }
    assert_equal %w[bundler github-actions npm], eco.sort
  end

  def test_issue_forms_parse
    Dir.glob(File.join(ROOT, ".github/ISSUE_TEMPLATE/*.yml")).each { |f| assert YAML.safe_load(File.read(f)), f }
  end
end

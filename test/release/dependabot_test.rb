# frozen_string_literal: true
# The Dependabot merge workflow waits for every pull_request workflow and merges only the head commit it judged.
require "minitest/autorun"
require "yaml"

class DependabotTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  WORKFLOWS = Dir[File.join(ROOT, ".github/workflows/*.yml")].to_h { |f| [File.basename(f), YAML.safe_load(File.read(f))] }
  MERGE = WORKFLOWS.fetch("dependabot-auto-merge.yml")

  # YAML 1.1 reads the bare key on as true.
  def triggers(wf) = wf[true].is_a?(Hash) ? wf[true].keys : Array(wf[true])

  def test_the_merge_waits_for_every_pull_request_workflow
    pr = WORKFLOWS.values.select { |wf| triggers(wf).include?("pull_request") }.map { |wf| wf["name"] }
    assert_includes pr, "CI"
    assert_equal pr.sort, MERGE.dig(true, "workflow_run", "workflows").sort, "a workflow on pull_request is missing from the trigger list"
    assert_equal ["completed"], MERGE.dig(true, "workflow_run", "types")
  end

  def test_the_merge_judges_the_latest_run_per_workflow_and_the_same_head_commit
    job = MERGE.dig("jobs", "merge")
    assert_includes job["if"], "github.repository == 'modootoday/jekyll-theme-modootoday'"
    assert_includes job["if"], "startsWith(github.event.workflow_run.head_branch, 'dependabot/')"
    run = job["steps"].map { |s| s["run"].to_s }.join("\n")
    assert_includes run, "group_by(.workflow_id) | map(max_by(.run_number))"
    assert_includes run, "completed\\|(success|skipped)$"
    assert_includes run, '--match-head-commit "$SHA"'
  end

  def test_updates_wait_two_weeks_and_leave_the_pages_pins_alone
    updates = YAML.safe_load(File.read(File.join(ROOT, ".github/dependabot.yml")))["updates"]
    updates.each { |u| assert_equal({ "default-days" => 14 }, u["cooldown"], u["package-ecosystem"]) }
    bundler = updates.find { |u| u["package-ecosystem"] == "bundler" }["ignore"].map { |i| i["dependency-name"] }
    assert_equal %w[github-pages jekyll-optional-front-matter jekyll-titles-from-headings nokogiri], bundler.sort
  end
end

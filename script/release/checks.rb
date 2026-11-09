# frozen_string_literal: true

require "json"
require "open3"
require_relative "changelog"

module Release
  # The release check (RELEASING.md): the slow workflows started by hand on the release commit, and their results.
  # script/release-prep dispatches them, script/release-status reports them, release.yml requires them.
  module Checks
    WORKFLOWS = %w[ci.yml lighthouse.yml visual.yml].freeze
    BASE_INPUT = { "visual.yml" => "base" }.freeze # compared with the previous release tag
    Run = Struct.new(:workflow, :status, :conclusion, :url) do
      def ok? = status == "completed" && conclusion == "success"
    end

    module_function

    # The repository as owner/name: GITHUB_REPOSITORY in Actions, else the gemspec homepage.
    def repo
      ENV["GITHUB_REPOSITORY"] || File.read(File.join(Changelog::ROOT, "jekyll-theme-modootoday.gemspec"))[%r{homepage\s*=\s*"https://github\.com/([^"]+)"}, 1]
    end

    def dispatch(ref, base)
      WORKFLOWS.each do |w|
        args = ["gh", "workflow", "run", w, "--repo", repo, "--ref", ref]
        args += ["-f", "#{BASE_INPUT[w]}=#{base}"] if BASE_INPUT[w]
        system(*args) or raise Error, "gh workflow run #{w} failed"
      end
    end

    # The newest manual run of each workflow on sha (a push run of ci.yml skips the slow jobs, so it does not count).
    def runs(sha)
      WORKFLOWS.map do |w|
        out, err, st = Open3.capture3("gh", "api", "repos/#{repo}/actions/workflows/#{w}/runs?head_sha=#{sha}&event=workflow_dispatch&per_page=1")
        raise Error, "gh api: #{err.strip}" unless st.success?

        r = JSON.parse(out)["workflow_runs"].first
        r ? Run.new(w, r["status"], r["conclusion"], r["html_url"]) : Run.new(w, "missing", nil, nil)
      end
    end

    def table(runs)
      rows = runs.map { |r| "| #{r.workflow} | #{r.status} | #{r.conclusion || "-"} | #{r.url || "-"} |" }
      (["| workflow | status | conclusion | run |", "| --- | --- | --- | --- |"] + rows).join("\n")
    end
  end
end

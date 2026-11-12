# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      ISSUES_URL = %r{\Ahttps?://\S+/issues\z}
      # modootoday.feedback (meta/feedback.html): prefilled issue links and a discussion link, no script.
      feedback = lambda do |ctx, path, v|
        issues = v["issues"]
        unless issues.nil? || issues == false || issues == "auto" || issues.to_s.match?(ISSUES_URL)
          ctx.errs << "_config.yml: #{path}.issues must be auto, false or a repository's issues URL such as https://github.com/OWNER/REPO/issues (got #{issues.inspect})"
        end
        GITHUB_SOURCE.call(ctx, "#{path}.issues", issues)
        ctx.errs << "_config.yml: #{path}.helpful must be true or false" unless [nil, true, false].include?(v["helpful"])
        ctx.warns << "_config.yml: #{path}.helpful: true needs issues:, since both answers are prefilled issue links" if v["helpful"] == true && [nil, false].include?(issues)
        ctx.errs << "_config.yml: #{path}.discuss must be an http(s) URL (got #{v["discuss"].inspect})" unless v["discuss"].nil? || v["discuss"].to_s.match?(Validate::URL)
        labels = v["labels"]
        ctx.errs << "_config.yml: #{path}.labels must be a list of label names" unless labels.nil? || (labels.is_a?(Array) && labels.all? { |l| l.is_a?(String) && !l.strip.empty? })
      end
      Schema.register(Key.new(name: "feedback", type: :map, keys: %w[issues helpful discuss labels], check: feedback,
                              message: "must be a map of issues, helpful, discuss and labels (got %{got})"))
    end
  end
end

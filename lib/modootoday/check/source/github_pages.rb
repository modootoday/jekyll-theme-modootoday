# frozen_string_literal: true

module Modootoday
  module Check
    # 6. --github-pages[=VERSION]: the lockfile pins github-pages VERSION (default 232 or $MODOOTODAY_GITHUB_PAGES).
    module GithubPages
      module_function

      def call(ctx)
        return unless (gp = ctx.argv.find { |a| a == "--github-pages" || a.start_with?("--github-pages=") })
        want = gp.include?("=") ? gp.split("=", 2)[1] : ENV.fetch("MODOOTODAY_GITHUB_PAGES", "232")
        lock = "#{ctx.src}/Gemfile.lock" # the site's own lockfile wins; else the active bundle's lockfile
        lock = "#{ENV['BUNDLE_GEMFILE']}.lock" if !File.exist?(lock) && ENV["BUNDLE_GEMFILE"] && File.exist?("#{ENV['BUNDLE_GEMFILE']}.lock")
        if File.exist?(lock) && (v = File.read(lock)[/^    github-pages \((\d+)\)/, 1])
          ctx.errs << "#{lock}: github-pages #{v} != #{want}" unless v == want
        else
          ctx.errs << "--github-pages: no Gemfile.lock with github-pages found (#{lock}); run `bundle lock` (the file may stay gitignored) " \
                     "or point BUNDLE_GEMFILE at a Gemfile whose .lock pins github-pages, or drop --github-pages"
        end
      end
    end
  end
end

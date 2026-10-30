# frozen_string_literal: true

module Modootoday
  module Check
    module Layouts
      # Page shells: error status, redirect target, home hero; and the search fallback in _config.yml.
      module Shells
        STATUSES = [404, 410, 500].freeze

        module_function

        def error(errs, where, fm, _ctx)
          s = fm.fetch("status", 404)
          errs << "#{where}: status must be one of #{STATUSES.join(', ')} (got #{s.inspect})" unless STATUSES.include?(s)
        end

        def redirect(errs, where, fm, _ctx)
          to = fm["redirect_to"]
          errs << "#{where}: redirect_to is required (a site path starting with / or a full URL)" unless to.is_a?(String) && to.match?(%r{\A(/|https?://)})
        end

        def home(errs, where, fm, _ctx)
          hero = fm["hero"]
          return if hero.nil?
          return errs << "#{where}: hero must be a map of title, text, actions" unless hero.is_a?(Hash)
          (hero.keys - %w[title text actions]).each { |k| errs << "#{where}: hero has unknown key '#{k}' (known: title, text, actions)" }
          errs << "#{where}: hero.title is required when hero is set" unless Shape.text?(hero["title"])
          actions(errs, where, "hero.actions", hero["actions"])
        end

        def actions(errs, where, key, acts)
          return if acts.nil?
          return errs << "#{where}: #{key} must be a list of {label, url}" unless acts.is_a?(Array)
          acts.each_with_index do |a, i|
            errs << "#{where}: #{key}[#{i}] needs label and url" unless a.is_a?(Hash) && a["label"].is_a?(String) && a["url"].is_a?(String)
          end
        end

        def fallback(errs, fb)
          return if fb.nil? || fb == false
          return errs << "_config.yml: modootoday.search.fallback must be false or a map of url, param" unless fb.is_a?(Hash)
          errs << "_config.yml: modootoday.search.fallback.url must be an https URL" if fb.key?("url") && !fb["url"].to_s.start_with?("https://")
        end
      end
    end
  end
end

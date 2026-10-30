# frozen_string_literal: true

module Modootoday
  module Check
    module Layouts
      # Docs-extra layouts (reference, changelog, roadmap, glossary, hub, course, book) and the documents legal and resume.
      module DocsExtra
        LAYOUTS = %w[reference changelog roadmap glossary hub course book legal resume].freeze
        CATS = %w[added changed fixed removed security].freeze
        STATUS = %w[now next later].freeze

        module_function

        def url(errs, where, key, v) = (errs << "#{where}: #{key} must be a site path or a full URL" unless v.nil? || Shape.url?(v))

        def call(errs, w, fm, _ctx)
          send(fm["layout"], errs, w, fm)
        end

        def reference(errs, w, fm) = Shape.list(errs, w, "members", fm["members"], any: %w[name], optional: false)

        def changelog(errs, w, fm)
          Shape.list(errs, w, "releases", fm["releases"], any: %w[version], optional: false) do |r, i|
            Shape.need_date(errs, w, "releases[#{i}].date", r["date"], optional: true)
            CATS.each { |c| errs << "#{w}: releases[#{i}].#{c} must be a list" unless r[c].nil? || r[c].is_a?(Array) }
            extra = r.keys - CATS - %w[version date url]
            errs << "#{w}: releases[#{i}] has unknown keys #{extra.join(', ')} (use #{CATS.join(', ')})" unless extra.empty?
          end
        end

        def roadmap(errs, w, fm)
          Shape.list(errs, w, "items", fm["items"], optional: false) do |it, i|
            Shape.one_of(errs, w, "items[#{i}].status", it["status"] || "(none)", STATUS)
            url(errs, w, "items[#{i}].url", it["url"])
          end
        end

        def glossary(errs, w, fm)
          Shape.list(errs, w, "terms", fm["terms"], any: %w[term], optional: false) do |t, i|
            errs << "#{w}: terms[#{i}].text is required" unless Shape.text?(t["text"])
          end
          names = Array(fm["terms"]).filter_map { |t| t["term"].to_s.downcase if t.is_a?(Hash) }
          names.tally.each { |n, c| errs << "#{w}: term '#{n}' is listed #{c} times" if c > 1 }
        end

        def hub(errs, w, fm)
          Shape.list(errs, w, "cards", fm["cards"], optional: false) { |c, i| errs << "#{w}: cards[#{i}].url is required" unless Shape.url?(c["url"]) }
        end

        def course(errs, w, fm)
          errs << "#{w}: description is required (Course structured data)" unless Shape.text?(fm["description"])
          Shape.list(errs, w, "modules", fm["modules"], optional: false) do |m, i|
            Shape.list(errs, w, "modules[#{i}].lessons", m["lessons"]) do |l, j|
              errs << "#{w}: modules[#{i}].lessons[#{j}].minutes must be a number" unless l["minutes"].nil? || l["minutes"].is_a?(Integer)
              url(errs, w, "modules[#{i}].lessons[#{j}].url", l["url"])
            end
          end
        end

        def book(errs, w, fm)
          errs << "#{w}: pages must be a number" unless fm["pages"].nil? || fm["pages"].is_a?(Integer)
          errs << "#{w}: isbn must be 10 or 13 digits" unless fm["isbn"].nil? || fm["isbn"].to_s.delete("- ").match?(/\A(\d{9}[\dX]|\d{13})\z/)
          Shape.list(errs, w, "chapters", fm["chapters"]) { |c, i| url(errs, w, "chapters[#{i}].url", c["url"]) }
        end

        def legal(errs, w, fm)
          Shape.need_date(errs, w, "effective", fm["effective"])
          Shape.need_date(errs, w, "updated", fm["updated"], optional: true)
          Shape.list(errs, w, "toc", fm["toc"])
        end

        def resume(errs, w, fm)
          errs << "#{w}: set name: (or a title)" unless Shape.text?(fm["name"]) || Shape.text?(fm["title"])
          Shape.list(errs, w, "experience", fm["experience"], any: %w[role]) do |e, i|
            Shape.need_date(errs, w, "experience[#{i}].start", e["start"], optional: true)
            Shape.need_date(errs, w, "experience[#{i}].end", e["end"], optional: true)
          end
          Shape.list(errs, w, "education", fm["education"], any: %w[school])
          Shape.list(errs, w, "skills", fm["skills"], any: %w[group]) { |s, i| errs << "#{w}: skills[#{i}].items must be a list" unless s["items"].is_a?(Array) }
          Shape.list(errs, w, "links", fm["links"], any: %w[label]) { |l, i| url(errs, w, "links[#{i}].url", l["url"]) }
        end
      end
    end
  end
end

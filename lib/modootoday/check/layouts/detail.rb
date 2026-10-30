# frozen_string_literal: true

module Modootoday
  module Check
    module Layouts
      # Detail layouts (project, case-study, job, event, episode): the front matter each one reads for its facts,
      # call to action and JSON-LD (_includes/modootoday/detail/).
      module Detail
        LAYOUTS = %w[project case-study job event episode].freeze
        EMPLOYMENT = %w[full-time part-time contractor temporary intern volunteer per-diem other].freeze

        module_function

        def call(errs, where, fm, _ctx)
          links(errs, where, fm)
          send(fm["layout"].tr("-", "_"), errs, where, fm) if respond_to?(fm["layout"].tr("-", "_"))
        end

        def links(errs, where, fm)
          Shape.list(errs, where, "links", fm["links"], any: %w[label]) { |l, i| errs << "#{where}: links[#{i}].url is required" unless Shape.url?(l["url"]) }
          errs << "#{where}: stack must be a list" unless fm["stack"].nil? || fm["stack"].is_a?(Array)
          cta = fm["cta"]
          errs << "#{where}: cta must be a map of label and url" unless cta.nil? || (cta.is_a?(Hash) && Shape.text?(cta["label"]) && Shape.url?(cta["url"]))
        end

        def job(errs, where, fm)
          Shape.need_date(errs, where, "date", fm["date"])
          Shape.need_date(errs, where, "deadline", fm["deadline"], optional: true)
          Shape.one_of(errs, where, "employment", fm["employment"], EMPLOYMENT)
          errs << "#{where}: set location: (a place) or remote: (the country applicants must live in)" unless Shape.text?(fm["location"]) || Shape.text?(fm["remote"])
          errs << "#{where}: apply must be a site path, full URL or mailto: link" unless fm["apply"].nil? || Shape.url?(fm["apply"])
          s = fm["salary"]
          errs << "#{where}: salary must be text or a map of min, max, currency, unit" unless s.nil? || s.is_a?(String) || (s.is_a?(Hash) && s["min"].is_a?(Numeric) && Shape.text?(s["currency"]))
        end

        def event(errs, where, fm)
          Shape.need_date(errs, where, "starts", fm["starts"])
          Shape.need_date(errs, where, "ends", fm["ends"], optional: true)
          errs << "#{where}: set venue: (a place) or online: (an https URL)" unless Shape.text?(fm["venue"]) || fm["online"].to_s.start_with?("https://")
          errs << "#{where}: tickets must be a site path or full URL" unless fm["tickets"].nil? || Shape.url?(fm["tickets"])
        end

        def episode(errs, where, fm)
          errs << "#{where}: episode must be a number" unless fm["episode"].is_a?(Integer)
          errs << "#{where}: season must be a number" unless fm["season"].nil? || fm["season"].is_a?(Integer)
          errs << "#{where}: duration must be minutes (a number)" unless fm["duration"].nil? || fm["duration"].is_a?(Integer)
          %w[audio transcript].each { |k| errs << "#{where}: #{k} must be a site path or full URL" unless fm[k].nil? || Shape.url?(fm[k]) }
        end
      end
    end
  end
end

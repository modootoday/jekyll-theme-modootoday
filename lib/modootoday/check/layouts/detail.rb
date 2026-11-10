# frozen_string_literal: true

module Modootoday
  module Check
    module Layouts
      # Detail layouts (project, case-study, job, event, episode): the front matter each one reads for its facts,
      # call to action and JSON-LD (_includes/modootoday/detail/).
      module Detail
        LAYOUTS = %w[project case-study job event episode].freeze
        TICKETS = %w[url price currency].freeze
        PRICE_HINT = "tickets: give {url, price, currency} so the event offer has a price (a nested offer without one is an error in the next major version)"
        EMPLOYMENT = %w[full-time part-time contractor temporary intern volunteer per-diem other].freeze

        module_function

        def call(errs, where, fm, ctx)
          links(errs, where, fm)
          m = fm["layout"].tr("-", "_")
          send(m, errs, where, fm, ctx) if respond_to?(m)
        end

        def links(errs, where, fm)
          Shape.list(errs, where, "links", fm["links"], any: %w[label]) { |l, i| errs << "#{where}: links[#{i}].url is required" unless Shape.url?(l["url"]) }
          errs << "#{where}: stack must be a list" unless fm["stack"].nil? || fm["stack"].is_a?(Array)
          cta = fm["cta"]
          errs << "#{where}: cta must be a map of label and url" unless cta.nil? || (cta.is_a?(Hash) && Shape.text?(cta["label"]) && Shape.url?(cta["url"]))
        end

        def job(errs, where, fm, _ctx)
          Shape.need_date(errs, where, "date", fm["date"])
          Shape.need_date(errs, where, "deadline", fm["deadline"], optional: true)
          Shape.one_of(errs, where, "employment", fm["employment"], EMPLOYMENT)
          errs << "#{where}: set location: (a place) or remote: (the country applicants must live in)" unless Shape.text?(fm["location"]) || Shape.text?(fm["remote"])
          errs << "#{where}: apply must be a site path, full URL or mailto: link" unless fm["apply"].nil? || Shape.url?(fm["apply"])
          s = fm["salary"]
          errs << "#{where}: salary must be text or a map of min, max, currency, unit" unless s.nil? || s.is_a?(String) || (s.is_a?(Hash) && s["min"].is_a?(Numeric) && Shape.text?(s["currency"]))
        end

        def event(errs, where, fm, ctx)
          Shape.need_date(errs, where, "starts", fm["starts"])
          Shape.need_date(errs, where, "ends", fm["ends"], optional: true)
          errs << "#{where}: set venue: (a place) or online: (an https URL)" unless Shape.text?(fm["venue"]) || fm["online"].to_s.start_with?("https://")
          tickets(errs, where, fm["tickets"]) unless fm["tickets"].nil?
          ctx.warns << "#{where}: #{PRICE_HINT}" unless fm["tickets"].nil? || priced?(fm)
        end

        # tickets: a site path or URL, or {url, price, currency} (price and currency together, or neither).
        def tickets(errs, where, t)
          return errs << "#{where}: tickets must be a site path or full URL, or a map of url, price and currency" unless t.is_a?(Hash) || Shape.url?(t)
          return unless t.is_a?(Hash)
          (t.keys - TICKETS).each { |k| errs << "#{where}: tickets has unknown key '#{k}' (url, price, currency)" }
          errs << "#{where}: tickets.url must be a site path or full URL" unless Shape.url?(t["url"])
          errs << "#{where}: tickets.price must be a number of 0 or more (0 is shown as free)" unless t["price"].nil? || (t["price"].is_a?(Numeric) && t["price"] >= 0)
          errs << "#{where}: tickets.currency must be an ISO 4217 code such as KRW or USD" unless t["currency"].nil? || t["currency"].to_s.match?(/\A[A-Z]{3}\z/)
          errs << "#{where}: tickets needs price and currency together, or neither" if t["price"].nil? != t["currency"].nil?
        end

        # The offer gets a price from the tickets map, or the page gives its own schema.offers.
        def priced?(fm) = (fm["tickets"].is_a?(Hash) && !fm["tickets"]["price"].nil?) || (fm["schema"].is_a?(Hash) && fm["schema"].key?("offers"))

        def episode(errs, where, fm, _ctx)
          errs << "#{where}: episode must be a number" unless fm["episode"].is_a?(Integer)
          errs << "#{where}: season must be a number" unless fm["season"].nil? || fm["season"].is_a?(Integer)
          errs << "#{where}: duration must be minutes (a number)" unless fm["duration"].nil? || fm["duration"].is_a?(Integer)
          %w[audio transcript].each { |k| errs << "#{where}: #{k} must be a site path or full URL" unless fm[k].nil? || Shape.url?(fm[k]) }
        end
      end
    end
  end
end

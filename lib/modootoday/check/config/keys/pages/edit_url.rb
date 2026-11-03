# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "edit_url", type: :url, pattern: %r{\Ahttps?://\S+/\z},
                              message: "must be an http(s) URL ending in / (page.path is appended)"))
    end
  end
end

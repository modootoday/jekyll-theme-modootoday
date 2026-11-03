# frozen_string_literal: true

module Modootoday
  module Check
    module Layouts
      # The display name of a resume or links page (_includes/modootoday/profile/name.html reads the same keys).
      module Profile
        LAYOUTS = %w[resume links].freeze

        module_function

        # Jekyll replaces a page's name: with its file name, so only display_name: reaches the page and its Person.
        def call(ctx, where, fm)
          return if Shape.text?(fm["display_name"])
          return ctx.warns << "#{where}: rename name: to display_name: (on a page, Jekyll shows the file name for name:)" if fm.key?("name")
          ctx.warns << "#{where}: set display_name: (the title is shown as the name)"
        end
      end
    end
  end
end

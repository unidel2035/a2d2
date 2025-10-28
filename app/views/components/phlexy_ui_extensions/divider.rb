# frozen_string_literal: true

module PhlexyUI
  class Divider < Base
    def view_template(&block)
      div(**attrs) do
        plain(yield) if block_given?
      end
    end

    private

    def default_attrs
      { class: "divider" }
    end
  end
end

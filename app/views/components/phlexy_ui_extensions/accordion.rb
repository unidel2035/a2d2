# frozen_string_literal: true

module PhlexyUI
  class Accordion < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      { class: "join join-vertical w-full" }
    end
  end
end

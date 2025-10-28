# frozen_string_literal: true

module PhlexyUI
  class Collapse < Base
    def view_template(&)
      div(**attrs, &)
    end

    def title(**attributes, &block)
      div(**mix(attributes, { class: "collapse-title" }), &block)
    end

    def content(&block)
      div(class: "collapse-content", &block)
    end

    private

    def default_attrs
      { class: "collapse" }
    end
  end
end

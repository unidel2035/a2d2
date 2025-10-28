# frozen_string_literal: true

module PhlexyUI
  class Hero < Base
    def view_template(&)
      div(**attrs, &)
    end

    def content(**attributes, &block)
      div(**mix(attributes, { class: "hero-content" }), &block)
    end

    def overlay(**attributes, &block)
      div(**mix(attributes, { class: "hero-overlay" }), &block)
    end

    private

    def default_attrs
      { class: "hero" }
    end
  end
end

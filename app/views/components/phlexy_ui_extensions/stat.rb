# frozen_string_literal: true

module PhlexyUI
  class Stat < Base
    def view_template(&)
      div(**attrs, &)
    end

    def title(**attributes, &block)
      div(**mix(attributes, { class: "stat-title" }), &block)
    end

    def value(**attributes, &block)
      div(**mix(attributes, { class: "stat-value" }), &block)
    end

    def desc(**attributes, &block)
      div(**mix(attributes, { class: "stat-desc" }), &block)
    end

    def figure(**attributes, &block)
      div(**mix(attributes, { class: "stat-figure" }), &block)
    end

    def actions(**attributes, &block)
      div(**mix(attributes, { class: "stat-actions" }), &block)
    end

    private

    def default_attrs
      { class: "stat" }
    end
  end
end

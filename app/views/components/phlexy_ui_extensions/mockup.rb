# frozen_string_literal: true

module PhlexyUI
  class Mockup < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      { class: "mockup-code" }
    end
  end
end

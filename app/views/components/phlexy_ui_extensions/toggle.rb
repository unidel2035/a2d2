# frozen_string_literal: true

module PhlexyUI
  class Toggle < Base
    def view_template
      input(**attrs)
    end

    private

    def default_attrs
      { class: "toggle", type: "checkbox" }
    end
  end
end

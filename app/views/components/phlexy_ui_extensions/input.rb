# frozen_string_literal: true

module PhlexyUI
  class Input < Base
    def view_template
      input(**attrs)
    end

    private

    def default_attrs
      { class: "input", type: "text" }
    end
  end
end

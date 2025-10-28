# frozen_string_literal: true

module PhlexyUI
  class Radio < Base
    def view_template
      input(**attrs)
    end

    private

    def default_attrs
      { class: "radio", type: "radio" }
    end
  end
end

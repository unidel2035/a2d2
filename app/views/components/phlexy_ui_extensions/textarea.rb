# frozen_string_literal: true

module PhlexyUI
  class Textarea < Base
    def view_template
      textarea(**attrs)
    end

    private

    def default_attrs
      { class: "textarea" }
    end
  end
end

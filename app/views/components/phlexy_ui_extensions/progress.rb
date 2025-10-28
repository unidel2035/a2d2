# frozen_string_literal: true

module PhlexyUI
  class Progress < Base
    def view_template
      progress(**attrs)
    end

    private

    def default_attrs
      { class: "progress" }
    end
  end
end

# frozen_string_literal: true

module PhlexyUI
  class Select < Base
    def view_template(&)
      select(**attrs, &)
    end

    private

    def default_attrs
      { class: "select" }
    end
  end
end

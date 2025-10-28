# frozen_string_literal: true

module PhlexyUI
  class Join < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      { class: "join" }
    end
  end
end

# frozen_string_literal: true

module Layouts
  class ApplicationLayout < ApplicationComponent
    include Phlex::Rails::Layout

    def initialize(title: "A2D2 - Платформа автоматизации автоматизации")
      @title = title
    end

    def template(&block)
      doctype

      html(data_theme: "light") do
        head do
          title { @title }
          meta(name: "viewport", content: "width=device-width,initial-scale=1")
          csrf_meta_tags
          csp_meta_tag

          stylesheet_link_tag "application", data: { turbo_track: "reload" }
          script(src: "https://cdn.tailwindcss.com")
          link(
            href: "https://cdn.jsdelivr.net/npm/daisyui@4.12.14/dist/full.min.css",
            rel: "stylesheet",
            type: "text/css"
          )
          javascript_importmap_tags
        end

        body do
          yield
        end
      end
    end
  end
end

# frozen_string_literal: true

module Layouts
  class ApplicationLayout < ApplicationComponent
    include Phlex::Rails::Layout

    def initialize(title: "A2D2 - Платформа автоматизации автоматизации")
      @title = title
    end

    def view_template(&block)
      doctype

      html(data_theme: "light") do
        head do
          title { @title }
          meta(name: "viewport", content: "width=device-width,initial-scale=1")
          csrf_meta_tags
          csp_meta_tag

          # Tailwind CSS via CDN
          script(src: "https://cdn.tailwindcss.com")

          # DaisyUI via CDN
          link(
            href: "https://cdn.jsdelivr.net/npm/daisyui@4.12.14/dist/full.min.css",
            rel: "stylesheet",
            type: "text/css"
          )

          # Configure Tailwind with DaisyUI
          unsafe_raw <<~HTML
            <script>
              tailwind.config = {
                theme: {
                  extend: {
                    colors: {
                      primary: '#3b82f6',
                      secondary: '#6366f1',
                      accent: '#8b5cf6',
                    }
                  }
                }
              }
            </script>
          HTML

          stylesheet_link_tag "application", data: { turbo_track: "reload" }
          javascript_importmap_tags
        end

        body do
          yield
        end
      end
    end
  end
end

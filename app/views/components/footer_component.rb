# frozen_string_literal: true

module Components
  class FooterComponent < ApplicationComponent
    def view_template
     div class: "footer-center p-10 bg-base-200 text-base-content" do
        div do
          p(class: "font-bold text-xl") do
            span(class: "bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent") { "A2D2" }
          end
          p(class: "text-base-content/70") { "Платформа автоматизации автоматизации" }
          p(class: "text-base-content/60") { "Разработано с 🇷🇺 в России" }
        end

        div do
          div(class: "grid grid-flow-col gap-4") do
            Link(href: "#", class: "link link-hover") { "О проекте" }
            Link(href: "#", class: "link link-hover") { "Контакты" }
            Link(href: "#", class: "link link-hover") { "Документация" }
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Errors
  class NotFoundView < ApplicationComponent
    def view_template
      div(class: "min-h-screen flex items-center justify-center bg-gradient-to-b from-base-100 to-base-200 px-4") do
        div(class: "max-w-2xl mx-auto text-center") do
          # Анимированная иконка 404
          div(class: "mb-8") do
            div(class: "relative inline-block") do
              # Большой текст 404
              h1(class: "text-9xl font-black text-primary/20 select-none") do
                "404"
              end

              # Иконка робота поверх текста
              div(class: "absolute inset-0 flex items-center justify-center") do
                svg(
                  xmlns: "http://www.w3.org/2000/svg",
                  class: "h-32 w-32 text-primary animate-bounce",
                  fill: "none",
                  viewBox: "0 0 24 24",
                  stroke: "currentColor"
                ) do
                  path(
                    stroke_linecap: "round",
                    stroke_linejoin: "round",
                    stroke_width: "2",
                    d: "M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  )
                end
              end
            end
          end

          # Заголовок
          h2(class: "text-4xl font-bold text-base-content mb-4") do
            "Страница не найдена"
          end

          # Описание
          p(class: "text-lg text-base-content/70 mb-8 max-w-md mx-auto") do
            "К сожалению, запрашиваемая страница не существует. Возможно, она была перемещена или удалена."
          end

          # Кнопки действий
          div(class: "flex flex-col sm:flex-row gap-4 justify-center") do
            # Кнопка "На главную"
            a(
              href: root_path,
              class: "btn btn-primary btn-lg gap-2"
            ) do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                class: "h-6 w-6",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor"
              ) do
                path(
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  stroke_width: "2",
                  d: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
                )
              end
              plain "На главную"
            end

            # Кнопка "Назад"
            button(
              onclick: "history.back()",
              class: "btn btn-outline btn-lg gap-2"
            ) do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                class: "h-6 w-6",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor"
              ) do
                path(
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  stroke_width: "2",
                  d: "M10 19l-7-7m0 0l7-7m-7 7h18"
                )
              end
              plain "Назад"
            end
          end

          # Дополнительные ссылки
          div(class: "mt-12 pt-8 border-t border-base-300") do
            p(class: "text-sm text-base-content/60 mb-4") do
              "Полезные ссылки:"
            end
            div(class: "flex flex-wrap gap-4 justify-center text-sm") do
              a(href: helpers.dashboard_path, class: "link link-primary") do
                "Dashboard"
              end
              a(href: helpers.components_path, class: "link link-primary") do
                "Компоненты"
              end
              a(href: helpers.landing_path, class: "link link-primary") do
                "О платформе"
              end
              a(href: "https://github.com/unidel2035/a2d2/issues", target: "_blank", rel: "noopener", class: "link link-primary") do
                "Поддержка"
              end
            end
          end
        end
      end
    end
  end
end

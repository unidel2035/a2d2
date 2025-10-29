# frozen_string_literal: true

module ThemeGenerator
  class IndexView < ApplicationComponent
    def view_template
      html_tag(data: { theme: "light" }) do
        head do
          title { "Theme Generator - daisyUI" }
          meta(name: "viewport", content: "width=device-width,initial-scale=1")
          csrf_meta_tags
          csp_meta_tag
          stylesheet_link_tag "application", "data-turbo-track": "reload"
          render_styles
        end

        body(class: "bg-base-100") do
          # Left Sidebar
          aside(class: "sidebar bg-base-100") do
            div(class: "p-4") do
              # Logo
              div(class: "mb-6") do
                a(href: helpers.root_path, class: "text-2xl font-bold") do
                  span(class: "text-primary") { "daisy" }
                  span(class: "text-secondary") { "UI" }
                end
                div(class: "text-xs text-base-content/60 mt-1") { "5.3.10" }
              end

              # Navigation Links
              div(class: "menu text-sm") do
                li(class: "menu-title") { "Documentation" }
                li { a(href: "https://daisyui.com/docs/changelog/", target: "_blank") { "Changelog" } }
                li { a(href: "https://github.com/saadeghi/daisyui/releases", target: "_blank") { "Release notes" } }
                li { a(href: "https://daisyui.com/docs/version/", target: "_blank") { "Version archives" } }

                li(class: "menu-title mt-4") { "Resources" }
                li { a(href: "https://github.com/saadeghi/daisyui/discussions/3641", target: "_blank") { "Roadmap" } }

                li(class: "menu-title mt-4") { "Design" }
                li do
                  a(href: helpers.components_path, class: "btn btn-sm btn-ghost justify-start") { "Components" }
                end
                li { a(href: "https://daisyui.com/templates/", target: "_blank") { "Templates" } }
                li { a(href: "https://daisyui.com/figma/", target: "_blank") { "Figma library" } }

                li(class: "menu-title mt-4 text-primary font-bold") { "Theme Generator" }
              end
            end
          </aside>

          # Main Content
          main(class: "main-content") do
            div(class: "container mx-auto p-6 max-w-7xl") do
              # Header
              div(class: "mb-8") do
                h1(class: "text-4xl font-bold mb-2") { "Theme Generator" }
                p(class: "text-base-content/70") { "Customize daisyUI themes or create new ones" }
              end

              # Theme Selector
              render_theme_selector

              # Color Customization
              render_color_customization

              # Design Controls
              render_design_controls

              # Component Preview
              render_component_preview

              # CSS Output
              render_css_output
            end
          end

          render_scripts
        end
      end
    end

    private

    def html_tag(attributes = {})
      tag = Phlex::HTML.new
      tag.html(attributes) do
        yield
      end
    end

    def render_styles
      style do
        unsafe_raw(<<~CSS)
          /* Custom styles for the theme generator */
          .sidebar {
            width: 280px;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            overflow-y: auto;
            border-right: 1px solid hsl(var(--bc) / 0.1);
          }

          .main-content {
            margin-left: 280px;
            min-height: 100vh;
          }

          .color-input-group {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.5rem;
          }

          .color-preview {
            width: 40px;
            height: 40px;
            border-radius: 0.5rem;
            border: 2px solid hsl(var(--bc) / 0.2);
            cursor: pointer;
          }

          input[type="color"] {
            width: 40px;
            height: 40px;
            border: none;
            cursor: pointer;
          }

          .css-output {
            background: hsl(var(--b3));
            border: 1px solid hsl(var(--bc) / 0.2);
            border-radius: 0.5rem;
            padding: 1rem;
            font-family: 'Courier New', monospace;
            font-size: 0.875rem;
            line-height: 1.5;
            max-height: 400px;
            overflow-y: auto;
          }

          .component-preview {
            padding: 2rem;
            background: hsl(var(--b2));
            border-radius: 0.5rem;
            margin-bottom: 1rem;
          }

          .range-input {
            display: flex;
            align-items: center;
            gap: 1rem;
          }
        CSS
      end
    end

    def render_theme_selector
      div(class: "mb-8") do
        div(class: "card bg-base-200 shadow-xl") do
          div(class: "card-body") do
            h2(class: "card-title") { "Select a base theme (40+ built-in themes)" }
            div(class: "form-control") do
              label(class: "label") do
                span(class: "label-text") { "Choose a theme to start with:" }
              end
              select(id: "themeSelect", class: "select select-bordered w-full max-w-xs") do
                THEMES.each do |theme|
                  option(value: theme) { theme }
                end
              end
            end
          end
        end
      end
    end

    def render_color_customization
      div(class: "mb-8") do
        div(class: "card bg-base-200 shadow-xl") do
          div(class: "card-body") do
            h2(class: "card-title mb-4") { "Colors" }

            div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6") do
              render_color_input("Primary", "colorPrimary", "#570df8")
              render_color_input("Secondary", "colorSecondary", "#f000b8")
              render_color_input("Accent", "colorAccent", "#37cdbe")
              render_color_input("Neutral", "colorNeutral", "#3d4451")
              render_color_input("Base 100", "colorBase100", "#ffffff")
              render_color_input("Base 200", "colorBase200", "#f2f2f2")
              render_color_input("Base 300", "colorBase300", "#e5e6e6")
              render_color_input("Base Content", "colorBaseContent", "#1f2937")
              render_color_input("Info", "colorInfo", "#3abff8")
              render_color_input("Success", "colorSuccess", "#36d399")
              render_color_input("Warning", "colorWarning", "#fbbd23")
              render_color_input("Error", "colorError", "#f87272")
            end
          end
        end
      end
    end

    def render_color_input(label, id, default_value, with_content = false)
      div do
        label(class: "label") do
          span(class: "label-text font-semibold") { label }
        end
        div(class: "color-input-group") do
          input(
            type: "color",
            id: id,
            value: default_value,
            class: "color-preview"
          )
          input(
            type: "text",
            id: "#{id}Text",
            value: default_value,
            class: "input input-bordered input-sm flex-1"
          )
        end

        if with_content
          div(class: "color-input-group mt-2") do
            span(class: "text-xs text-base-content/60") { "Content:" }
            input(
              type: "color",
              id: "#{id}Content",
              value: "#ffffff",
              class: "color-preview w-8 h-8"
            )
            input(
              type: "text",
              id: "#{id}ContentText",
              value: "#ffffff",
              class: "input input-bordered input-sm flex-1"
            )
          end
        end
      end
    end

    def render_design_controls
      div(class: "mb-8") do
        div(class: "card bg-base-200 shadow-xl") do
          div(class: "card-body") do
            h2(class: "card-title mb-4") { "Design Controls" }

            div(class: "space-y-6") do
              render_range_control("Border Radius (rounded-box)", "borderRadius", "radiusValue", "1rem", 0, 2, 0.1, 1)
              render_range_control("Border Radius for Buttons (rounded-btn)", "borderRadiusBtn", "radiusBtnValue", "0.5rem", 0, 2, 0.1, 0.5)
              render_range_control("Border Radius for Badges (rounded-badge)", "borderRadiusBadge", "radiusBadgeValue", "1.9rem", 0, 2, 0.1, 1.9)
              render_range_control("Border Width", "borderWidth", "borderWidthValue", "1px", 0.5, 2, 0.5, 1)

              div(class: "form-control") do
                label(class: "label cursor-pointer justify-start gap-4") do
                  input(
                    type: "checkbox",
                    id: "animationEnabled",
                    checked: true,
                    class: "toggle toggle-primary"
                  )
                  span(class: "label-text font-semibold") { "Enable Animations" }
                end
              end
            end
          end
        end
      end
    end

    def render_range_control(label, input_id, value_id, display_unit, min, max, step, initial_value)
      div do
        label(class: "label") do
          span(class: "label-text font-semibold") { label }
          span(class: "label-text-alt", id: value_id) { "#{initial_value}#{display_unit.include?('px') ? 'px' : 'rem'}" }
        end
        div(class: "range-input") do
          input(
            type: "range",
            id: input_id,
            min: min,
            max: max,
            step: step,
            value: initial_value,
            class: "range range-primary flex-1"
          )
        end
      end
    end

    def render_component_preview
      div(class: "mb-8") do
        div(class: "card bg-base-200 shadow-xl") do
          div(class: "card-body") do
            h2(class: "card-title mb-4") { "Preview Components" }

            # Buttons
            div(class: "component-preview") do
              h3(class: "font-bold mb-4") { "Buttons" }
              div(class: "flex flex-wrap gap-2") do
                button(class: "btn") { "Default" }
                button(class: "btn btn-primary") { "Primary" }
                button(class: "btn btn-secondary") { "Secondary" }
                button(class: "btn btn-accent") { "Accent" }
                button(class: "btn btn-neutral") { "Neutral" }
                button(class: "btn btn-info") { "Info" }
                button(class: "btn btn-success") { "Success" }
                button(class: "btn btn-warning") { "Warning" }
                button(class: "btn btn-error") { "Error" }
              end
            end

            # Cards
            div(class: "component-preview") do
              h3(class: "font-bold mb-4") { "Cards" }
              div(class: "grid grid-cols-1 md:grid-cols-3 gap-4") do
                div(class: "card bg-base-100 shadow-xl") do
                  figure(class: "bg-primary/20 h-32")
                  div(class: "card-body") do
                    h4(class: "card-title") { "Card Title" }
                    p { "Sample card with image" }
                    div(class: "card-actions justify-end") do
                      button(class: "btn btn-primary btn-sm") { "Action" }
                    end
                  end
                end

                div(class: "card bg-base-100 shadow-xl") do
                  div(class: "card-body") do
                    h4(class: "card-title") { "Simple Card" }
                    p { "Card without image" }
                    div(class: "card-actions justify-end") do
                      button(class: "btn btn-secondary btn-sm") { "Action" }
                    end
                  end
                end

                div(class: "card bg-primary text-primary-content shadow-xl") do
                  div(class: "card-body") do
                    h4(class: "card-title") { "Colored Card" }
                    p { "Card with colored background" }
                    div(class: "card-actions justify-end") do
                      button(class: "btn btn-sm") { "Action" }
                    end
                  end
                end
              end
            end

            # Form Elements
            div(class: "component-preview") do
              h3(class: "font-bold mb-4") { "Form Elements" }
              div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
                div do
                  label(class: "label") do
                    span(class: "label-text") { "Text Input" }
                  end
                  input(
                    type: "text",
                    placeholder: "Type here",
                    class: "input input-bordered w-full"
                  )
                end

                div do
                  label(class: "label") do
                    span(class: "label-text") { "Select" }
                  end
                  select(class: "select select-bordered w-full") do
                    option { "Option 1" }
                    option { "Option 2" }
                  end
                end

                div do
                  label(class: "label cursor-pointer justify-start gap-2") do
                    input(
                      type: "checkbox",
                      checked: true,
                      class: "checkbox checkbox-primary"
                    )
                    span(class: "label-text") { "Checkbox" }
                  end
                end

                div do
                  label(class: "label cursor-pointer justify-start gap-2") do
                    input(
                      type: "checkbox",
                      checked: true,
                      class: "toggle toggle-primary"
                    )
                    span(class: "label-text") { "Toggle" }
                  end
                end
              end
            end
          end
        end
      end
    end

    def render_css_output
      div(class: "mb-8") do
        div(class: "card bg-base-200 shadow-xl") do
          div(class: "card-body") do
            h2(class: "card-title mb-4") { "Generated CSS" }
            p(class: "text-sm text-base-content/70 mb-4") do
              text "Add this theme to your CSS file after "
              code(class: "bg-base-300 px-2 py-1 rounded") { "@plugin 'daisyui';" }
            end

            div(class: "css-output", id: "cssOutput") do
              pre do
                unsafe_raw(<<~CSS)
                  [data-theme="mytheme"] {
                    color-scheme: light;
                    --rounded-box: 1rem;
                    --rounded-btn: 0.5rem;
                    --rounded-badge: 1.9rem;
                    --animation-btn: 0.25s;
                    --animation-input: 0.2s;
                    --btn-focus-scale: 0.95;
                    --border-btn: 1px;
                    --tab-border: 1px;
                    --tab-radius: 0.5rem;

                    --p: 262 80% 50%;
                    --pc: 0 0% 100%;
                    --s: 318 81% 47%;
                    --sc: 0 0% 100%;
                    --a: 175 62% 56%;
                    --ac: 0 0% 100%;
                    --n: 221 20% 29%;
                    --nc: 0 0% 100%;
                    --b1: 0 0% 100%;
                    --b2: 0 0% 95%;
                    --b3: 0 0% 90%;
                    --bc: 221 39% 11%;
                    --in: 198 93% 60%;
                    --inc: 0 0% 100%;
                    --su: 158 64% 52%;
                    --suc: 0 0% 100%;
                    --wa: 43 96% 56%;
                    --wac: 0 0% 100%;
                    --er: 0 91% 71%;
                    --erc: 0 0% 100%;
                  }
                CSS
              end
            end

            div(class: "card-actions justify-end mt-4") do
              button(class: "btn btn-primary", id: "copyCssBtn") do
                svg_icon_copy
                text " Copy CSS"
              end
            end
          end
        end
      end
    end

    def render_scripts
      script do
        unsafe_raw(<<~JS)
          let currentTheme = {
            colors: {
              primary: '#570df8',
              primaryContent: '#ffffff',
              secondary: '#f000b8',
              secondaryContent: '#ffffff',
              accent: '#37cdbe',
              accentContent: '#ffffff',
              neutral: '#3d4451',
              neutralContent: '#ffffff',
              base100: '#ffffff',
              base200: '#f2f2f2',
              base300: '#e5e6e6',
              baseContent: '#1f2937',
              info: '#3abff8',
              infoContent: '#ffffff',
              success: '#36d399',
              successContent: '#ffffff',
              warning: '#fbbd23',
              warningContent: '#ffffff',
              error: '#f87272',
              errorContent: '#ffffff'
            },
            borderRadius: 1,
            borderRadiusBtn: 0.5,
            borderRadiusBadge: 1.9,
            borderWidth: 1,
            animationEnabled: true
          };

          function syncColorInputs(colorId, textId) {
            const colorInput = document.getElementById(colorId);
            const textInput = document.getElementById(textId);

            colorInput.addEventListener('input', (e) => {
              textInput.value = e.target.value;
              updateTheme();
            });

            textInput.addEventListener('input', (e) => {
              const value = e.target.value;
              if (/^#[0-9A-F]{6}$/i.test(value)) {
                colorInput.value = value;
                updateTheme();
              }
            });
          }

          function hexToHSL(hex) {
            const result = /^#?([a-f\\d]{2})([a-f\\d]{2})([a-f\\d]{2})$/i.exec(hex);
            if (!result) return '0 0% 0%';

            let r = parseInt(result[1], 16) / 255;
            let g = parseInt(result[2], 16) / 255;
            let b = parseInt(result[3], 16) / 255;

            const max = Math.max(r, g, b);
            const min = Math.min(r, g, b);
            let h, s, l = (max + min) / 2;

            if (max === min) {
              h = s = 0;
            } else {
              const d = max - min;
              s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

              switch (max) {
                case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break;
                case g: h = ((b - r) / d + 2) / 6; break;
                case b: h = ((r - g) / d + 4) / 6; break;
              }
            }

            h = Math.round(h * 360);
            s = Math.round(s * 100);
            l = Math.round(l * 100);

            return `${h} ${s}% ${l}%`;
          }

          syncColorInputs('colorPrimary', 'colorPrimaryText');
          syncColorInputs('colorSecondary', 'colorSecondaryText');
          syncColorInputs('colorAccent', 'colorAccentText');
          syncColorInputs('colorNeutral', 'colorNeutralText');
          syncColorInputs('colorBase100', 'colorBase100Text');
          syncColorInputs('colorBase200', 'colorBase200Text');
          syncColorInputs('colorBase300', 'colorBase300Text');
          syncColorInputs('colorBaseContent', 'colorBaseContentText');
          syncColorInputs('colorInfo', 'colorInfoText');
          syncColorInputs('colorSuccess', 'colorSuccessText');
          syncColorInputs('colorWarning', 'colorWarningText');
          syncColorInputs('colorError', 'colorErrorText');

          document.getElementById('borderRadius').addEventListener('input', (e) => {
            document.getElementById('radiusValue').textContent = e.target.value + 'rem';
            currentTheme.borderRadius = parseFloat(e.target.value);
            updateTheme();
          });

          document.getElementById('themeSelect').addEventListener('change', (e) => {
            document.documentElement.setAttribute('data-theme', e.target.value);
          });

          document.getElementById('copyCssBtn').addEventListener('click', () => {
            const cssText = document.getElementById('cssOutput').textContent;
            navigator.clipboard.writeText(cssText).then(() => {
              const btn = document.getElementById('copyCssBtn');
              const originalText = btn.innerHTML;
              btn.innerHTML = '✓ Copied!';
              setTimeout(() => {
                btn.innerHTML = originalText;
              }, 2000);
            });
          });

          function updateTheme() {
            // Implementation of updateTheme
          }

          updateTheme();
        JS
      end
    end

    def svg_icon_copy
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |svg|
        svg.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: "M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
        )
      end
    end

    THEMES = %w[
      light dark cupcake bumblebee emerald corporate synthwave retro cyberpunk valentine
      halloween garden forest aqua lofi pastel fantasy wireframe black luxury dracula cmyk
      autumn business acid lemonade night coffee winter dim nord sunset
    ].freeze
  end
end

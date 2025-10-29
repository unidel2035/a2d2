# config/initializers/phlexy_ui_extensions.rb
Rails.application.config.to_prepare do
  # Загружаем все компоненты PhlexyUI
  components_dir = Rails.root.join('app/views/components/phlexy_ui_extensions')
  
  if Dir.exist?(components_dir)
    Dir.glob(components_dir.join('*.rb')).each do |file|
      load file
    end
  end
  
  # Регистрируем path helpers если нужно
  PhlexyUI::Base.class_eval do
    include Rails.application.routes.url_helpers
  end
end

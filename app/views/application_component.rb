class ApplicationComponent < Phlex::HTML
  # Используем Button и Card из гема phlexy_ui
  def Button(*args, &block)
    PhlexyUI::Button.new(*args, &block)
  end

  def Card(*args, &block)
    PhlexyUI::Card.new(*args, &block)
  end

  # Используем наши кастомные компоненты
  def Hero(*args, &block)
    PhlexyUI::Hero.new(*args, &block)
  end

  def Stat(*args, &block)
    PhlexyUI::Stat.new(*args, &block)
  end

  def Divider(*args, &block)
    PhlexyUI::Divider.new(*args, &block)
  end

  def Navbar(*args, &block)
    PhlexyUI::Navbar.new(*args, &block)
  end

  def Link(*args, &block)
    PhlexyUI::Link.new(*args, &block)
  end
end

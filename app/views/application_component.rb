class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers
  include Phlex::Rails::Helpers::Routes

  # Include specific helpers for meta tags and assets
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptImportmapTags

  # Include date helpers for time_ago_in_words and similar methods
  include ActionView::Helpers::DateHelper

  # Include URL helpers
  include ActionView::Helpers::UrlHelper

  # Actions
  def Button(*args, &block)
    PhlexyUI::Button.new(*args, &block)
  end

  def Dropdown(*args, &block)
    PhlexyUI::Dropdown.new(*args, &block)
  end

  def Modal(*args, &block)
    PhlexyUI::Modal.new(*args, &block)
  end

  def Swap(*args, &block)
    PhlexyUI::Swap.new(*args, &block)
  end

  def ThemeController(*args, &block)
    PhlexyUI::ThemeController.new(*args, &block)
  end

  # Data Display
  def Badge(*args, &block)
    PhlexyUI::Badge.new(*args, &block)
  end

  def Card(*args, &block)
    PhlexyUI::Card.new(*args, &block)
  end

  def Accordion(*args, &block)
    PhlexyUI::Accordion.new(*args, &block)
  end

  def Avatar(*args, &block)
    PhlexyUI::Avatar.new(*args, &block)
  end

  def Carousel(*args, &block)
    PhlexyUI::Carousel.new(*args, &block)
  end

  def ChatBubble(*args, &block)
    PhlexyUI::ChatBubble.new(*args, &block)
  end

  def Collapse(*args, &block)
    PhlexyUI::Collapse.new(*args, &block)
  end

  def Countdown(*args, &block)
    PhlexyUI::Countdown.new(*args, &block)
  end

  def Diff(*args, &block)
    PhlexyUI::Diff.new(*args, &block)
  end

  def Kbd(*args, &block)
    PhlexyUI::Kbd.new(*args, &block)
  end

  def Stat(*args, &block)
    PhlexyUI::Stat.new(*args, &block)
  end

  def Table(*args, &block)
    PhlexyUI::Table.new(*args, &block)
  end

  def Timeline(*args, &block)
    PhlexyUI::Timeline.new(*args, &block)
  end

  # Data Input
  def Checkbox(*args, &block)
    PhlexyUI::Checkbox.new(*args, &block)
  end

  def FileInput(*args, &block)
    PhlexyUI::FileInput.new(*args, &block)
  end

  def Radio(*args, &block)
    PhlexyUI::Radio.new(*args, &block)
  end

  def Range(*args, &block)
    PhlexyUI::Range.new(*args, &block)
  end

  def Rating(*args, &block)
    PhlexyUI::Rating.new(*args, &block)
  end

  def Select(*args, &block)
    PhlexyUI::Select.new(*args, &block)
  end

  def Input(*args, &block)
    PhlexyUI::Input.new(*args, &block)
  end

  def Textarea(*args, &block)
    PhlexyUI::Textarea.new(*args, &block)
  end

  def Toggle(*args, &block)
    PhlexyUI::Toggle.new(*args, &block)
  end

  def FormControl(*args, &block)
    PhlexyUI::FormControl.new(*args, &block)
  end

  # Layout
  def Artboard(*args, &block)
    PhlexyUI::Artboard.new(*args, &block)
  end

  def Divider(*args, &block)
    PhlexyUI::Divider.new(*args, &block)
  end

  def Drawer(*args, &block)
    PhlexyUI::Drawer.new(*args, &block)
  end

  def Footer(*args, &block)
    PhlexyUI::Footer.new(*args, &block)
  end

  def Hero(*args, &block)
    PhlexyUI::Hero.new(*args, &block)
  end

  def Indicator(*args, &block)
    PhlexyUI::Indicator.new(*args, &block)
  end

  def Join(*args, &block)
    PhlexyUI::Join.new(*args, &block)
  end

  def Mask(*args, &block)
    PhlexyUI::Mask.new(*args, &block)
  end

  def Stack(*args, &block)
    PhlexyUI::Stack.new(*args, &block)
  end

  # Mockup
  def Browser(*args, &block)
    PhlexyUI::Browser.new(*args, &block)
  end

  def Code(*args, &block)
    PhlexyUI::Code.new(*args, &block)
  end

  def Phone(*args, &block)
    PhlexyUI::Phone.new(*args, &block)
  end

  def Window(*args, &block)
    PhlexyUI::Window.new(*args, &block)
  end

  # Feedback
  def Loading(*args, &block)
    PhlexyUI::Loading.new(*args, &block)
  end

  def Alert(*args, &block)
    PhlexyUI::Alert.new(*args, &block)
  end

  def Progress(*args, &block)
    PhlexyUI::Progress.new(*args, &block)
  end

  def RadialProgress(*args, &block)
    PhlexyUI::RadialProgress.new(*args, &block)
  end

  def Skeleton(*args, &block)
    PhlexyUI::Skeleton.new(*args, &block)
  end

  def Toast(*args, &block)
    PhlexyUI::Toast.new(*args, &block)
  end

  def Tooltip(*args, &block)
    PhlexyUI::Tooltip.new(*args, &block)
  end

  # Navigation
  def Menu(*args, &block)
    PhlexyUI::Menu.new(*args, &block)
  end

  def Link(*args, &block)
    PhlexyUI::Link.new(*args, &block)
  end

  def Breadcrumbs(*args, &block)
    PhlexyUI::Breadcrumbs.new(*args, &block)
  end

  def BottomNavigation(*args, &block)
    PhlexyUI::BottomNavigation.new(*args, &block)
  end

  def Navbar(*args, &block)
    PhlexyUI::Navbar.new(*args, &block)
  end

  def Pagination(*args, &block)
    PhlexyUI::Pagination.new(*args, &block)
  end

  def Steps(*args, &block)
    PhlexyUI::Steps.new(*args, &block)
  end

  def Tab(*args, &block)
    PhlexyUI::Tab.new(*args, &block)
  end
end

class ThemeGeneratorController < ApplicationController
  def index
    render ThemeGenerator::IndexView.new
  end
end

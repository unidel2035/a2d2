class DashboardController < ApplicationController
  def index
    render DashboardViews::IndexView.new, layout: Layouts::DashboardLayout
  end
end

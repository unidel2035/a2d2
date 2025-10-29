class DashboardController < ApplicationController
  def index
    render Layouts::DashboardLayout.new { DashboardViews::IndexView.new }
  end
end

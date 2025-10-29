class DashboardController < ApplicationController
  def index
    render Dashboard::IndexView.new, layout: Layouts::DashboardLayout
  end
end

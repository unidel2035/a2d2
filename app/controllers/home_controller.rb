class HomeController < ApplicationController
  skip_before_action :require_login

  def index
    render Home::IndexView.new(
      logged_in: logged_in?,
      current_user: current_user
    )
  end
end

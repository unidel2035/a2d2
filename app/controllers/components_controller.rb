class ComponentsController < ApplicationController
  # This controller showcases all design components
  def index
    render Components::IndexView.new(
      logged_in: logged_in?,
      current_user: current_user
    )
  end
end

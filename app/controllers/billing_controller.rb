class BillingController < ApplicationController
  def index
    render Billing::IndexView.new(
      logged_in: logged_in?,
      current_user: current_user
    )
  end
end

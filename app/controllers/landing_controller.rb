# frozen_string_literal: true

class LandingController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    render Landing::IndexView.new
  end
end

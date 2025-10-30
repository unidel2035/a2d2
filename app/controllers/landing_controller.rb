# frozen_string_literal: true

class LandingController < ApplicationController
  def index
    render Landing::IndexView.new
  end
end

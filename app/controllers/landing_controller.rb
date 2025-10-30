# frozen_string_literal: true

class LandingController < ApplicationController
  def index
    render Layouts::ApplicationLayout.new { Landing::IndexView.new }
  end
end

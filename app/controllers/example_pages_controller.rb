class ExamplePagesController < ApplicationController
  # before_action :authenticate_user!, only: :dashboard

  def welcome
  end

  def dashboard
    @forecast = MultiDayForecast.new(current_user).retrieve
  end
end

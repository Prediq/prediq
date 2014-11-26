class PrediqApiController < ApplicationController

  before_action :authenticate_user! #, only: :dashboard

  def welcome
  end

  def dashboard
    @dashboard_tab = true
    @forecast = MultiDayForecast.new(current_user).retrieve
  end
end

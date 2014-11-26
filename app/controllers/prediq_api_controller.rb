class PrediqApiController < ApplicationController

  # NOTE: This is the controller that makes all of the 'backend' calls to the "prediq API" server, hence it is named mnemonically
  layout 'application'

  before_action :authenticate_user! #, only: :dashboard

  def welcome
  end

  def dashboard
    puts "***** current_user.id: #{current_user.id}"
    @dashboard_tab = true
    @forecast = MultiDayForecast.new(current_user).retrieve
  end
end

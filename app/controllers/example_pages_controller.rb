class ExamplePagesController < ApplicationController
  before_action :authenticate_user!, only: :dashboard

  def welcome
  end

  def dashboard
  end
end

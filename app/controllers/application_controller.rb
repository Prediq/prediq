class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?
  
  def after_sign_in_path_for(resource)
    '/dashboard'
  end

  protected

  def configure_permitted_parameters
    permitted_params = [:firstname, :lastname, :telephone, :fax, :email, :password, :password_confirmation]
    permitted_params.each{|param| devise_parameter_sanitizer.for(:sign_up) << param }
  end
end

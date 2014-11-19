class RegistrationsController < Devise::RegistrationsController

  private

  def after_update_path_for(resource)
    dashboard_index_path if current_admin
  end

  def sign_up_params
    #devise_parameter_sanitizer.sanitize(:sign_up)
    #params[:user]
    new_admin_params
  end

  def account_update_params
    #devise_parameter_sanitizer.sanitize(:account_update)
    update_admin_params
  end

  def new_admin_params
    params.require(:admin).permit( :email, :last_name, :first_name, :password, :password_confirmation, :current_password )
  end

  def update_admin_params
    params.require(:admin).permit( :email, :last_name, :first_name, :password, :password_confirmation, :current_password )
  end

end
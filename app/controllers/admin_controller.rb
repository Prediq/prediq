# NOTE: This controller has, in addition to being the controller for the 'admin' layout (has empty 'index' method),
# also allows the Superadmin users to create new users through the CMS rather
# than the default "devise" method via the registrations_controller which allows for self-registration / maintenance
# only.  In this app we wanted to allow only the Superadmin user the ability to create new users.
# The 'admins_controller', on the other hand, allows only the 'index' method and its allied sort/search functionality

class AdminController < ApplicationController

  before_filter :authenticate_admin!

  layout 'admin'

  def index
  end

  def show
    @user = Admin.find( params[:id] )
  end

  def new
    @user = Admin.new
    respond_to do |format|
      format.html {
      } # new.html.erb
      format.json  { render :json => @user }
    end
  end

  def edit
    @user = Admin.find(params[:id])
  end

  def create
    #puts "******************** CREATE: #{params}"
    @user = Admin.new( new_user_params )

    respond_to do |format|
      if @user.errors.empty? && @user.save

        #puts "************ user_role: #{params[:user_role]}"
        # @user.add_role( params[:user_role] )
        format.html {
          flash[:notice] = "Successfully Created User."
          # to user index page
          redirect_to admins_path( view_context.admin_params ), notice: 'The User was successfully created.'
          # to user "show" page
          #redirect_to user_path( view_context.user_params.merge( :id => @user ) ), notice: 'The User was successfully created.'
        }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def update
    @user = Admin.find(params[:id])
    old_user_role = @user.roles.first.name
    if current_admin.has_any_role?(:superadmin)
      params[:admin].delete(:password) if params[:admin][:password].blank?
      params[:admin].delete(:password_confirmation) if params[:admin][:password].blank? and params[:admin][:password_confirmation].blank?
    end

    respond_to do |format|

      #puts ""
      #puts ""
      #puts "********* UPDATE params: #{params}"
      #puts ""
      #puts ""

      # If the user was changed from penduser to reguser
      # "user"=>{"role_ids"=>"3"}
      if @user.update_attributes( update_user_params )
        format.html {
          msg = ''
          new_user_role = @user.roles.first.name
          if old_user_role != new_user_role
            msg = "; the user role was updated from '#{old_user_role}' to '#{new_user_role}'"
          end
          # to admin "show" page
          redirect_to admins_path( view_context.admin_params ), notice: "The Admin User was successfully updated" + msg
          # redirect_to admin_index_path( view_context.admin_params ), notice: "The Admin User was successfully updated" + msg
          # to user "show" page
          #redirect_to user_path( view_context.user_params.merge( :id => @user ) ), notice: 'The User was successfully updated.'
        }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @user = Admin.find(params[:id])
    if @user.destroy
      respond_to do |format|
        format.html { redirect_to admins_path( :sort          => session[:sort],
                                               :direction     => session[:direction],
                                               :page          => session[:page],
                                               :num_per_page  => session[:num_per_page],
                                               :last_name     => session[:last_name],
                                               :first_name    => session[:first_name],
                                               :email         => session[:email],
                                               :func          => session[:func]), notice: "SUCCESS: The Admin User record was successfully deleted"
        }
        #format.html {
        #  flash[:notice] = "Successfully deleted User."; redirect_to user_index_path( :page => params[:page], :num_per_page => params[:num_per_page] )
        #}
      end
    end
  end

  private

  def update_user_params
    params.require( :admin ).permit( :last_name, :first_name, :email, :role_ids, :password, :password_confirmation )
  end

  def new_user_params
    params.require( :admin ).permit( :last_name, :first_name, :email, :role_ids, :password, :password_confirmation )
  end


end

# NOTE: This controller was added strictly to allow the Superadmin users to create new users through the CMS rather
# than the default "devise" method via the registrations_controller which allows for self-registration / maintenance
# only.  In this app we wanted to allow only the Superadmin user the ability to create new users.

class UserController < ApplicationController

  before_filter :authenticate_user!

  layout 'admin'

  # authorize_resource

  def index

    params[:sort] ||= "last_name"
    params[:direction] ||= "asc"

    #puts ""
    #puts ""
    #puts "********* INDEX params: #{params}"
    #puts ""
    #puts ""

    set_session_params_user( params )

    puts;puts "************ search_conditions: #{search_conditions}";puts

    if current_user.has_any_role?( :superadmin, :admin )
      @users = User.where( search_conditions ).order( params[:sort] + ' ' + params[:direction] ).page(params[:page]).per( params[:num_per_page] ||= User.default_per_page )
      # @users = User.order( last_name: :desc ).page(params[:page]).per( params[:num_per_page] ||= User.default_per_page )
    elsif current_user.has_any_role?( :reguser )
      @users = User.where( :id => current_user.id).page(params[:page]).per( params[:num_per_page] ||= User.default_per_page )
    else
      @users = []
    end
  end

  def show
    @user = User.find( params[:id] )
  end

  def new
    @user = User.new
    @user.add_role(:reguser)
    respond_to do |format|
      format.html {
      } # new.html.erb
      format.json  { render :json => @user }
    end
  end

  def create
    #puts "******************** CREATE: #{params}"
    @user = User.new( new_user_params )

    respond_to do |format|
      if @user.errors.empty? && @user.save

        #puts "************ user_role: #{params[:user_role]}"
        @user.add_role( params[:user_role] )
        format.html {
          flash[:notice] = "Successfully Created User."
          # to user index page
          redirect_to user_index_path( view_context.user_params ), notice: 'The User was successfully created.'
          # to user "show" page
          #redirect_to user_path( view_context.user_params.merge( :id => @user ) ), notice: 'The User was successfully created.'
        }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    old_user_role = @user.roles.first.name
    if current_user.has_any_role?(:superadmin)
      params[:user].delete(:password) if params[:user][:password].blank?
      params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
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
          redirect_to user_index_path( view_context.user_params ), notice: "The user was successfully updated" + msg
          # to user "show" page
          #redirect_to user_path( view_context.user_params.merge( :id => @user ) ), notice: 'The User was successfully updated.'
        }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      respond_to do |format|
        format.html { redirect_to user_index_path( :sort          => session[:sort],
                                                   :direction     => session[:direction],
                                                   :page          => session[:page],
                                                   :num_per_page  => session[:num_per_page],
                                                   :last_name     => session[:last_name],
                                                   :first_name    => session[:first_name],
                                                   :email         => session[:email] ), notice: "SUCCESS: The User record was successfully deleted"
        }
        #format.html {
        #  flash[:notice] = "Successfully deleted User."; redirect_to user_index_path( :page => params[:page], :num_per_page => params[:num_per_page] )
        #}
      end
    end
  end

  private

  def search_conditions
    cond_params = {
      :last_name    => ( params[:last_name].present? )  ? "%#{params[:last_name].downcase}%"   : params[:last_name],
      :first_name   => ( params[:first_name].present? ) ? "%#{params[:first_name].downcase}%"  : params[:first_name],
      :email        => ( params[:email].present? )      ? "%#{params[:email].downcase}%"       : params[:email]
    }

    cond_strings = []
    cond_strings << 'LOWER(users.last_name) LIKE :last_name'   unless params[:last_name].blank?
    cond_strings << 'LOWER(users.first_name) LIKE :first_name' unless params[:first_name].blank?
    cond_strings << 'LOWER(users.email) LIKE :email'           unless params[:email].blank?

    cond_strings.any? ? [ cond_strings.join(' AND '), cond_params ] : nil

  end

  def update_user_params
    params.require( :user ).permit( :last_name, :first_name, :email, :role_ids, :password, :password_confirmation )
  end

  def new_user_params
    params.require( :user ).permit( :last_name, :first_name, :email, :role_ids, :password, :password_confirmation )
  end

end


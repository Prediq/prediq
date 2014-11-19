# NOTE: This controller was added strictly to allow the Superadmin users to create new users through the CMS rather
# than the default "devise" method via the registrations_controller which allows for self-registration / maintenance
# only.  In this app we wanted to allow only the Superadmin user the ability to create new users.
# The 'admin_controller', on the other hand, is the one that we use for the CRUD stuff.
# NOTE: The situation where we are using one controller (this one) for the index method, and another 'admin_controller'
# for the CRUD functionality came about because of the unfortunate naming on the model for the Admin users as 'Admin'
# Conflicting with this we also have the 'admin' layout which needs an 'admin_controller' just to hold its 'index' method.
# Had we named the Admin model something more like 'AdminUser' then the duplicitous use of 'admin' would have been avoided ;)

class AdminsController < ApplicationController

  before_filter :authenticate_admin!

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

    set_session_params_admin( params )

    puts;puts "************ search_conditions: #{search_conditions}";puts

    if current_admin.has_any_role?( :superadmin, :admin )
      if params[:func] == 'admins'
        # inspired by: http://thepugautomatic.com/2014/08/union-with-active-record/
        sql     = Admin.connection.unprepared_statement{"((#{Admin.with_role(:superadmin).to_sql}) UNION (#{Admin.with_role(:admin).to_sql})) AS admins"}
        @users  = Admin.from(sql).references(:admins, :admins_roles, :roles).order( params[:sort] + ' ' + params[:direction] ).page(params[:page]).per( params[:num_per_page] ||= Admin.default_per_page )
      elsif params[:func] == 'internals'
        @users  = Admin.where.not(id: Admin.with_role(:superadmin).pluck(:id) + Admin.with_role(:admin).pluck(:id)).order( params[:sort] + ' ' + params[:direction] ).page(params[:page]).per( params[:num_per_page] ||= Admin.default_per_page )
      end
    else
      @users = []
    end
  end

=begin
  def show
    @user = Admin.find( params[:id] )
  end
=end

=begin
  def new
    @user = Admin.new
    respond_to do |format|
      format.html {
      } # new.html.erb
      format.json  { render :json => @user }
    end
  end
=end

=begin
  def create
    #puts "******************** CREATE: #{params}"
    @user = Admin.new( new_user_params )

    respond_to do |format|
      if @user.errors.empty? && @user.save

        #puts "************ user_role: #{params[:user_role]}"
        @user.add_role( params[:user_role] )
        format.html {
          flash[:notice] = "Successfully Created User."
          # to user index page
          redirect_to admins_index_path( view_context.user_params ), notice: 'The User was successfully created.'
          # to user "show" page
          #redirect_to user_path( view_context.user_params.merge( :id => @user ) ), notice: 'The User was successfully created.'
        }
      else
        format.html { render :action => 'new' }
      end
    end
  end
=end

=begin
  def edit
    @user = Admin.find(params[:id])
  end
=end

=begin
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
=end

=begin
  def destroy
    @user = Admin.find(params[:id])
    if @user.destroy
      respond_to do |format|
        format.html { redirect_to admin_index_path( :sort          => session[:sort],
                                                   :direction     => session[:direction],
                                                   :page          => session[:page],
                                                   :num_per_page  => session[:num_per_page],
                                                   :last_name     => session[:last_name],
                                                   :first_name    => session[:first_name],
                                                   :email         => session[:email] ), notice: "SUCCESS: The Admin User record was successfully deleted"
        }
        #format.html {
        #  flash[:notice] = "Successfully deleted User."; redirect_to user_index_path( :page => params[:page], :num_per_page => params[:num_per_page] )
        #}
      end
    end
  end
=end

  private

  def search_conditions
    cond_params = {
      :last_name    => ( params[:last_name].present? )  ? "%#{params[:last_name].downcase}%"   : params[:last_name],
      :first_name   => ( params[:first_name].present? ) ? "%#{params[:first_name].downcase}%"  : params[:first_name],
      :email        => ( params[:email].present? )      ? "%#{params[:email].downcase}%"       : params[:email]
    }

    cond_strings = []
    cond_strings << 'LOWER(admins.last_name) LIKE :last_name'   unless params[:last_name].blank?
    cond_strings << 'LOWER(admins.first_name) LIKE :first_name' unless params[:first_name].blank?
    cond_strings << 'LOWER(admins.email) LIKE :email'           unless params[:email].blank?

    cond_strings.any? ? [ cond_strings.join(' AND '), cond_params ] : nil

  end

=begin
  def update_user_params
    params.require( :admin ).permit( :last_name, :first_name, :email, :role_ids, :password, :password_confirmation )
  end

  def new_user_params
    params.require( :admin ).permit( :last_name, :first_name, :email, :role_ids, :password, :password_confirmation )
  end
=end

  def set_session_params_admin( params )
    session[:page]          = params[:page_num]
    session[:num_per_page]  = params[:num_per_page]
    session[:sort]          = params[:sort]
    session[:direction]     = params[:direction]
    session[:last_name]     = params[:first_name]
    session[:first_name]    = params[:first_name]
    session[:email]         = params[:email]
    session[:func]          = params[:func]
  end

end


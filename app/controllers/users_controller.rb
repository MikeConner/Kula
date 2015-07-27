class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
  # GET /users
  def index
    @users = User.all

    render :layout => 'admin'
  end
  
  # GET /users/:id/edit
  def edit
    @user = User.find(params[:id])
    
    render :layout => 'admin'
  end
  
  # PUT /users/:id
  def update
    @user = User.find(params[:id])
    @user.partner_id = nil unless params[:user].has_key?(:partner_id)
    @user.cause_id = nil unless params[:user].has_key?(:cause_id)      
    
    if @user.update_attributes(user_params)
      redirect_to users_path, :notice => 'User successfully updated'
    else
      render 'edit', :layout => 'admin'
    end
  end
 
  # GET /users/new 
  def new
    # Issue here -- we don't want Sign Up to be publically accessible (otherwise, just put it on the main site)
    # We only want authenicated admins to be able to see it, but you can't create a user if you're logged in
    # So.... you have to sign out, then redirect to Sign Up, which will leave you logged in as the new account
    # To change you role, you have to log out, log back in as a SuperAdmin, and edit the user
    #
    sign_out
    
    redirect_to new_user_registration_path
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to users_path, :notice => 'User successfully destroyed'
  end
  
private
  def user_params
    params.require(:user).permit(:email, :role, :partner_id, :cause_id)
  end
  
  def ensure_admin
    unless current_user.super_admin?
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
end

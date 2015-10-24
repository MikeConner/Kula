class GlobalSettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
  def edit
    @settings = GlobalSetting.first
    
    render :layout => 'admin'
  end
  
  def update
    
  end
      
private
  def ensure_admin
    unless current_user.any_admin?
      redirect_to root_path, :alert => I8n.t('admins_only')
    end
  end
end

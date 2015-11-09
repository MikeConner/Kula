class GlobalSettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
  def edit
    @settings = GlobalSetting.first
    
    render :layout => 'admin'
  end
  
  def update
    @settings = GlobalSetting.first

    period = Date.parse("#{global_settings_params['current_period(1i)']}-#{global_settings_params['current_period(2i)'].rjust(2, '0')}-01")
    
    if @settings.update_attribute(:current_period, period)
      redirect_to site_admin_path, :notice => 'Settings successfully updated'
    else
      redirect_to edit_global_setting_path(@settings), :alert => 'Setting update failed!'
    end    
  end
      
private
  def global_settings_params
    params.require(:global_setting).permit('current_period(1i)', 'current_period(2i)')
  end

  def ensure_admin
    unless current_user.any_admin?
      redirect_to root_path, :alert => I8n.t('admins_only')
    end
  end
end

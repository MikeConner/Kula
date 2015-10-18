class DelayedRakesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
  def index
    @active_jobs = DelayedRake.active_jobs
    @failed_jobs = DelayedRake.failed_jobs
    
    render :layout => 'admin'
  end
    
private
  def ensure_admin
    unless current_user.any_admin?
      redirect_to root_path, :alert => I8n.t('admins_only')
    end
  end
end

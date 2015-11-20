class StaticPagesController < ApplicationController
  def home
  end
  
  def admin_index   
    @partners = Partner.order(:display_name)
    @active_jobs = !DelayedRake.active_jobs.empty?
        
    render :layout => 'admin'
  end
end

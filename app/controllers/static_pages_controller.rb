class StaticPagesController < ApplicationController
  def home
  end
  
  def admin_index   
    @partners = Partner.order(:display_name)
    @active_import = DelayedRake.active_import_transaction?
    
    render :layout => 'admin'
  end
end

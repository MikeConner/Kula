class StaticPagesController < ApplicationController
  def home
  end
  
  def admin_index   
    render :layout => 'admin'
  end
end

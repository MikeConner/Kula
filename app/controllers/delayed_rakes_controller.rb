class DelayedRakesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
  def index
    @active_jobs = DelayedRake.active_jobs
    @failed_jobs = DelayedRake.failed_jobs
    
    render :layout => 'admin'
  end
    
  def replicate
    dr = DelayedRake.create!(:name => DelayedRake::ETL_REPLICATE_TASK)

    dr.update_attribute(:job_identifier, dr.run_task.id)

    redirect_to delayed_rakes_path    
  end
  
  def close_year
    year = params['year']
    
    dr = DelayedRake.create!(:name => DelayedRake::CLOSE_YEAR_TASK)
    dr.set_params({:year => year})
    
    dr.update_attribute(:job_identifier, dr.run_task.id)

    redirect_to delayed_rakes_path    
  end
  
  def generate_payment_batch
    year = params['year']
    month = params['date']['month']
    ach = Payment::ACH == params['ach'] ? 1 : 0
    
    dr = DelayedRake.create!(:name => DelayedRake::GENERATE_PAYMENT_BATCH_TASK)
    dr.set_params({:user_id => current_user.id, 
                   :partner_id => params['partner_id'], 
                   :year => year, 
                   :month => month, 
                   :ach => ach, 
                   :threshold => params['threshold'].to_i})
    
    dr.update_attribute(:job_identifier, dr.run_task.id)

    redirect_to delayed_rakes_path    
  end
  
private
  def ensure_admin
    unless current_user.any_admin?
      redirect_to root_path, :alert => I8n.t('admins_only')
    end
  end
end

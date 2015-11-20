require 'delayed_rake'

class CauseTransactionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
  def import
    if CauseTransaction::LAST_MONTH_LABEL == params['commit']
      year = Date.today.year.to_s
      month = (Date.today.beginning_of_month - 1.month).month.to_s
    else
      year = params['year']
      month = params['date']['month']
    end
    
    dr = DelayedRake.create!(:name => DelayedRake::IMPORT_TX_TASK)
    dr.set_params({:partner_id => params['partner_id'], :year => year, :month => month})
    
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

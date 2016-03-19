class AdjustmentsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @adjustment = Batch.find(params[:batch_id]).adjustments.build
    @cause = current_user.cause.nil? ? '' : current_user.cause.org_name      
  end
  
  def create  
    @adjustment = Adjustment.new(adjustment_params)
    @adjustment.date = Date.strptime(adjustment_params["date"], "%m/%d/%Y")
    @adjustment.month = adjustment_params["month(2i)"].to_i
    @adjustment.year = adjustment_params["year(1i)"].to_i
    
    if @adjustment.valid?
      ActiveRecord::Base.transaction do
      begin
        if params.has_key?(:cause)  
          @adjustment.cause_id = Cause.find_by_org_name(params['cause']).id
        else
          @adjustment.cause_id = nil     
        end
        
        @adjustment.save!
        
        # Save in cause balances too
        CauseBalance.create!(:partner_id => @adjustment.batch.partner.id, 
                             :cause_id => @adjustment.cause_id, 
                             :year => @adjustment.date.year,
                             :balance_type => CauseBalance::ADJUSTMENT,
                             :total => @adjustment.amount)
                             
        redirect_to batch_path(@adjustment.batch), :notice => 'Adjustment was successfully created.'
        
        rescue ActiveRecord::Rollback => ex
          redirect_to batch_path(@adjustment.batch), :alert => 'Adjustment failed!'          
        end
      end
                
    else
      render 'new', :layout => 'admin'
    end
  end
  
private
  def adjustment_params
    params.require(:adjustment).permit(:batch_id, :cause, :amount, :date, :month, :year, :comment)
  end
end

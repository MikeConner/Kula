class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
  def index
    @partner = Partner.find_by_partner_identifier(params[:partner])
    @payments = @partner.nil? ? nil : @partner.payments.order(:batch_id, :date).includes(:cause)
        
    render :layout => 'admin'
  end
  
  def edit
    @payment = Payment.find(params[:id])
    @period_date = Date.parse("#{@payment.year}-#{@payment.month.to_s.rjust(2, '0')}-01")
    
    render :layout => 'admin'
  end
  
  def update
    @payment = Payment.find(params[:id])
    # Period change currently disabled
    #params[:payment][:year] = params[:period]['(1i)'].to_i    
    #params[:payment][:month] = params[:period]['(2i)'].to_i
    
    old_status = @payment.status
    
    ActiveRecord::Base.transaction do
    begin   
      @payment.assign_attributes(payment_params)   
      if @payment.status != old_status
        process_status_change(@payment, old_status)
      end
 
      if @payment.save!   
        redirect_to payments_path, notice: 'Payment was successfully updated.' and return
      end
      
      rescue ActiveRecord::Rollback => ex
        Rails.logger.error ex.message
      end
      
      @period_date = Date.parse("#{@payment.year}-#{@payment.month.to_s.rjust(2, '0')}-01")
      
      render 'edit', :layout => 'admin'
    end
  end
  
  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy
    
    redirect_to payments_path, :alert => 'Payment successfully deleted.'    
  end
  
private 
  def process_status_change(payment, old_status)
    if payment.check_payment?
      actionable = [Payment.CANCELLED, Payment.VOID]
      # going to/from CANCELLED/VOID?
      # If the set intersection is 0, CANCELLED/VOID is not involved and we don't need to worry about it
      # If the set intersection is 2, we're going between CANCELLED and VOID, and again don't need to worry about it
      # If the set intersection is 1, we're going between one of these two "actionable" statuses and something else,
      #   so we need to add an adjustment
      unless 1 == (actionable & [payment.status, old_status]).count
        # If going from Cancelled/Void to something else, positive adjustment; otherwise a negative adjustment
        sign = actionable.include?(old_status) ? 1 : -1
        
        payment.batch.adjustments.create!(:amount => payment.amount * sign, 
                                          :date => Date.today, 
                                          :cause_id => payment.cause_id, 
                                          :month => payment.month, 
                                          :year => payment.year,
                                          :comment => "Status change; payment #{payment.id}, from #{old_status} to #{payment.status}")
      end
    else
      # We know the statuses aren't equal, so if one is RETURNED we need to make an adjustment
      if [payment.status, old_status].include? Payment.RETURNED
        # If going from Returned to something else, positive adjustment; otherwise a negative adjustment
        sign = old_status == Payment.RETURNED ? 1 : -1
        
        payment.batch.adjustments.create!(:amount => payment.amount * sign, 
                                          :date => Date.today, 
                                          :cause_id => payment.cause_id, 
                                          :month => payment.month, 
                                          :year => payment.year,
                                          :comment => "Status change; payment #{payment.id}, from #{old_status} to #{payment.status}")
      end
    end
  end
  
  def payment_params
    params.require(:payment).permit(:status, :amount, :confirmation, :payment_method, :address, :comment, :check_num, :month, :year)
  end
  
  def ensure_admin
    unless current_user.any_admin?
      redirect_to payments_path, :alert => I18n.t('admins_only')
    end
  end
end

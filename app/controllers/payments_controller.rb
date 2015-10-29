class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
  def index
    @partner = Partner.find_by_partner_identifier(params[:partner])
    @payments = @partner.nil? ? nil : @partner.payments.order(:batch_id, :date)
        
    render :layout => 'admin'
  end
  
  def edit
    @payment = Payment.find(params[:id])
    @period_date = Date.parse("#{@payment.year}-#{@payment.month.to_s.rjust(2, '0')}-01")
    
    render :layout => 'admin'
  end
  
  def update
    @payment = Payment.find(params[:id])

    if @payment.update_attributes(payment_params)      
      redirect_to payments_path, notice: 'Payment was successfully updated.'
    else
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
  def payment_params
    params.require(:payment).permit(:status, :amount, :confirmation, :payment_method, :address, :comment, :check_num, :month, :year)
  end
  
  def ensure_admin
    unless current_user.any_admin?
      redirect_to payments_path, :alert => I18n.t('admins_only')
    end
  end
end

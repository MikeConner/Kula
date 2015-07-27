class PartnersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @partners = Partner.all
    
    render :layout => 'admin'
  end
  
  def edit
    @partner = Partner.find_by_partner_identifier(params[:id])
    
    render :layout => 'admin'
  end
  
  def update
    @partner = Partner.find_by_partner_identifier(params[:id])
    if @partner.update_attributes(partner_params)      
      redirect_to partners_path, notice: 'Partner was successfully updated.'
    else
      render 'edit', :layout => 'admin'
    end
  end

  def debt
    @partner = Partner.find_by_partner_identifier(params[:id])

    @causes = CauseBalance.where(:partner_id => @partner.partner_identifier).pluck(:cause_id).uniq.inject({}) { |s, n| s.merge(n => Cause.find_by_cause_identifier(n).name) }
    @owed = calculate_debt
    
    render :layout => 'admin'    
  end
  
  def make_batch
    @partner = Partner.find_by_partner_identifier(params[:id])
    @owed = calculate_debt(params[:minimum_ach].to_i, params[:minimum_check].to_i)
    @ach_causes = Cause.where(:has_ach_info => true).map(&:cause_identifier)
    
    if @owed.empty?
      redirect_to batches_path, :notice => 'No valid Payments; No batch created.'
    else
      batch = @partner.batches.build(:user => current_user, 
                                     :date => Date.today,
                                     :name => params[:batch_name].blank? ? "#{@partner.display_name} #{Time.now.to_s}" : params[:batch_name],
                                     :description => params[:batch_description])
      @owed.each do |cause, total|
        batch.payments.build(:status => Payment::PENDING, 
                             :payment_method => @ach_causes.include?(cause) ? Payment::ACH : Payment::CHECK,
                             :amount => total)
      end
      
      if batch.save
        redirect_to batch_path(batch)
      else
        redirect_to debt_partner_path(@partner), :alert => 'Batch creation failed'
      end
    end
  end
  
private
  def calculate_debt(threshold_ach = 0, threshold_check = 0)
    @owed = Hash.new
    @ach_causes = Cause.where(:has_ach_info => true).map(&:cause_identifier)
    
    CauseBalance.where('partner_id = ? AND ((balance_type = ?) OR (balance_type = ?))', 
                       @partner.id, CauseBalance::PAYABLE, CauseBalance::PAYMENT).each do |balance|
      unless @owed.has_key?(balance.cause_id)
        @owed[balance.cause_id] = 0
      end
      
      if CauseBalance::PAYABLE == balance.balance_type
        @owed[balance.cause_id] += balance.total
      elsif CauseBalance::PAYMENT == balance.balance_type
        @owed[balance.cause_id] -= balance.total        
      end
    end

    @owed.select { |k, v| v >= (@ach_causes.include?(k) ? threshold_ach : threshold_check) }.sort_by { |k, v| v }.reverse 
  end
    
  def partner_params
    params.require(:partner).permit(:partner_identifier, :display_name, :domain, :currency, 
                                    :kula_fees_attributes => [:id, :kula_rate, :discount_rate, :effective_date, :expiration_date,
                                                              :_destroy])    
  end
end

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

    # Parse out datepicker dates properly
    idx = 0
    while params["partner"]["kula_fees_attributes"].has_key?(idx.to_s) do
      effective = params["partner"]["kula_fees_attributes"][idx.to_s]["effective_date"]
      expiration = params["partner"]["kula_fees_attributes"][idx.to_s]["expiration_date"]
      
      unless effective.blank?
        ed = Date.strptime(effective, "%m/%d/%Y")
        params["partner"]["kula_fees_attributes"][idx.to_s]["effective_date"] = ed.strftime("%d/%m/%Y")
      end

      unless expiration.blank?
        ed = Date.strptime(expiration, "%m/%d/%Y")
        params["partner"]["kula_fees_attributes"][idx.to_s]["expiration_date"] = ed.strftime("%d/%m/%Y")
      end
      
      idx += 1
    end    
params["partner"]["kula_fees_attributes"]["0"]
    
    if @partner.update_attributes(partner_params)      
      redirect_to partners_path, notice: 'Partner was successfully updated.'
    else
      render 'edit', :layout => 'admin'
    end
  end

  def debt
    @partner = Partner.find_by_partner_identifier(params[:id])

    @causes = CauseBalance.where(:partner_id => @partner.partner_identifier).pluck(:cause_id).uniq.inject({}) { |s, n| s.merge(n => (Cause.find_by_cause_identifier(n) || Cause.new(:org_name => '?')).org_name) }
    @owed = calculate_debt
    
    render :layout => 'admin'    
  end
  
  def fees
    @partner = Partner.find_by_partner_identifier(params[:id])
    
    @fees = @partner.kula_fees
    
    render :layout => 'admin'
  end
  
  def make_batch
    @partner = Partner.find_by_partner_identifier(params[:id])
    @owed = calculate_debt(params[:minimum_ach].to_i, params[:minimum_check].to_i)
    @ach_causes = Cause.where(:has_eft_bank_info => true).map(&:cause_identifier)
    
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
    @ach_causes = Cause.where(:has_eft_bank_info => true).map(&:cause_identifier)
    
    CauseBalance.where('partner_id = ? AND balance_type = ?', 
                       @partner.id, CauseBalance::PAYMENT).each do |balance|
      unless @owed.has_key?(balance.cause_id)
        @owed[balance.cause_id] = 0
      end
      
      @owed[balance.cause_id] -= balance.total        
    end

    @owed.select { |k, v| v >= (@ach_causes.include?(k) ? threshold_ach : threshold_check) }.sort_by { |k, v| v }.reverse 
  end
    
  def partner_params
    params.require(:partner).permit(:partner_identifier, :display_name, :domain, :currency, 
                                    :kula_fees_attributes => [:id, :us_school_rate, :us_school_kf_rate, 
                                                              :us_charity_rate, :us_charity_kf_rate,
                                                              :intl_charity_rate, :intl_charity_kf_rate, 
                                                              :mcr_cc_rate, :distributor_identifier, :distributor_rate,
                                                              :effective_date, :expiration_date,
                                                              :_destroy])    
  end
end

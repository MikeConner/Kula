class CausesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @cause_name = (params[:cause_name] || "").gsub('*', '%')
    @partner_id = params[:partner].to_i
    @min_balance = params[:min_balance]

    base = CauseBalance.joins(:cause)
    unless 0 == @partner_id
      base = base.where(:partner_id => @partner_id)
    end
    
    unless @min_balance.blank?
      base = base.where('total >= ?', @min_balance)
    end
    
    unless @cause_name.blank?
      base = base.where("name LIKE '#{@cause_name}'")
    end
    
    @balances = base.order("name asc").group(:cause_id).paginate(:page => params[:page])
    
    render :layout => 'admin'
  end

  def show
    @cause = Cause.find_by_cause_identifier(params[:id])
    @partner_balances = Hash.new
    current_partner = nil
    CauseBalance.where(:cause_id => params[:id]).group(:partner_id, :year, :balance_type).each do |balance|
      if current_partner != balance.partner_id
        current_partner = balance.partner_id
        @partner_balances[current_partner] = Hash.new
        @partner_balances[current_partner][balance.year] = { :amount_due => 0, :payable => 0, :payments => 0, :donee => 0, :fees => 0, :net => 0, :discount => 0, :gross => 0 }
      end
      
      unless @partner_balances[current_partner].has_key?(balance.year)
        @partner_balances[current_partner][balance.year] = { :amount_due => 0, :payable => 0, :payments => 0, :donee => 0, :fees => 0, :net => 0, :discount => 0, :gross => 0 }        
      end
      
      case balance.balance_type
      when CauseBalance::PAYABLE
        @partner_balances[current_partner][balance.year][:payable] = balance.total
        @partner_balances[current_partner][balance.year][:amount_due] = balance.total - @partner_balances[current_partner][balance.year][:payments]
      when CauseBalance::PAYMENT
        @partner_balances[current_partner][balance.year][:payments] = balance.total
        @partner_balances[current_partner][balance.year][:amount_due] = @partner_balances[current_partner][balance.year][:payable] - balance.total
      when CauseBalance::GROSS
        @partner_balances[current_partner][balance.year][:gross] = balance.total
      when CauseBalance::DISCOUNT
        @partner_balances[current_partner][balance.year][:discount] = balance.total
      when CauseBalance::NET
        @partner_balances[current_partner][balance.year][:net] = balance.total
      when CauseBalance::FEE
        @partner_balances[current_partner][balance.year][:fees] = balance.total
      when CauseBalance::DONEE_AMOUNT
        @partner_balances[current_partner][balance.year][:donee] = balance.total
      when CauseBalance::ADJUSTMENT
        @partner_balances[current_partner][balance.year][:gross] += balance.total
      else
        raise "Unknown balance type #{balance.balance_type}"
      end
    end
    
    render :layout => 'admin'
  end
end

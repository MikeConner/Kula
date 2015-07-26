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
    @balances = CauseBalance.where(:cause_id => params[:id]).group(:year, :partner_id, :balance_type)
    
    render :layout => 'admin'
  end
end

class CausesController < ApplicationController
  before_filter :authenticate_user!

  def index

    @balances = CauseBalance.joins(:cause).order("name asc").group(:cause_id).paginate(:page => params[:page])
      render :layout => 'admin'
  end

  def show
    @cause = Cause.find_by_cause_identifier(params[:id])
    @balances = CauseBalance.where(:cause_id => params[:id]).group(:year, :partner_id, :balance_type)
        render :layout => 'admin'
  end
end

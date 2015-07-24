class PaymentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @partner = Partner.find_by_partner_identifier(params[:partner])
    @payments = @partner.nil? ? nil : @partner.payments.order(:batch_id, :date)
        render :layout => 'admin'
  end
end

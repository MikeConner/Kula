class BatchesController < ApplicationController
  before_filter :authenticate_user!

  # GET /batches
  def index
    @batches = Batch.order('created_at DESC')
    
    render :layout => 'admin'
  end
  
  # GET /batches/:id
  def show
    @batch = Batch.find(params[:id])
    @payments = @batch.payments.group(:cause_id, :status).order('amount DESC')
    @adjustments = @batch.adjustments.group(:cause_id).order('amount DESC')

    render :layout => 'admin'
  end
  
  # GET /batches/new
  def new
    @partner = Partner.find_by_partner_identifier(params[:partner])
    @batch = @partner.batches.build(:user => current_user)
    
    render :layout => 'admin'
  end

  # POST /batches
  def create
    @batch = Batch.new(batch_params)

    if @batch.save
      # Add to CauseBalance
      ActiveRecord::Base.transaction do
        begin
          @batch.payments.each do |payment|
            balance = CauseBalance.where(:partner_id => @batch.partner, :cause_id => payment.cause,
                                         :year => payment.date.year, :balance_type => CauseBalance::PAYMENT).first_or_create
            case payment.date.month
            when 1
              balance.update_attribute(:jan, balance.jan + payment.amount)
            when 2
              balance.update_attribute(:feb, balance.feb + payment.amount)
            when 3
              balance.update_attribute(:mar, balance.mar + payment.amount)
            when 4
              balance.update_attribute(:apr, balance.apr + payment.amount)
            when 5
              balance.update_attribute(:may, balance.may + payment.amount)
            when 6
              balance.update_attribute(:jun, balance.jun + payment.amount)
            when 7
              balance.update_attribute(:jul, balance.jul + payment.amount)
            when 8
              balance.update_attribute(:aug, balance.aug + payment.amount)
            when 9
              balance.update_attribute(:sep, balance.sep + payment.amount)
            when 10
              balance.update_attribute(:oct, balance.oct + payment.amount)
            when 11
              balance.update_attribute(:nov, balance.nov + payment.amount)
            when 12
              balance.update_attribute(:dec, balance.dec + payment.amount)
            end

            balance.update_attribute(:total, balance.jan + balance.feb + balance.mar + balance.apr + balance.may + balance.jun +
                                             balance.jul + balance.aug + balance.sep + balance.oct + balance.nov + balance.dec)
          end
        rescue ActiveRecord::Rollback => ex
          # All or nothing
          @batch.destroy
        end
      end

      redirect_to payments_path(:partner => @batch.partner_id), :notice => 'Batch was successfully created.'
    else
      render 'new', :layout => 'admin'
    end
  end

private
  def batch_params
    params.require(:batch).permit(:partner_id, :user_id, :name, :date, :description,
                                  :payments_attributes => [:id, :status, :amount, :date, :confirmation,
                                                           :payment_method, :address, :comment, :cause_id,
                                                           :_destroy])
  end
end

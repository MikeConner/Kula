class BatchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_or_owner, :only => [:destroy]
  
  # GET /batches
  def index
    @batches = Batch.order('created_at DESC')
    
    render :layout => 'admin'
  end
  
  # GET /batches/:id
  def show
    @batch = Batch.find(params[:id])
    @payments = @batch.payments.group('payments.id', :cause_id, :status).order('amount DESC')
    @adjustments = @batch.adjustments.group('adjustments.id', :cause_id).order('amount DESC')

    render :layout => 'admin'
  end
  
  # GET /batches/new
  def new
    @partner = Partner.find_by_partner_identifier(params[:partner])
    @batch = @partner.batches.build(:user => current_user)
    @cause = current_user.cause.nil? ? '' : current_user.cause.org_name  
        
    render :layout => 'admin'
  end

  # POST /batches
  def create
    # Cause fields are autocomplete. Cause_id comes back as a string, but we need it to be the cause_identifier
    # Convert before passing to batch creation
    if params[:batch].has_key?(:payments_attributes)
      params[:batch][:payments_attributes].each do |k, v|
        v[:cause_id] = Cause.find_by_org_name(v[:cause_id]).cause_identifier
      end
    end
    
    if params[:batch].has_key?(:adjustments_attributes)
      params[:batch][:adjustments_attributes].each do |k, v|
        v[:cause_id] = Cause.find_by_org_name(v[:cause_id]).cause_identifier
      end
    end
    
    @batch = Batch.new(batch_params)
    
    # Preprocess to change embedded autocompleted text cause_ids to integer cause_ids
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
          
          @batch.adjustments.each do |adjustment|
            balance = CauseBalance.where(:partner_id => @batch.partner, :cause_id => payment.cause,
                                         :year => payment.date.year, :balance_type => CauseBalance::ADJUSTMENT).first_or_create
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

  def destroy
    causes = @batch.payments.map(&:cause_id).uniq | @batch.adjustments.map(&:cause_id).uniq
    
    ActiveRecord::Base.transaction do
      @batch.payments.each do |p|
        balance = CauseBalance.where(:partner_id => @batch.partner_id, :cause_id => p.cause_id, :year => p.year, :balance_type => CauseBalance::PAYMENT).first
        if balance.nil?
          raise "Cause Balance payment record not found when deleting batch #{@batch.id}, #{p.inspect}"
        end
        
        # payments are negative, so subtracting them cancels the payment
        adjust_cause_balance(balance, p.month, p.amount)
      end
      @batch.payments.destroy_all

      @batch.adjustments.each do |a|
        balance = CauseBalance.where(:partner_id => @batch.partner_id, :cause_id => a.cause_id, :year => a.year, :balance_type => CauseBalance::ADJUSTMENT).first
        if balance.nil?
          raise "Cause Balance payment record not found when deleting batch #{@batch.id}, #{a.inspect}"
        end
        
        # payments are negative, so subtracting them cancels the payment
        # adjustments can be either, but still want to subtract them
        adjust_cause_balance(balance, a.month, a.amount)
      end      
      @batch.adjustments.destroy_all
      @batch.destroy
      
      str_ids = causes.to_s.gsub('[','').gsub(']','')
      ActiveRecord::Base.connection.execute("UPDATE cause_balances SET total=jan+feb+mar+apr+may+jun+jul+aug+sep+oct+nov+dec WHERE cause_id in (#{str_ids})")    
    end
    
    redirect_to batches_path, :notice => 'Batch was successfully deleted'
  end
  
private
  def batch_params
    params.require(:batch).permit(:partner_id, :user_id, :name, :date, :description,
                                  :payments_attributes => [:status, :amount, :date, :confirmation,
                                                           :payment_method, :address, :comment, :cause_id, :check_num,
                                                           'month(1i)', 'month(2i)', 'month(3i)', 'year(1i)', 'year(2i)', 'year(3i)',
                                                           :_destroy],
                                  :adjustments_attributes => [:amount, :date, :comment, :cause_id,
                                                              'month(1i)', 'month(2i)', 'month(3i)', 'year(1i)', 'year(2i)', 'year(3i)',
                                                              :_destroy])
  end
  
  def admin_or_owner
    @batch = Batch.find(params[:id])
    unless current_user.any_admin? or current_user.id == @batch.user_id
      redirect_to batches_path, :alert => I18n.t('admins_only')
    end
  end
  
  def adjust_cause_balance(balance, month, amount)
    case month
    when 1
      balance.update_attribute(:jan, balance.jan - amount)
    when 2
      balance.update_attribute(:feb, balance.feb - amount)
    when 3
      balance.update_attribute(:mar, balance.mar - amount)
    when 4
      balance.update_attribute(:apr, balance.apr - amount)
    when 5
      balance.update_attribute(:may, balance.may - amount)
    when 6
      balance.update_attribute(:jun, balance.jun - amount)
    when 7
      balance.update_attribute(:jul, balance.jul - amount)
    when 8
      balance.update_attribute(:aug, balance.aug - amount)
    when 9
      balance.update_attribute(:sep, balance.sep - amount)
    when 10
      balance.update_attribute(:oct, balance.oct - amount)
    when 11
      balance.update_attribute(:nov, balance.nov - amount)
    when 12
      balance.update_attribute(:dec, balance.dec - amount)
    end    
  end
end

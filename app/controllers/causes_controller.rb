class CausesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @cause_name = (params[:cause_name] || "").gsub('*', '%')
    @min_balance = params[:min_balance].to_f
    
    where_clause = @cause_name.blank? ? '' : "WHERE org_name LIKE '%#{@cause_name}%'"
    sql = 'SELECT causes.cause_identifier, causes.cause_id, causes.org_name,' +
          "(SELECT sum(total) FROM cause_balances where cause_balances.cause_id = causes.CAUSE_IDENTIFIER and balance_type in('#{CauseBalance::DONEE_AMOUNT}', '#{CauseBalance::PAYMENT}', '#{CauseBalance::ADJUSTMENT}')) as balance_due," + 
          "(SELECT sum(total) FROM cause_balances where cause_balances.cause_id = causes.CAUSE_IDENTIFIER and balance_type in('#{CauseBalance::DONEE_AMOUNT}')) as donated_balance," +
          "(SELECT sum(total) FROM cause_balances where cause_balances.cause_id = causes.CAUSE_IDENTIFIER and balance_type in('#{CauseBalance::PAYMENT}')) as payments_balance," +
          "(SELECT sum(total) FROM cause_balances where cause_balances.cause_id = causes.CAUSE_IDENTIFIER and balance_type in('#{CauseBalance::ADJUSTMENT}')) as adj_balance" +
          " FROM causes #{where_clause} ORDER BY org_name;"

    @cause_data = []
    
    records = ActiveRecord::Base.connection.execute(sql)
    records.each do |line|
      due = line['balance_due'].to_f
      donated = line['donated_balance'].to_f
      payments = line['payments_balance'].to_f
      unless 0 == payments
        payments *= -1
      end
      adjustments = line['adj_balance'].to_f
      
      next if due.nil? and donated.nil? and payments.nil? and adjustments.nil?
      next unless (0 == @min_balance) or (due >= @min_balance)
      
      @cause_data.push({:name => line['org_name'], :path => cause_path(line['cause_identifier']), :due => due, :donated => donated, :payments => payments, :adjustments => adjustments})
    end
 
    @causes = @cause_data.paginate(:page => params[:page])
    
    render :layout => 'admin'
  end

  def show
    @cause = Cause.find_by_cause_identifier(params[:id])
    @partner_balances = Hash.new
    CauseBalance.where(:cause_id => params[:id]).each do |balance|
      current_partner = balance.partner_id
      
      unless @partner_balances.has_key?(current_partner)
        @partner_balances[current_partner] = Hash.new 
      end
       
      unless @partner_balances[current_partner].has_key?(balance.year)
        @partner_balances[current_partner][balance.year] = { :payments => 0, :adjustments => 0, :amount_due => 0, :donee => 0, :kula_fee => 0, :foundation_fee => 0, :distributor_fee => 0, :net => 0, :discount => 0, :gross => 0 }        
      end
      
      case balance.balance_type
      when CauseBalance::PAYMENT
        @partner_balances[current_partner][balance.year][:payments] += balance.total
        # Payments should be negative, so it's just addition
        @partner_balances[current_partner][balance.year][:amount_due] += balance.total
      when CauseBalance::GROSS
        @partner_balances[current_partner][balance.year][:gross] += balance.total
      when CauseBalance::DISCOUNT
        @partner_balances[current_partner][balance.year][:discount] += balance.total
      when CauseBalance::NET
        @partner_balances[current_partner][balance.year][:net] += balance.total
      when CauseBalance::KULA_FEE
        @partner_balances[current_partner][balance.year][:kula_fee] += balance.total
      when CauseBalance::DISTRIBUTOR_FEE
        @partner_balances[current_partner][balance.year][:distributor_fee] += balance.total
      when CauseBalance::FOUNDATION_FEE
        @partner_balances[current_partner][balance.year][:foundation_fee] += balance.total
      when CauseBalance::DONEE_AMOUNT
        @partner_balances[current_partner][balance.year][:donee] += balance.total
        @partner_balances[current_partner][balance.year][:amount_due] += balance.total
      when CauseBalance::ADJUSTMENT
        @partner_balances[current_partner][balance.year][:adjustments] += balance.total
        # Adjustments should be negative, so it's just addition
        @partner_balances[current_partner][balance.year][:amount_due] += balance.total
      else
        raise "Unknown balance type #{balance.balance_type}"
      end
    end
        
    render :layout => 'admin'
  end
  
  def autocomplete
    @causes = Cause.where("org_name ILIKE ?", "%#{params[:term]}%").order(:org_name)
    
    respond_to do |format|
      format.html
      format.json { render json: @causes.map(&:org_name) }
    end    
  end
end

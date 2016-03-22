class CausesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @cause_name = (params[:cause_name] || "").gsub('*', '%')
    @partner_id = params[:partner].to_i
    @has_ach = params[:has_ach].to_i
    if params[:min_balance].blank?
      @min_balance = 1 == @has_ach ? CauseBalance::DEFAULT_ACH_PAYMENT_THRESHOLD : CauseBalance::DEFAULT_CHECK_PAYMENT_THRESHOLD
    else
      @min_balance = params[:min_balance].to_f
    end
    
    where_clause = @cause_name.blank? ? '' : " AND org_name LIKE '%#{@cause_name}%'"
    base_sql = CauseBalance.cause_index_query
    current_year = GlobalSetting.first.current_period.year
    
    sql = base_sql.gsub('##NAME_FILTER', where_clause).gsub('##YEAR', current_year.to_s)
    if 0 == @partner_id
      sql.gsub!('##PARTNER_FILTER', '')
    else
      sql.gsub!('##PARTNER_FILTER', " AND partner_id = #{@partner_id}")
    end
        
    if 1 == @has_ach
      sql.gsub!('##ACH_FILTER', ' AND c.has_eft_bank_info = 1')
    else
      sql.gsub!('##ACH_FILTER', '')
    end
    @cause_data = []
        
    partner_names = Partner.all.inject({}) { |s, p| s.update(p.id => p.name) }
    
    records = ActiveRecord::Base.connection.execute(sql)
    records.each do |line|
      next unless (0 == @min_balance) or (line['q4_total'].to_f >= @min_balance)
      
      @cause_data.push({:cause_name => line['org_name'], 
                        :cause_path => cause_path(line['cause_id']), 
                        :partner_name => partner_names[line['partner_id'].to_i],
                        :q1 => line['q1_total'].to_f,
                        :q2 => line['q2_total'].to_f,
                        :q3 => line['q3_total'].to_f, 
                        :q4 => line['q4_total'].to_f, })
    end
 
    @causes = @cause_data.paginate(:page => params[:page])
    
    render :layout => 'admin'
  end

  def show
    @cause = Cause.find_by_cause_identifier(params[:id])
    
    @partner_balances = Hash.new
    @tx_data = Hash.new
    @original_tx = Hash.new
    @payment_data = Hash.new
    @adjustment_data = Hash.new
    
    @cause.payments.each do |p|
      unless @payment_data.has_key?(p.partner.id)
        @payment_data[p.partner.id] = []
      end
      
      @payment_data[p.partner.id].push(p)
    end

    @cause.adjustments.each do |a|
      unless @adjustment_data.has_key?(a.partner.id)
        @adjustment_data[a.partner.id] = []
      end
      
      @adjustment_data[a.partner.id].push(a)
    end
      
    CauseBalance.where(:cause_id => params[:id]).each do |balance|
      current_partner = balance.partner_id
      
      unless @partner_balances.has_key?(current_partner)
        @partner_balances[current_partner] = Hash.new 
        @tx_data[current_partner] = @cause.cause_transactions.where(:partner_identifier => current_partner).order('year, month')
        sql = 'SELECT u.first_name, u.last_name, u.city, u.region, u.country, u.postal_code, amount, created ' +
                'FROM replicated_balance_transactions bt ' +
                  'JOIN replicated_users u ON u.user_id = bt.user_id ' +  
                    "WHERE cause_id = '#{params[:id]}' AND partner_id = #{current_partner} " + 
                      'ORDER BY created'
        @original_tx[current_partner] = ActiveRecord::Base.connection.execute(sql)
      end
       
      unless @partner_balances[current_partner].has_key?(balance.year)
        @partner_balances[current_partner][balance.year] = { :payments => 0, :adjustments => 0, :amount_due => 0, :donee => 0, :kula_fee => 0, :foundation_fee => 0, :distributor_fee => 0, :credit_card_fee => 0, :net => 0, :discount => 0, :gross => 0 }        
      end
      
      case balance.balance_type
      when CauseBalance::PAYMENT
        @partner_balances[current_partner][balance.year][:payments] += balance.total
        @partner_balances[current_partner][balance.year][:amount_due] += balance.total
      when CauseBalance::GROSS
        @partner_balances[current_partner][balance.year][:gross] += balance.total
      when CauseBalance::KULA_FEE
        @partner_balances[current_partner][balance.year][:kula_fee] += balance.total
      when CauseBalance::DISTRIBUTOR_FEE
        @partner_balances[current_partner][balance.year][:distributor_fee] += balance.total
      when CauseBalance::FOUNDATION_FEE
        @partner_balances[current_partner][balance.year][:foundation_fee] += balance.total
      when CauseBalance::CREDIT_CARD_FEE
        @partner_balances[current_partner][balance.year][:credit_card_fee] += balance.total
      when CauseBalance::DONEE_AMOUNT
        @partner_balances[current_partner][balance.year][:donee] += balance.total
        @partner_balances[current_partner][balance.year][:amount_due] += balance.total
      when CauseBalance::ADJUSTMENT
        @partner_balances[current_partner][balance.year][:adjustments] += balance.total
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

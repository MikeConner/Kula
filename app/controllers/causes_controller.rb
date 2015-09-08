class CausesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @cause_name = (params[:cause_name] || "").gsub('*', '%')
    @min_balance = params[:min_balance].to_f
    
    where_clause = @cause_name.blank? ? '' : "WHERE name LIKE '%#{@cause_name}%'"

    sql = 'SELECT *,' +
          "(SELECT sum(total) FROM #{Rails.configuration.database_configuration[Rails.env]['database']}.cause_balances where cause_balances.cause_id = causes.CAUSE_IDENTIFIER  and balance_type in('#{CauseBalance::DONEE_AMOUNT}', '#{CauseBalance::PAYMENT}', '#{CauseBalance::ADJUSTMENT}')) as balance_due," + 
          "(SELECT sum(total) FROM #{Rails.configuration.database_configuration[Rails.env]['database']}.cause_balances where cause_balances.cause_id = causes.CAUSE_IDENTIFIER  and balance_type in('#{CauseBalance::DONEE_AMOUNT}')) as donated_balance," +
          "(SELECT sum(total) FROM #{Rails.configuration.database_configuration[Rails.env]['database']}.cause_balances where cause_balances.cause_id = causes.CAUSE_IDENTIFIER  and balance_type in('#{CauseBalance::PAYMENT}')) as payments_balance," +
          "(SELECT sum(total) FROM #{Rails.configuration.database_configuration[Rails.env]['database']}.cause_balances where cause_balances.cause_id = causes.CAUSE_IDENTIFIER  and balance_type in('#{CauseBalance::ADJUSTMENT}')) as adj_balance" +
          " FROM #{Rails.configuration.database_configuration[Rails.env]['database']}.causes #{where_clause} ORDER BY name;"

    @cause_data = []
    
    records = ActiveRecord::Base.connection.execute(sql)
    records.each do |line|
      due = line[line.length - 4].to_f
      donated = line[line.length - 3].to_f
      payments = line[line.length - 2].to_f
      adjustments = line[line.length - 1].to_f
      
      next if due.nil? and donated.nil? and payments.nil? and adjustments.nil?
      next unless (0 == @min_balance) or (due >= @min_balance)
      
      @cause_data.push({:name => line[1], :path => cause_path(line[0]), :due => due, :donated => donated, :payments => payments, :adjustments => adjustments})
    end
 
    @causes = @cause_data.paginate(:page => params[:page])
    
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

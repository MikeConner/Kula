namespace :db do
  desc "Generate payment batch"
  task :generate_payment_batch, [:user_id, :partner_id, :year, :month, :ach, :threshold] => :environment do |t, args|
    unless args.has_key?(:user_id) and args.has_key?(:partner_id) and args.has_key?(:year) and args.has_key?(:month)
      puts "Need user id, partner id, year, and month: db:generate_batch[3024,24,2015,3{,1/0 ach flag,payment threshold}]"
    end
    
    filter_by_ach = 1 == (args[:ach].to_i || 0)
    threshold = filter_by_ach ? (args[:threshold] || CauseBalance::DEFAULT_ACH_PAYMENT_THRESHOLD).to_i :
                                (args[:threshold] || CauseBalance::DEFAULT_CHECK_PAYMENT_THRESHOLD).to_i   
    year = args[:year].to_i
    month = args[:month].to_i

    # Make sure the user and partner are real
    user = User.find(args[:user_id])
    partner = Partner.find(args[:partner_id])

    payment_type = filter_by_ach ? 'ACH' : 'Check'
    
    description = "#{payment_type} batch for user #{user.email}, partner #{partner.display_name}, for #{month}/#{year}, with threshold #{threshold}"
    puts description
    
    sql = filter_by_ach ? CauseBalance.payment_batch_ach_query : CauseBalance.payment_batch_check_query
    sql.gsub!('##YEAR', args[:year]).gsub!('##PARTNER_ID', args[:partner_id])                         

    records = ActiveRecord::Base.connection.execute(sql)
    payments = []
    
    puts "Processing #{records.count} balances"
    
    idx = 1
    records.each do |balance|
      puts idx if 0 == idx % 1000
      idx += 1
      
      payment_amount = (balance['prior_year'].to_f + sum_months(balance, month)).round(2)
      
      if payment_amount >= threshold
        payments.push({:cause_id => balance['cause_id'].to_i, :amount => payment_amount})
      end
    end

    puts "Making #{payments.count} payments"
 
    ActiveRecord::Base.transaction do  
      begin        
        batch = Batch.create!(:user_id => user.id, 
                              :partner_id => partner.id, 
                              :name => 'Generate Payment Batch task', 
                              :description => description, 
                              :date => Time.now)
        
        num = 1000
        
        payments.each do |payment|
          batch.payments.create!(:amount => payment[:amount], 
                                 :cause_id => payment[:cause_id], 
                                 :payment_method => filter_by_ach ? Payment::ACH : Payment::CHECK,
                                 :check_num => num,
                                 :month => month,
                                 :year => year)
          num += 1
          
          balance = CauseBalance.find_or_create_by(:partner_id => partner.id, 
                                                   :cause_id => payment[:cause_id], 
                                                   :year => year, 
                                                   :balance_type => CauseBalance::PAYMENT)
          
          # Put in payments as negative
          balance.update_balance(month, -1 * payment[:amount])
        end
      rescue ActiveRecord::Rollback => ex
        puts ex.inspect
      end
    end
  end
  
  def sum_months(balance, month)
    case month
    when 1
      balance['jan_sum'].to_f
    when 2
      balance['jan_sum'].to_f + balance['feb_sum'].to_f
    when 3
      balance['jan_sum'].to_f + balance['feb_sum'].to_f + balance['mar_sum'].to_f
    when 4
      balance['jan_sum'].to_f + balance['feb_sum'].to_f + balance['mar_sum'].to_f + balance['apr_sum'].to_f
    when 5
      balance['jan_sum'].to_f + balance['feb_sum'].to_f + balance['mar_sum'].to_f + balance['apr_sum'].to_f + balance['may_sum'].to_f
    when 6
      balance['jan_sum'].to_f + balance['feb_sum'].to_f + balance['mar_sum'].to_f + balance['apr_sum'].to_f + balance['may_sum'].to_f +
      balance['jun_sum'].to_f  
    when 7
      balance['jan_sum'].to_f + balance['feb_sum'].to_f + balance['mar_sum'].to_f + balance['apr_sum'].to_f + balance['may_sum'].to_f +
      balance['jun_sum'].to_f + balance['jul_sum'].to_f  
    when 8 
      balance['jan_sum'].to_f + balance['feb_sum'].to_f + balance['mar_sum'].to_f + balance['apr_sum'].to_f + balance['may_sum'].to_f +
      balance['jun_sum'].to_f + balance['jul_sum'].to_f + balance['aug_sum'].to_f 
    when 9
      balance['jan_sum'].to_f + balance['feb_sum'].to_f + balance['mar_sum'].to_f + balance['apr_sum'].to_f + balance['may_sum'].to_f +
      balance['jun_sum'].to_f + balance['jul_sum'].to_f + balance['aug_sum'].to_f + balance['sep_sum'].to_f 
    when 10
      balance['jan_sum'].to_f + balance['feb_sum'].to_f + balance['mar_sum'].to_f + balance['apr_sum'].to_f + balance['may_sum'].to_f +
      balance['jun_sum'].to_f + balance['jul_sum'].to_f + balance['aug_sum'].to_f + balance['sep_sum'].to_f + balance['oct_sum'].to_f 
    when 11
      balance['jan_sum'].to_f + balance['feb_sum'].to_f + balance['mar_sum'].to_f + balance['apr_sum'].to_f + balance['may_sum'].to_f +
      balance['jun_sum'].to_f + balance['jul_sum'].to_f + balance['aug_sum'].to_f + balance['sep_sum'].to_f + balance['oct_sum'].to_f +
      balance['nov_sum'].to_f
    when 12
      # Could use total, but this way we don't depend on the total matching
      balance['jan_sum'].to_f + balance['feb_sum'].to_f + balance['mar_sum'].to_f + balance['apr_sum'].to_f + balance['may_sum'].to_f +
      balance['jun_sum'].to_f + balance['jul_sum'].to_f + balance['aug_sum'].to_f + balance['sep_sum'].to_f + balance['oct_sum'].to_f +
      balance['nov_sum'].to_f + balance['dec_sum'].to_f
    end
  end
end

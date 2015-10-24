namespace :db do
  desc "Import payments"
  task :import_payments => :environment do
    row = 0
    Payment.joins(:batch).each do |payment|
      begin                
        row += 1
        if 0 == row % 100
          puts row
        end       
       
        partner_id = payment.batch.partner_id       
        cause_id = payment.cause_id 
        month = payment.date.month 
        year = payment.date.year
        payment = payment.amount.to_f 

        if payment > 0    
          balance = CauseBalance.find_or_create_by(:partner_id => partner_id, :cause_id => cause_id, :year => year, :balance_type => CauseBalance::PAYMENT)
          
          # Put in payments as negative
          update_balance(balance, month, -1 * payment)
        end
      rescue Exception => ex
        puts ex.inspect  
      end
    end  
    
    # Total Cause Balances
    Rake::Task["db:total_cause_balances"].invoke   
  end
  
  desc "(One-off) Create pre-2014 adjustments"
  task :create_adjustments => :environment do
    ActiveRecord::Base.establish_connection(:production).connection unless Rails.env.production?
    user = User.select { |u| u.super_admin? }.first
    one_off = 'One off adjustment due to lack of early data'
    batches = Hash.new
    
    for year in 2012..2013      
      sql = "SELECT partner_identifier, cause_identifier, sum(donee_amount) FROM cause_transactions WHERE year=#{year} GROUP BY partner_identifier, cause_identifier"
      records = ActiveRecord::Base.connection.execute(sql)
      adj_date = Date.parse("#{year}-12-31")
      
      records.each do |rec|
        partner = rec['partner_identifier'].to_i
        cause = rec['cause_identifier'].to_i
        amount = -rec['sum'].to_f

        unless batches.has_key?(partner)
          batches[partner] = Batch.create!(:name => 'Historical adjustment', :partner_id => partner, :user_id => user.id, 
                                           :date => adj_date, :description => one_off)
        end
        
        batches[partner].adjustments.create!(:amount => amount, :date => adj_date, :comment => one_off, :cause_id => cause)
        CauseBalance.create!(:partner_id => partner, :cause_id => cause, :year => year, :balance_type => CauseBalance::ADJUSTMENT, :dec => amount, :total => amount)
      end
    end
  end
  
  task :test, [:partner_id, :year, :month] => :environment do |t, args|
    puts "FISH #{args[:partner_id]}, #{args[:year]}, #{args[:month]}"
  end

  desc "Import transactions"
  task :stepwise_import_transactions, [:partner_id, :year, :month] => :environment do |t, args|
    # Read from read-only replica (or our ghetto writeable copy), copy data to postgres reporting db
    #  In the process: calculate fees and write those alongside Kula's calculations 
    partner_id_param = args[:partner_id].to_i
    # Can be given a year but no month
    #   Or a year and a month
    #   Or neither
    year_param = args[:year].to_i
    month_param = args[:month].to_i
    
    # We're given a year
    if 0 == month_param
      unless 0 == year_param
        # If both nil, fall through and it will use the full date range
        current_date = Date.parse("#{year_param}-01-01")
        latest_date = current_date + 1.year
      end
    else
      # Month is valid - year must also be valid or it's an error
      if 0 == year_param
        raise "Invalid parameters: must give year and month"
      else
        current_date = Date.parse("#{year_param}-#{month_param.to_s.rjust(2,'0')}-01")
        latest_date = current_date + 1.month
      end
    end

    all_time = current_date.nil?
    
    # If no start/end defined, fall through and use full range (start_date and end_date must be defined together, so only one nil check suffices)
    if all_time
      current_date = Date.parse(ActiveRecord::Base.connection.execute('SELECT DISTINCT created FROM replicated_balance_transactions ORDER BY created LIMIT 1').first['created']).beginning_of_month
      latest_date = Date.parse(ActiveRecord::Base.connection.execute('SELECT DISTINCT created FROM replicated_balance_transactions ORDER BY created DESC LIMIT 1').first['created']).beginning_of_month
    end
          
    # Permissions issue using Sprockets on elastic beanstalk  
    sql_base = CauseTransaction.query_step1
        
    puts "Reading transactions from #{current_date.to_s} to #{latest_date.to_s}"
    BATCH_SIZE = 500
            
    # Delete everything if all partners
    if 0 == partner_id_param 
      if all_time
        CauseTransaction.delete_all
        CauseBalance.where("NOT balance_type IN ('#{CauseBalance::PAYMENT}','#{CauseBalance::ADJUSTMENT}')").delete_all
      else
        CauseTransaction.select { |tx| (current_date..latest_date).include? Date.parse("#{tx.year}-#{tx.month.to_s.rjust(2, '0')}-01") }.delete_all
        balances = CauseBalance.where("NOT balance_type IN ('#{CauseBalance::PAYMENT}','#{CauseBalance::ADJUSTMENT}')").select { |b| (current_date.year..latest_date.year).include? b.year }
        balances.each do |b|
          clear_balances(b, current_date, latest_date)
        end
      end
    else
      if all_time
        CauseTransaction.where(:partner_identifier => partner_id).delete_all      
        CauseBalance.where(:partner_id => partner_id).where("NOT balance_type IN ('#{CauseBalance::PAYMENT}','#{CauseBalance::ADJUSTMENT}')").delete_all
      else
        CauseTransaction.where(:partner_identifier => partner_id).select { |tx| (current_date..latest_date).include? Date.parse("#{tx.year}-#{tx.month.to_s.rjust(2, '0')}-01") }.delete_all
        balances = CauseBalance.where(:partner_id => partner_id).where("NOT balance_type IN ('#{CauseBalance::PAYMENT}','#{CauseBalance::ADJUSTMENT}')").select { |b| (current_date.year..latest_date.year).include? b.year }
        balances.each do |b|
          clear_balances(b, current_date, latest_date)
        end        
      end
    end
        
    while current_date <= latest_date do
      start_date = current_date.to_s
      end_date = (current_date + 1.month).to_s
      
      puts "Processing #{start_date} to #{end_date}"
      
      # fill in dates
      sql = sql_base.gsub('##START_DATE', "'#{start_date}'").gsub('##END_DATE', "'#{end_date}'")
      if 0 == partner_id_param
        sql.gsub!('##PARTNER_CLAUSE', '')
      else
        sql.gsub!('##PARTNER_CLAUSE', " AND bt.partner_id = #{partner_id_param}")
      end
      
      #ActiveRecord::Base.establish_connection(:test_dev).connection unless Rails.env.test_dev?
      
      puts "Reading transactions from source..."
      transactions = ActiveRecord::Base.connection.execute(sql)
      puts "Read #{transactions.count} transactions"

      # Now point to postgres
      puts "Processing transactions..."
      
      idx = 0
      records = []
      
      transactions.each do |tx|
        if (idx > 0) and (0 == idx % BATCH_SIZE)
          puts "Committing batch #{idx}"
          ActiveRecord::Base.transaction do  
            records.each do |r|
              CauseTransaction.create!(r)
              
              update_cause_balances(r)
            end           
            records = []
          end       
        end
        
        idx += 1

        cid = tx['causeid'].to_i        
        partner_id = tx['partnerid'].to_i        
        month = tx['month'].to_i
        year = tx['year'].to_i
        
        partner = Partner.find(partner_id)
        if partner.nil?
          puts "Could not find partner #{partner_id}"
        else
          # distributor is always nil
          fee = partner.current_kula_rate(nil, Date.parse("#{year}-#{month}-01"))
          
          if fee.nil?
            puts "Could not find fee for cause #{cid} P=#{partner_id}, C=#{cid} Date:#{month}/#{year}"
          else
            gross = tx['grossamount'].to_f
            usa = 'US' == tx['country'].strip
            cause_type = tx['causetype'].to_i
            cause_name = tx['causename']
            
            if Cause::SCHOOL_TYPE == cause_type
              total_rate = fee.us_school_rate + fee.us_school_kf_rate
              total_fee = total_rate * gross
              
              kula_fee = 0 == total_rate ? 0 : fee.us_school_rate / total_rate * total_fee
              foundation_fee = total_fee - kula_fee
            else
              total_rate = usa ? fee.us_charity_rate + fee.us_charity_kf_rate : fee.intl_charity_rate + fee.intl_charity_kf_rate
              total_fee = total_rate * gross
              
              if 0 == total_rate
                kula_fee = 0
              else
                kula_fee = (usa ? fee.us_charity_rate / total_rate : fee.intl_charity_rate / total_rate) * total_fee 
              end
              
              foundation_fee = total_fee - kula_fee
            end
                        
            records.push({:partner_identifier => partner_id,
                          :cause_identifier => cid,
                          :month => month,
                          :year => year,
                          :gross_amount => gross,
                          :net_amount => tx['netamount'].to_f,
                          :donee_amount => tx['doneeamount'].to_f,
                          :discounts_amount => tx['discountamount'].to_f,
                          :fees_amount => tx['kulafees'].to_f,
                          :calc_kula_fee => kula_fee,
                          :calc_foundation_fee => foundation_fee,
                          :calc_distributor_fee => 0,
                          :calc_credit_card_fee => 0})          
          end
        end
      end
      
      puts "Committing last batch of #{records.count}"
      ActiveRecord::Base.transaction do  
        records.each do |r|
          CauseTransaction.create!(r)
          
          update_cause_balances(r)
        end
      end
     
      current_date += 1.month
    end

    puts "STEP 2"
    sql = CauseTransaction.query_step2
    
    if 0 == partner_id_param
      sql.gsub!('##PARTNER_CLAUSE', '')
    else
      sql_base.gsub!('##PARTNER_CLAUSE', " AND bt.partner_id = #{partner_id_param}")
    end
    
    transactions = ActiveRecord::Base.connection.execute(sql)
    puts "Read #{transactions.count} discount transactions"

    transactions.each do |tx|
      partner_id = tx['partner_id'].to_i
      distributor_id = tx['distributor_id'].to_i
      month = tx['month'].to_i
      year = tx['year'].to_i
      cause_id = tx['cause_id'].to_i
      
      existing_tx = CauseTransaction.where(:partner_identifier => partner_id,
                                           :cause_identifier => cause_id,
                                           :month => month,
                                           :year => year).first      
      partner = Partner.find(partner_id)
      if partner.nil?
        puts "Could not find partner #{partner_id}"
      else
        fee = partner.current_kula_rate(distributor_id, Date.parse("#{year}-#{month}-01"))
        if fee.nil?
          # If unknown distributor, add in a 0 fee entry
          fee = partner.kula_fees.create(:distributor_identifier => distributor_id, 
                                         :distributor_rate => 0, 
                                         :us_charity_rate => 0.1, 
                                         :us_charity_kf_rate => 0.025, 
                                         :us_school_rate => 0.1, 
                                         :us_school_kf_rate => 0.025, 
                                         :intl_charity_rate => 0.1, 
                                         :intl_charity_kf_rate => 0.025,
                                         :mcr_cc_rate => 0)
          puts "Added previously unknown distributor: #{distributor_id}"
        end
        
        if fee.nil?
           puts "Could not find fee for cause #{cause_id} P=#{partner_id} D=#{distributor_id}, Date:#{month}/#{year}"
        else                        
          distributor_fee = (fee.distributor_rate * tx['amount'].to_f).round(2)
          
          unless 0 == distributor_fee
            ActiveRecord::Base.transaction do
              if existing_tx.nil?
                puts "Could not find CauseTransaction: #{tx.inspect} - Creating!"
              else             
                existing_tx.update_attribute(:calc_distributor_fee, distributor_fee)
                update_cause_balances(existing_tx.attributes.with_indifferent_access)

                puts "Added fee #{distributor_fee} to #{existing_tx.id}"
              end
            end
          end
        end
      end
    end         
    
    puts "STEP 3"
    sql = CauseTransaction.query_step3
    
    # Total Cause Balances
    Rake::Task["db:total_cause_balances"].invoke   
  end
  
  task :total_cause_balances => :environment do
    #ActiveRecord::Base.establish_connection(:production).connection unless Rails.env.production?    
    ActiveRecord::Base.connection.execute('UPDATE cause_balances SET total=jan+feb+mar+apr+may+jun+jul+aug+sep+oct+nov+dec')
  end
  
  desc "Compute total"
  task :compute_total => :environment do
    cnt = 1
    CauseBalance.find_in_batches(:batch_size => 100).each do |balance|
      puts cnt
      cnt += 1
      
      balance.each do |b|      
        if 0 == b.total
          b.update_attribute(:total, b.jan + b.feb + b.mar + b.apr + b.may + b.jun + b.jul + b.aug + b.sep + b.oct + b.nov + b.dec)
        end
      end
    end
  end
end

def update_cause_balances(r)
  unless 0.0 == r[:gross_amount].to_f
    balance = CauseBalance.find_or_create_by!(:partner_id => r[:partner_identifier], 
                                             :cause_id => r[:cause_identifier], 
                                             :year => r[:year], 
                                             :balance_type => CauseBalance::GROSS)
    update_balance(balance, r[:month], r[:gross_amount])
  end
  
  unless 0.0 == r[:discounts_amount].to_f
    balance = CauseBalance.find_or_create_by!(:partner_id => r[:partner_identifier], 
                                             :cause_id => r[:cause_identifier], 
                                             :year => r[:year], 
                                             :balance_type => CauseBalance::DISCOUNT)
    update_balance(balance, r[:month], r[:discounts_amount].to_f)
  end
  
  unless 0.0 == r[:net_amount].to_f
    balance = CauseBalance.find_or_create_by!(:partner_id => r[:partner_identifier], 
                                             :cause_id => r[:cause_identifier], 
                                             :year => r[:year], 
                                             :balance_type => CauseBalance::NET)
    update_balance(balance, r[:month], r[:net_amount].to_f)
  end
  
  unless 0.0 == r[:calc_kula_fee].to_f
    balance = CauseBalance.find_or_create_by!(:partner_id => r[:partner_identifier], 
                                             :cause_id => r[:cause_identifier], 
                                             :year => r[:year], 
                                             :balance_type => CauseBalance::KULA_FEE)
    update_balance(balance, r[:month], r[:calc_kula_fee])
  end

  unless 0.0 == r[:calc_foundation_fee].to_f 
    balance = CauseBalance.find_or_create_by!(:partner_id => r[:partner_identifier], 
                                             :cause_id => r[:cause_identifier], 
                                             :year => r[:year], 
                                             :balance_type => CauseBalance::FOUNDATION_FEE)
    update_balance(balance, r[:month], r[:calc_foundation_fee])
  end

  unless 0.0 == r[:calc_distributor_fee].to_f
    balance = CauseBalance.find_or_create_by!(:partner_id => r[:partner_identifier], 
                                             :cause_id => r[:cause_identifier], 
                                             :year => r[:year], 
                                             :balance_type => CauseBalance::DISTRIBUTOR_FEE)
    update_balance(balance, r[:month], r[:calc_distributor_fee])
  end

  unless 0.0 == r[:calc_credit_card_fee].to_f
    balance = CauseBalance.find_or_create_by!(:partner_id => r[:partner_identifier], 
                                             :cause_id => r[:cause_identifier], 
                                             :year => r[:year], 
                                             :balance_type => CauseBalance::CREDIT_CARD_FEE)
    update_balance(balance, r[:month], r[:calc_credit_card_fee])
  end
  
  unless 0.0 == r[:donee_amount]
    balance = CauseBalance.find_or_create_by!(:partner_id => r[:partner_identifier], 
                                             :cause_id => r[:cause_identifier], 
                                             :year => r[:year], 
                                             :balance_type => CauseBalance::DONEE_AMOUNT)
    update_balance(balance, r[:month], r[:donee_amount].to_f)  
  end
end

def clear_balances(b, current_date, latest_date)
  for month in 1..12 do
    test_date = Date.parse("#{b.year}-#{month.to_s.rjust(2, '0')}-01")
    
    if (current_date..latest_date).include? test_date
      case month
      when 1
        b.update_attribute(:jan, 0)
      when 2
        b.update_attribute(:feb, 0)
      when 3
        b.update_attribute(:mar, 0)
      when 4
        b.update_attribute(:apr, 0)
      when 5
        b.update_attribute(:may, 0)
      when 6
        b.update_attribute(:jun, 0)
      when 7
        b.update_attribute(:jul, 0)
      when 8
        b.update_attribute(:aug, 0)
      when 9
        b.update_attribute(:sep, 0)
      when 10
        b.update_attribute(:oct, 0)
      when 11
        b.update_attribute(:nov, 0)
      when 12
        b.update_attribute(:dec, 0)
      else
        raise "Invalid month #{month}"
      end                          
    end
  end
  
  b.update_attribute(:total, b.jan + b.feb + b.mar + b.apr + b.may + b.jun + b.jul + b.aug + b.sep + b.oct + b.nov + b.dec)
end

def update_balance(balance, month, amount)
  #puts "Updating #{balance.inspect} on #{month} for #{amount}"
  case month
  when 1
    balance.update_attribute(:jan, balance.jan + amount)
  when 2
    balance.update_attribute(:feb, balance.feb + amount)
  when 3
    balance.update_attribute(:mar, balance.mar + amount)
  when 4
    balance.update_attribute(:apr, balance.apr + amount)
  when 5
    balance.update_attribute(:may, balance.may + amount)
  when 6
    balance.update_attribute(:jun, balance.jun + amount)
  when 7
    balance.update_attribute(:jul, balance.jul + amount)
  when 8
    balance.update_attribute(:aug, balance.aug + amount)
  when 9
    balance.update_attribute(:sep, balance.sep + amount)
  when 10
    balance.update_attribute(:oct, balance.oct + amount)
  when 11
    balance.update_attribute(:nov, balance.nov + amount)
  when 12
    balance.update_attribute(:dec, balance.dec + amount)
  else
    raise "Invalid month #{month}"
  end                          
end

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
  
  # After import transactions, reconstruct CauseBalances by going through the table
  desc "Cause balances from transactions"
  task :cause_balances_from_tx => :environment do
    ActiveRecord::Base.establish_connection(:production).connection unless Rails.env.production?
    puts "Connection established; #{CauseTransaction.count} transactions"
  
    CauseTransaction.find_in_batches(:batch_size => 100) do |group|
      group.each do |tx|
        next if tx[:cause_id].nil? or tx[:partner_id].nil?
        
        puts "Updating #{tx.inspect}"
        update_cause_balances(tx.attributes.with_indifferent_access)
      end
    end  
  end
  
  desc "Import transactions"
  task :import_transactions => :environment do 
    # Read from read-only replica (or our ghetto writeable copy), copy data to postgres reporting db
    #  In the process: calculate fees and write those alongside Kula's calculations              
    asset = Rails.application.assets.find_asset('transaction-query.sql')
    resolved_fname = asset.pathname.to_s unless asset.nil?
    
    unless !asset.nil? and File.exists?(resolved_fname)
      puts "Cannot find transaction query file: transaction-query.sql"
      
      next
    end
=begin
0  distributor 
1  transaction_id  
2  partner_id  
3  month( bt.created)  
4  year( bt.created) 
5  Gross contribution Amount 
6  Discounts Amount  
7  Net amount ($)  
8  Kula/Foundation fees ($)  
9  Donee amount ($)  
10 name  
11 address1  
12 address2  
13 address3  
14 city  
15 region  
16 postal_code 
17 Country 
18 Mailing Address 
19 Mailing City  
20 Mailing State 
21 Mailing Postal Code 
22 Cause type  
23 Organization email  
24 Organization phone  
25 Organization fax  
26 Tax ID  
27 Has ACH Information 
28 site_url  
29 logo_url  
30 latitude  
31 longitude 
32 mission 
33 Cause ID
=end
    
    sql_base = IO.read(resolved_fname)
    
    ActiveRecord::Base.establish_connection(:test_dev).connection unless Rails.env.test_dev?

    current_date = ActiveRecord::Base.connection.execute('SELECT DISTINCT DATE(created) FROM balance_transactions ORDER BY created LIMIT 1').first[0].beginning_of_month
    latest_date = ActiveRecord::Base.connection.execute('SELECT DISTINCT DATE(created) FROM balance_transactions ORDER BY created DESC LIMIT 1').first[0].beginning_of_month
    
    puts "Reading transactions from #{current_date.to_s} to #{latest_date.to_s}"
    BATCH_SIZE = 100
    
    ActiveRecord::Base.establish_connection(:production).connection
    CauseTransaction.delete_all
    Payment.delete_all
    Adjustment.delete_all
    CauseBalance.delete_all
        
    while current_date <= latest_date do
      start_date = current_date.to_s
      end_date = current_date.end_of_month.to_s
      
      puts "Processing #{start_date}"
      
      # fill in dates
      sql = sql_base.gsub('##START_DATE', "'#{start_date}'").gsub('##END_DATE', "'#{end_date}'")
      
      ActiveRecord::Base.establish_connection(:test_dev).connection unless Rails.env.test_dev?
      
      puts "Reading transactions from test_dev..."
      transactions = ActiveRecord::Base.connection.execute(sql)
      puts "Read #{transactions.count} transactions"

      # Now point to postgres
      ActiveRecord::Base.establish_connection(:production).connection
      
      existing_causes = Cause.all.map(&:id) if existing_causes.nil?
      puts "#{existing_causes.count} causes"

=begin
      puts "Clearing balances"
      balances = CauseBalance.transactional.where(:year => current_date.year)
      case current_date.month
      when 1
        balances.update_all(:jan => 0.0)
      when 2
        balances.update_all(:feb => 0.0)
      when 3
        balances.update_all(:mar => 0.0)
      when 4
        balances.update_all(:apr => 0.0)
      when 5
        balances.update_all(:may => 0.0)
      when 6
        balances.update_all(:jun => 0.0)
      when 7
        balances.update_all(:jul => 0.0)
      when 8
        balances.update_all(:aug => 0.0)
      when 9
        balances.update_all(:sep => 0.0)
      when 10
        balances.update_all(:oct => 0.0)
      when 11
        balances.update_all(:nov => 0.0)
      when 12
        balances.update_all(:dec => 0.0)
      end
=end            
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
        
        # create Cause if not present
        cid = tx[33].to_i
        
        if existing_causes.include?(cid)
          cause = Cause.find(cid)
        else
          puts "Creating cause #{cid}: #{tx[10]}"
          
          # Not transactional, because this should be very infrequent
          cause = Cause.create!(:cause_identifier => cid,
                                :name => tx[10],
                                :cause_type => tx[22].to_i,
                                :has_ach_info => 1 == tx[27].to_i,
                                :email => tx[23],
                                :phone => tx[24],
                                :fax => tx[25],
                                :tax_id => tx[26],
                                :address_1 => tx[11],
                                :address_2 => tx[12],
                                :address_3 => tx[13],
                                :city => tx[14],
                                :region => tx[15],
                                :country => tx[17],
                                :postal_code => tx[16],
                                :mailing_address => tx[18],
                                :mailing_city => tx[19],
                                :mailing_state => tx[20],
                                :mailing_postal_code => tx[21],
                                :site_url => tx[28],
                                :logo_url => tx[29],
                                :latitude => tx[30].to_f,
                                :longitude => tx[31].to_f,
                                :mission => tx[32])
          existing_causes.push(cid)
        end
        
        partner_id = tx[2].to_i
        dist_id = tx[0].to_i
        dist_id = nil if 0 == dist_id
        
        month = tx[3].to_i
        year = tx[4].to_i
        
        partner = Partner.find(partner_id)
        if partner.nil?
          puts "Could not find partner #{partner_id}"
        else
          fee = partner.current_kula_rate(dist_id, Date.parse("#{year}-#{month}-01"))
          if fee.nil? and !dist_id.nil?
            # If unknown distributor, add in a 0 fee entry
            fee = partner.kula_fees.create(:distributor_identifier => dist_id, 
                                           :distributor_rate => 0, 
                                           :us_charity_rate => 0.1, 
                                           :us_charity_kf_rate => 0.025, 
                                           :us_school_rate => 0.1, 
                                           :us_school_kf_rate => 0.025, 
                                           :intl_charity_rate => 0.1, 
                                           :intl_charity_kf_rate => 0.025)
            puts "Added previously unknown distributor: #{dist_id}"
          end
          
          if fee.nil?
            puts "Could not find fee for cause #{cause.cause_identifier} P=#{partner_id} D=#{dist_id}, C=#{cause.name} School? #{cause.school?} Intl? #{cause.international?} Date:#{month}/#{year}"
          else
            gross = tx[5].to_f
            
            if cause.school?
              total_rate = fee.us_school_rate + fee.us_school_kf_rate
              total_fee = total_rate * gross
              
              kula_fee = 0 == total_rate ? 0 : fee.us_school_rate / total_rate * total_fee
              foundation_fee = total_fee - kula_fee
            else
              total_rate = cause.international? ? fee.intl_charity_rate + fee.intl_charity_kf_rate : fee.us_charity_rate + fee.us_charity_kf_rate
              total_fee = total_rate * gross
              
              if 0 == total_rate
                kula_fee = 0
              else
                kula_fee = (cause.international? ? fee.intl_charity_rate / total_rate : fee.us_charity_rate / total_rate) * total_fee 
              end
              
              foundation_fee = total_fee - kula_fee
            end
            
            distributor_fee = dist_id.nil? ? 0 : fee.distributor_rate * gross
            
            records.push({:transaction_identifier => tx[1].to_i,
                          :partner_identifier => tx[2].to_i,
                          :cause_identifier => cause.cause_identifier,
                          :month => month,
                          :year => year,
                          :gross_amount => gross,
                          :net_amount => tx[7].to_f,
                          :donee_amount => tx[9].to_f,
                          :discounts_amount => tx[6].to_f,
                          :fees_amount => tx[8].to_f,
                          :calc_kula_fee => kula_fee,
                          :calc_foundation_fee => foundation_fee,
                          :calc_distributor_fee => distributor_fee})          
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
    
    # Total Cause Balances
    Rake::Task["db:total_cause_balances"].invoke   
  end

  desc "Import transactions"
  task :stepwise_import_transactions, [:partner_id] => :environment do |t, args|
    # Read from read-only replica (or our ghetto writeable copy), copy data to postgres reporting db
    #  In the process: calculate fees and write those alongside Kula's calculations            
    
    # Permissions issue using Sprockets on elastic beanstalk  
=begin
    asset = Rails.application.assets.find_asset('transaction-query-step1.sql')
    resolved_fname = asset.pathname.to_s unless asset.nil?
    
    unless !asset.nil? and File.exists?(resolved_fname)
      puts "Cannot find transaction query file: transaction-query-step1.sql"
      
      next
    end

    sql_base = IO.read(resolved_fname)
=end    
    #ActiveRecord::Base.establish_connection(:development).connection unless Rails.env.test_dev?
    sql_base = CauseTransaction.query_step1
    
    current_date = Date.parse(ActiveRecord::Base.connection.execute('SELECT DISTINCT created FROM replicated_balance_transactions ORDER BY created LIMIT 1').first['created']).beginning_of_month
    latest_date = Date.parse(ActiveRecord::Base.connection.execute('SELECT DISTINCT created FROM replicated_balance_transactions ORDER BY created DESC LIMIT 1').first['created']).beginning_of_month
    
    puts "Reading transactions from #{current_date.to_s} to #{latest_date.to_s}"
    BATCH_SIZE = 100
    
    partner_id = args[:partner_id].to_i
    
    # Delete everything if all partners
    if 0 == partner_id 
      CauseTransaction.delete_all
      Payment.delete_all
      Adjustment.delete_all
      CauseBalance.delete_all
    else
      CauseTransaction.where(:partner_identifier => partner_id).delete_all
      
      Batch.where(:partner_id => partner_id).each do |batch|
        batch.payments.delete_all
        batch.adjustments.delete_all
      end
      
      CauseBalance.where(:partner_id => partner_id).delete_all
    end
        
    while current_date <= latest_date do
      start_date = current_date.to_s
      end_date = current_date.end_of_month.to_s
      
      puts "Processing #{start_date}"
      
      # fill in dates
      sql = sql_base.gsub('##START_DATE', "'#{start_date}'").gsub('##END_DATE', "'#{end_date}'")
      if 0 == partner_id
        sql.gsub!('##PARTNER_CLAUSE', '')
      else
        sql.gsub!('##PARTNER_CLAUSE', " AND bt.partner_id = #{partner_id}")
      end
      
      #ActiveRecord::Base.establish_connection(:test_dev).connection unless Rails.env.test_dev?
      
      puts "Reading transactions from source..."
      transactions = ActiveRecord::Base.connection.execute(sql)
      puts "Read #{transactions.count} transactions"

      # Now point to postgres
      #ActiveRecord::Base.establish_connection(:production).connection
      
      existing_causes = Cause.all.map(&:id) if existing_causes.nil?
      puts "#{existing_causes.count} causes"

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
        puts "Missing cause #{cid}" unless existing_causes.include?(cid)
        
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
                          :calc_distributor_fee => 0})          
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
    
    # Total Cause Balances
    Rake::Task["db:total_cause_balances"].invoke   
  end
  
  task :total_cause_balances => :environment do
    #ActiveRecord::Base.establish_connection(:production).connection unless Rails.env.production?    
    ActiveRecord::Base.connection.execute('UPDATE cause_balances SET total=jan+feb+mar+apr+may+jun+jul+aug+sep+oct+nov+dec')
  end
  
  desc "Read from kula_data to our db [fname, after date yyyy-mm-dd; ignores day]"
  task :kula_import, [:partner, :year, :month] => :environment do |t, args|
    # fname = args.has_key?(:fname) ? args[:fname] : '/Users/jeff/Documents/KulaTransactions.csv'
    cnt = 1
    row = 1
    
    base = "SELECT * FROM #{Rails.configuration.database_configuration[Rails.env]['database']}.transactions_by_cause"
    delete = "DELETE FROM #{Rails.configuration.database_configuration[Rails.env]['database']}.transactions_by_cause"
    
    where_clause = 0 == args.count ? "" : " WHERE"
    previous = false
    
    if args.has_key?(:partner)
      where_clause += " (partner_id = #{args[:partner]})"
      previous = true
    end
    
    if args.has_key?(:year)
      where_clause += " AND " if previous   
      where_clause += " (year = #{args[:year]})"
      previous = true
    end
    
    if args.has_key?(:month)
      where_clause += " AND " if previous   
      where_clause += " (month = #{args[:month]})"
      previous = true      
    end
=begin
0 partner_id
1 month
2 year
3 Gross_Contribution_Amount
4 Discounts_Amount
5 Net_amount
6 Kula_And_Foundation_fees
7 Donee_amount
8 Organization_name
9 Organization_name_for_address
10 Address1_2_3
11 City_State_Zip
12 Country
13 Type
14 Organization_Contact_First_Name
15 Organization_Contact_Last_Name
16 Organization_Contact_Email
17 Organization_Email
18 Tax_ID
19 Has_ACH_Information
20 Cause_ID         
=end
    #CSV.foreach(fname, :col_sep => ';') do |line|

    # This is somewhat dangerous -- if it doesn't check for a where_clause it would delete the whole table (reconstructable, at least)
    ActiveRecord::Base.connection.execute(delete + where_clause) unless where_clause.blank?
    
    records = ActiveRecord::Base.connection.execute(sql + where_clause)
    records.each do |line|
      begin
        #if first
        #  first = false
        #  next
        #end
                
        partner_id = line[0].to_i
        if Partner.find_by_partner_identifier(partner_id).nil?
          Partner.create!(:partner_id => line[0], :name => "Partner #{partner_id}", :display_name => "Partner #{partner_id}", :domain => 'unknown.com')
        end
        
        cause_id = line[20].to_i
        if Cause.find_by_cause_identifier(cause_id).nil?
          email = line[17].strip
          if 'NULL' == email
            email = line[16].strip
            if 'NULL' == email
              email = "unknown-#{cnt}@somewhere.com"
              cnt += 1
            end
          end
          
          unless email.blank?
            email = email.chomp('.')
          end
          
          fields = line[10].split(/,/)
          address1 = fields[0].nil? ? nil : fields[0].strip
          address2 = fields[1].nil? ? nil : fields[1].strip
          address3 = fields[2].nil? ? nil : fields[2].strip
          
          if line[11] =~ /^(.+?), (.+?) (\d+)/
            city = $1
            region = $2
            postal_code = $3
          end
          
          cause_type = 'School' == line[13].strip ? Cause::SCHOOL_TYPE : Cause::CAUSE_TYPE
          
          cause = Cause.new(:cause_id => line[20], :cause_type => cause_type, :name => line[8].strip, :has_ach_info => '1' == line[19].strip,
                            :email => email, :tax_id => line[18].strip, :address_1 => address1, :address_2 => address2, :address_3 => address3,
                            :city => city, :region => region, :postal_code => postal_code, :country => line[12].strip)
          unless cause.valid?
            cause.email = nil
            puts line
            puts cause.errors.full_messages.to_sentence
          end
          
          cause.save!
        end
        
        row += 1
        if 0 == row % 100
          puts row
        end       
        
        # financials
        gross = line[3].to_f
        discount = line[4].to_f
        net = line[5].to_f
        fees = line[6].to_f
        donee = line[7].to_f

        if gross > 0    
          balance = CauseBalance.where(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::GROSS).first
          if balance.nil?
            balance = CauseBalance.create(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::GROSS)
          end
          
          update_balance(balance, line[1].to_i, gross)
        end

        if discount > 0    
          balance = CauseBalance.where(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::DISCOUNT).first
          if balance.nil?
            balance = CauseBalance.create(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::DISCOUNT)
          end
          
          update_balance(balance, line[1].to_i, discount)
        end

        if net > 0    
          balance = CauseBalance.where(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::NET).first
          if balance.nil?
            balance = CauseBalance.create(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::NET)
          end
          
          update_balance(balance, line[1].to_i, net)
        end

        if fees > 0    
          balance = CauseBalance.where(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::FEE).first
          if balance.nil?
            balance = CauseBalance.create(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::FEE)
          end
          
          update_balance(balance, line[1].to_i, fees)
        end
        
        if donee > 0    
          balance = CauseBalance.where(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::DONEE_AMOUNT).first
          if balance.nil?
            balance = CauseBalance.create(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::DONEE_AMOUNT)
          end
          
          update_balance(balance, line[1].to_i, donee)
        end    
      rescue Exception => ex
        puts ex.inspect  
      end
    end  
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

  desc "Migrate Causes from replica to production"
  task :migrate_causes => :environment do 
    ActiveRecord::Base.establish_connection(:test_dev).connection unless Rails.env.test_dev?
    
    puts "Fetching records"
    sql = 'select * from causes where cause_id in (select distinct cause_id from balance_transactions)'
    records = ActiveRecord::Base.connection.execute(sql)
 
    puts "Got #{records.count} records"
    ActiveRecord::Base.establish_connection(:production).connection
    existing = Cause.all.map(&:cause_identifier)
    
    cnt = 1
    causes = []
    records.each do |row|
      if 0 == cnt % 100
        puts "#{cnt} Uploading..."
        ActiveRecord::Base.transaction do
          begin
            causes.each do |params|
              Cause.create!(params) 
            end
            
            puts "#{causes.count} successfully uploaded"
            
            causes = []
          rescue ActiveRecord::Rollback => ex
            puts "Rollback! #{ex.inspect}"
          end
        end
      end
      
      cnt += 1
      
      next if existing.include?(row[0].to_i)
      
      causes.push({ :cause_identifier => row[0].to_i,
                    :name => row[10],
                    :cause_type => row[7],
                    :has_ach_info => 1 == row[8].to_i,
                    :email => row[20],
                    :phone => row[21],
                    :fax => row[23],
                    :tax_id => row[6],
                    :address_1 => row[27],
                    :address_2 => row[29],
                    :address_3 => row[30],
                    :city => row[33],
                    :region => row[35],
                    :country => row[37],
                    :postal_code => row[38],
                    :mailing_address => row[40],
                    :mailing_city => row[41],
                    :mailing_state => row[42],
                    :mailing_postal_code => row[43],
                    :site_url => row[44],
                    :logo_url => row[46],
                    :mission => row[24] })
    end

    unless causes.empty?   
      puts "Writing remainder (#{causes.count})"
      ActiveRecord::Base.transaction do
        begin
          causes.each do |params|
            Cause.create!(params) 
          end
          
          puts "#{causes.count} successfully uploaded"
          
          causes = []
        rescue ActiveRecord::Rollback => ex
          puts "Rollback! #{ex.inspect}"
        end
      end
    end
    
    puts "Wrote #{cnt - 1} records"
  end
   
  desc "Upload Causes from Replica"
  task :upload_causes => :environment do
    unless Rails.env.production?
      puts "Must run in production"
      next
    end

    cnt = 1
    CSV.foreach('fish.csv', headers: false) do |row|
      Cause.create!(:cause_identifier => row[0],
                    :name => row[10],
                    :cause_type => row[7],
                    :has_ach_info => 1 == row[8].to_i,
                    :email => row[20],
                    :phone => row[21],
                    :fax => row[23],
                    :tax_id => row[6],
                    :address_1 => row[27],
                    :address_2 => row[29],
                    :address_3 => row[30],
                    :city => row[33],
                    :region => row[35],
                    :country => row[37],
                    :postal_code => row[38],
                    :mailing_address => row[40],
                    :mailing_city => row[41],
                    :mailing_state => row[42],
                    :mailing_postal_code => row[43],
                    :site_url => row[44],
                    :logo_url => row[46],
                    :mission => row[24])
      puts cnt if 0 == cnt % 100
      cnt += 1
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
  
  unless 0.0 == r[:calc_kula_fee].to_f +  r[:calc_foundation_fee].to_f + r[:calc_distributor_fee].to_f
    balance = CauseBalance.find_or_create_by!(:partner_id => r[:partner_identifier], 
                                             :cause_id => r[:cause_identifier], 
                                             :year => r[:year], 
                                             :balance_type => CauseBalance::FEE)
    update_balance(balance, r[:month], r[:calc_kula_fee] + r[:calc_foundation_fee] + r[:calc_distributor_fee])
  end
  
  unless 0.0 == r[:donee_amount]
    balance = CauseBalance.find_or_create_by!(:partner_id => r[:partner_identifier], 
                                             :cause_id => r[:cause_identifier], 
                                             :year => r[:year], 
                                             :balance_type => CauseBalance::DONEE_AMOUNT)
    update_balance(balance, r[:month], r[:donee_amount].to_f)  
  end
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

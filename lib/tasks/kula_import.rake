namespace :db do
  desc "Import payments"
  task :import_payments => :environment do
    sql = "SELECT *, partner_id,  MONTH(payments.date), YEAR(payments.date)  FROM #{Rails.configuration.database_configuration[Rails.env]['database']}.payments" + 
          " join #{Rails.configuration.database_configuration[Rails.env]['database']}.batches on  batches.id = payments.batch_id ;"
    
    records = ActiveRecord::Base.connection.execute(sql)
    records.each do |line|
      begin                
        row += 1
        if 0 == row % 100
          puts row
        end       
       
        partner_id = line[13].to_i        
        cause_id = line[11].to_i
        month = line[21].to_i
        payment = line[3].to_f

        if payment > 0    
          balance = CauseBalance.where(:partner_id => partner_id, :cause_id => cause_id, :year => line[22].to_i, :balance_type => CauseBalance::PAYMENT).first
          if balance.nil?
            balance = CauseBalance.create(:partner_id => partner_id, :cause_id => cause_id, :year => line[22].to_i, :balance_type => CauseBalance::PAYMENT)
          end
          
          # Put in payments as negative
          update_balance(balance, month, -1 * payment)
        end
      rescue Exception => ex
        puts ex.inspect  
      end
    end  
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
end

def update_balance(balance, month, amount)
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
    raise "Invalid month #{line[1]}"
  end                          
end
=begin
0             1      2       3                          4                   5             6                          7
partner_id;"month";"year";"Gross_Contribution_Amount";"Discounts_Amount";"Net_amount";"Kula_And_Foundation_fees";"Donee_amount";
8                      9                              10              11              12       13      14   
"Organization_name";"Organization_name_for_address";"Address1_2_3";"City_State_Zip";"Country";"Type";"Organization_Contact_First_Name";
15                                 16                           17                    18      19                    20
"Organization_Contact_Last_Name";"Organization_Contact_Email";"Organization_Email";"Tax_ID";"Has_ACH_Information";"Cause_ID"         
=end

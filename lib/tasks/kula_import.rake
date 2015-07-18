namespace :db do
  desc "Read from kula_data to our db [fname, after date yyyy-mm-dd; ignores day]"
  task :kula_import, [:fname, :after_date] => :environment do |t, args|
    fname = args.has_key?(:fname) ? args[:fname] : '/Users/jeff/Documents/KulaTransactions.csv'
    if args.has_key?(:after_date)
      dt = Date.parse(args[:after_date])
      month = dt.month
      year = dt.year      
    end
        
    admin = User.where("role = ?", User::ADMIN).first
    first = true
    cnt = 1
    row = 1
    
    CSV.foreach(fname, :col_sep => ';') do |line|
      begin
        if first
          first = false
          next
        end
        
        # Filter by month/year, if given
        next unless year.nil? or ((year == line[2].to_i) and (month == line[1].to_i))
        
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
          balance = CauseBalance.where(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::FEES).first
          if balance.nil?
            balance = CauseBalance.create(:partner_id => partner_id, :cause_id => cause_id, :year => line[2].to_i, :balance_type => CauseBalance::FEES)
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

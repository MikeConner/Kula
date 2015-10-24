namespace :db do
  desc "Close out a balance transaction year"
  task :close_year, [:year] => :environment do |t, args|
    unless args.has_key?(:year)
      puts "Must provide a year: db:close_year[2012]"
      next
    end
    
    closing_year = args[:year].to_i
    next_year = closing_year + 1
    
    CauseBalance.where(:year => closing_year).find_in_batches(:batch_size => 100) do |batch|  
      inserts = []
      
      puts "Found block"
      
      batch.each do |balance|      
        rollover = balance.prior_year_rollover + balance.total
        keys = {:year => next_year, :partner_id => balance.partner_id, :cause_id => balance.cause_id, :balance_type => balance.balance_type}
        
        next_balance = CauseBalance.where(keys).first
        
        if next_balance.nil?
          inserts.push(keys.update(:prior_year_rollover => rollover))
        else
          next_balance.update_attribute(:prior_year_rollover, rollover)
        end
      end
      
      unless inserts.empty?
        puts "Inserting block of #{inserts.count}"
        
        ActiveRecord::Base.transaction do  
          inserts.each do |data|
            CauseBalance.create!(data)
          end           
        end  
      end            
    end
  end
end

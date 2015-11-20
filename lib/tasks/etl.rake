namespace :etl do
  #causes are full-replicate as of today 10/2015
  task :causes_replicate => :environment do
    start_time = Time.now
    etl_filename = 'etl/causes.etl'
    script_content = IO.read(etl_filename)
    job_definition = Kiba.parse(script_content, etl_filename)

    ENV['BATCH_SIZE'] = "50000"
    ENV['LAST_CAUSE_ID'] = ""
    config = YAML.load(IO.read('config/database.yml'))
    @mysql = Mysql2::Client.new(config['replica'])
    rowCount = @mysql.query('select count(*) as cnt from causes')

    num_rows = rowCount.first['cnt'].to_i

    puts "--------------------------------------------"
    puts "Clearing Replicated Table"
    puts "--------------------------------------------"

    ActiveRecord::Base.establish_connection(Rails.env).connection
    ActiveRecord::Base.connection.execute("DELETE FROM causes;")

    puts "Table Clear"
    puts "--------------------------------------------"
    puts "#{num_rows} total rows"

    blocks = num_rows / ENV['BATCH_SIZE'].to_i
    remainder = num_rows % ENV['BATCH_SIZE'].to_i

    blocks.times do
      Kiba.run(job_definition)
      ENV['LAST_CAUSE_ID'] = ActiveRecord::Base.connection.execute("SELECT MAX(cause_id) as max FROM causes").first['max']
    end
    ENV['BATCH_SIZE'] = remainder.to_s
    Kiba.run(job_definition)


    end_time = Time.now
    duration_in_minutes = (end_time - start_time)/60
    puts ""
    puts "*** End CAUSES REPLICATION #{end_time}***"
    puts "*** Duration (min): #{duration_in_minutes.round(2)}"
  end

  #Users are full replicate as of today 10/2015
  task :users_replicate => :environment do
    start_time = Time.now
    etl_filename = 'etl/users.etl'
    script_content = IO.read(etl_filename)
    job_definition = Kiba.parse(script_content, etl_filename)

    ENV['BATCH_SIZE'] = "50000"
    ENV['LAST_USER_ID'] = ""
    config = YAML.load(IO.read('config/database.yml'))
    @mysql = Mysql2::Client.new(config['replica'])
    rowCount = @mysql.query('select count(*) as cnt from users')
    ActiveRecord::Base.establish_connection(Rails.env).connection
    ActiveRecord::Base.connection.execute("DELETE FROM replicated_users;")

    num_rows = rowCount.first['cnt'].to_i

    puts "--------------------------------------------"
    puts "Clearing Replicated Table"
    puts "--------------------------------------------"

    puts "Table Clear"
    puts "--------------------------------------------"
    puts "#{num_rows} total rows"

    blocks = num_rows / ENV['BATCH_SIZE'].to_i
    remainder = num_rows % ENV['BATCH_SIZE'].to_i

    blocks.times do
      Kiba.run(job_definition)
      ENV['LAST_USER_ID'] = ActiveRecord::Base.connection.execute("SELECT MAX(user_id) as max FROM replicated_users").first['max']
    end
    ENV['BATCH_SIZE'] = remainder.to_s
    Kiba.run(job_definition)

    end_time = Time.now
    duration_in_minutes = (end_time - start_time)/60
    puts ""
    puts "*** End USERS REPLICATION #{end_time}***"
    puts "*** Duration (min): #{duration_in_minutes.round(2)}"
  end

  #balances are full replicate as of today 10/2015
  task :balances_replicate => :environment do
    #TODO We will update this to store possibly in a different format - For now we'll do a full replication - should be fast enough no batching
    start_time = Time.now
    etl_filename = 'etl/balances.etl'
    script_content = IO.read(etl_filename)
    job_definition = Kiba.parse(script_content, etl_filename)
    Kiba.run(job_definition)
  end

  task :partner_user_map_replicate => :environment do
    etl_filename = 'etl/partner_user_map.etl'
    script_content = IO.read(etl_filename)
    # pass etl_filename to line numbers on errors
    job_definition = Kiba.parse(script_content, etl_filename)
    Kiba.run(job_definition)
  end

  #batching AND incremental (later, very quick right now)
  task :partner_codes_replicate => :environment do
    etl_filename = 'etl/partner_codes.etl'
    script_content = IO.read(etl_filename)
    # pass etl_filename to line numbers on errors
    job_definition = Kiba.parse(script_content, etl_filename)
    Kiba.run(job_definition)
  end

  # Assumption that id is auto-incrementing
  task :burn_links_full_replicate => :environment do
    start_time = Time.now
    etl_filename = 'etl/burn_links.etl'
    script_content = IO.read(etl_filename)
    job_definition = Kiba.parse(script_content, etl_filename)

    ENV['BATCH_SIZE'] = "50000"
    ENV['LAST_BURN_ID'] = ""
    config = YAML.load(IO.read('config/database.yml'))
    @mysql = Mysql2::Client.new(config['replica'])
    rowCount = @mysql.query('select count(*) as cnt from burn_links')

    num_rows = rowCount.first['cnt'].to_i

    puts "--------------------------------------------"
    puts "Clearing Replicated Table"
    puts "--------------------------------------------"

    ActiveRecord::Base.establish_connection(Rails.env).connection
    ActiveRecord::Base.connection.execute("DELETE FROM replicated_burn_links;")

    puts "Table Clear"
    puts "--------------------------------------------"
    puts "#{num_rows} total rows"

    blocks = num_rows / ENV['BATCH_SIZE'].to_i
    remainder = num_rows % ENV['BATCH_SIZE'].to_i

    blocks.times do
      Kiba.run(job_definition)
      ENV['LAST_BURN_ID'] = ActiveRecord::Base.connection.execute("SELECT MAX(burn_link_id) as max FROM replicated_burn_links").first['max']
    end
    ENV['BATCH_SIZE'] = remainder.to_s #TODO: JEFF, I Changed this from [ENF'LAST_ID'] to BATCH_SIZE... check my logic
    Kiba.run(job_definition)

    end_time = Time.now
    duration_in_minutes = (end_time - start_time)/60
    puts ""
    puts "*** End CAUSES REPLICATION #{end_time}***"
    puts "*** Duration (min): #{duration_in_minutes.round(2)}"
  end

  #this needs to be batched for memory Usage
  #this needs to have incrementals as well
  task :balance_transactions_full_replicate => :environment do
    start_time = Time.now
    etl_filename = 'etl/balance_transactions.etl'
    script_content = IO.read(etl_filename)
    # pass etl_filename to line numbers on errors
    job_definition = Kiba.parse(script_content, etl_filename)

    ENV['BATCH_SIZE'] = "50000"
    ENV['LAST_TXN_ID'] = "0"
    config = YAML.load(IO.read('config/database.yml'))
    @mysql = Mysql2::Client.new(config['replica'])
    rowCount = @mysql.query('select count(*) as cnt from balance_transactions')
    num_rows = rowCount.first['cnt'].to_i

    puts "--------------------------------------------"
    puts "Clearing Replicated Table"
    puts "--------------------------------------------"

    ActiveRecord::Base.establish_connection(Rails.env).connection
    ActiveRecord::Base.connection.execute("DELETE FROM replicated_balance_transactions;")

    puts "Table Clear"
    puts "--------------------------------------------"
    puts "#{num_rows} total rows"

    blocks = num_rows / ENV['BATCH_SIZE'].to_i
    remainder = num_rows % ENV['BATCH_SIZE'].to_i
    blocks.times do
      Kiba.run(job_definition)
      ENV['LAST_TXN_ID'] = ActiveRecord::Base.connection.execute("SELECT max(transaction_id) as max from replicated_balance_transactions").first['max']
    end
    ENV['BATCH_SIZE'] = remainder.to_s
    Kiba.run(job_definition)

    end_time = Time.now
    duration_in_minutes = (end_time - start_time)/60
    puts ""
    puts "*** End BALANCE TRANSACTION FULL REPLICATION #{end_time}***"
    puts "*** Duration (min): #{duration_in_minutes.round(2)}"
  end

  task :partner_transactions_full_replicate => :environment do
    start_time = Time.now
    etl_filename = 'etl/partner_transactions.etl'
    script_content = IO.read(etl_filename)
    # pass etl_filename to line numbers on errors
    job_definition = Kiba.parse(script_content, etl_filename)

    ENV['BATCH_SIZE'] = "50000"
    ENV['LAST_P_TXN_ID'] = "0"
    config = YAML.load(IO.read('config/database.yml'))
    @mysql = Mysql2::Client.new(config['replica'])
    rowCount = @mysql.query('select count(*) as cnt from partner_transaction')
    num_rows = rowCount.first['cnt'].to_i

    puts "--------------------------------------------"
    puts "Clearing Replicated Table"
    puts "--------------------------------------------"

    ActiveRecord::Base.establish_connection(Rails.env).connection
    ActiveRecord::Base.connection.execute("DELETE FROM replicated_partner_transaction;")

    puts "Table Clear"
    puts "--------------------------------------------"
    puts "#{num_rows} total rows"

    blocks = num_rows / ENV['BATCH_SIZE'].to_i
    remainder = num_rows % ENV['BATCH_SIZE'].to_i
    blocks.times do
      Kiba.run(job_definition)
      ENV['LAST_P_TXN_ID'] = ActiveRecord::Base.connection.execute("SELECT max(partner_transaction_id) as max from replicated_partner_transaction").first['max']
    end
    ENV['BATCH_SIZE'] = remainder.to_s
    Kiba.run(job_definition)

    end_time = Time.now
    duration_in_minutes = (end_time - start_time)/60
    puts ""
    puts "*** End PARTNER TRANSACTION FULL REPLICATION #{end_time}***"
    puts "*** Duration (min): #{duration_in_minutes.round(2)}"
  end

  task :balance_transactions_inc_replicate => :environment do
    start_time = Time.now
    etl_filename = 'etl/balance_transactions.etl'
    script_content = IO.read(etl_filename)
    # pass etl_filename to line numbers on errors
    job_definition = Kiba.parse(script_content, etl_filename)

    ENV['BATCH_SIZE'] = "50000"
    ENV['LAST_TXN_ID'] = ""
    config = YAML.load(IO.read('config/database.yml'))
    @mysql = Mysql2::Client.new(config['replica'])

    puts "--------------------------------------------"
    puts "Finding Last Txn ID from last replication"
    puts "--------------------------------------------"

    ActiveRecord::Base.establish_connection(Rails.env).connection
    ENV['LAST_TXN_ID'] = ActiveRecord::Base.connection.execute("SELECT max(transaction_id) as max from replicated_balance_transactions").first['max']

    puts "Last ID: #{ENV['LAST_TXN_ID']}"
    puts "--------------------------------------------"

    rowCount = @mysql.query("select count(*) as cnt from balance_transactions where transaction_id > #{ENV['LAST_TXN_ID']} "  )
    num_rows = rowCount.first['cnt'].to_i

    puts "#{num_rows} total rows"
    puts "--------------------------------------------"

    blocks = num_rows / ENV['BATCH_SIZE'].to_i
    remainder = num_rows % ENV['BATCH_SIZE'].to_i
    blocks.times do
      Kiba.run(job_definition)
      ENV['LAST_TXN_ID'] = ActiveRecord::Base.connection.execute("SELECT max(transaction_id) as max from replicated_balance_transactions").first['max']
    end
    ENV['BATCH_SIZE'] = remainder.to_s
    Kiba.run(job_definition)

    end_time = Time.now
    duration_in_minutes = (end_time - start_time)/60
    puts ""
    puts "*** End BALANCE TRANSACTION FULL REPLICATION #{end_time}***"
    puts "*** Duration (min): #{duration_in_minutes.round(2)}"
  end

  task :burn_links_inc_replicate => :environment do
    start_time = Time.now
    etl_filename = 'etl/burn_links.etl'
    script_content = IO.read(etl_filename)
    job_definition = Kiba.parse(script_content, etl_filename)

    ENV['BATCH_SIZE'] = "50000"
    config = YAML.load(IO.read('config/database.yml'))
    @mysql = Mysql2::Client.new(config['replica'])

    puts "--------------------------------------------"
    puts "Finding Last Burn ID from last replication"
    puts "--------------------------------------------"

    ActiveRecord::Base.establish_connection(Rails.env).connection
    ENV['LAST_BURN_ID'] = ActiveRecord::Base.connection.execute("SELECT MAX(burn_link_id) as max FROM replicated_burn_links").first['max']

    puts "Last ID: #{ENV['LAST_BURN_ID']}"
    puts "--------------------------------------------"

    rowCount = @mysql.query("select count(*) as cnt from burn_links where burn_link_id > #{ENV['LAST_BURN_ID']} "  )
    num_rows = rowCount.first['cnt'].to_i

    puts "#{num_rows} total rows"
    puts "--------------------------------------------"

    blocks = num_rows / ENV['BATCH_SIZE'].to_i
    remainder = num_rows % ENV['BATCH_SIZE'].to_i

    blocks.times do
      Kiba.run(job_definition)
      ENV['LAST_BURN_ID'] = ActiveRecord::Base.connection.execute("SELECT MAX(burn_link_id) as max FROM replicated_burn_links").first['max']
    end
    ENV['BATCH_SIZE'] = remainder.to_s #TODO: JEFF, I Changed this from [ENF'LAST_ID'] to BATCH_SIZE... check my logic
    Kiba.run(job_definition)

    end_time = Time.now
    duration_in_minutes = (end_time - start_time)/60
    puts ""
    puts "*** End BURN LINKS INCREMENTAL REPLICATION #{end_time}***"
    puts "*** Duration (min): #{duration_in_minutes.round(2)}"
  end

  task :partner_transactions_inc_replicate => :environment do
    start_time = Time.now
    etl_filename = 'etl/partner_transactions.etl'
    script_content = IO.read(etl_filename)
    # pass etl_filename to line numbers on errors
    job_definition = Kiba.parse(script_content, etl_filename)

    ENV['BATCH_SIZE'] = "50000"
    ENV['LAST_P_TXN_ID'] = ""
    config = YAML.load(IO.read('config/database.yml'))
    @mysql = Mysql2::Client.new(config['replica'])

    puts "--------------------------------------------"
    puts "Finding Last Txn ID from last replication"
    puts "--------------------------------------------"

    ActiveRecord::Base.establish_connection(Rails.env).connection
    ENV['LAST_P_TXN_ID'] = ActiveRecord::Base.connection.execute("SELECT max(partner_transaction_id) from replicated_partner_transaction").first['max']

    puts "Last ID: #{ENV['LAST_P_TXN_ID']}"
    puts "--------------------------------------------"

    rowCount = @mysql.query("select count(*) as cnt from partner_transaction where partner_transaction_id > #{ENV['LAST_P_TXN_ID']} "  )
    num_rows = rowCount.first['cnt'].to_i

    puts "#{num_rows} total rows"
    puts "--------------------------------------------"

    blocks = num_rows / ENV['BATCH_SIZE'].to_i
    remainder = num_rows % ENV['BATCH_SIZE'].to_i
    blocks.times do
      Kiba.run(job_definition)
      ENV['LAST_P_TXN_ID'] = ActiveRecord::Base.connection.execute("SELECT max(partner_transaction_id) as max from replicated_partner_transaction").first['max']
    end
    ENV['BATCH_SIZE'] = remainder.to_s
    Kiba.run(job_definition)

    end_time = Time.now
    duration_in_minutes = (end_time - start_time)/60
    puts ""
    puts "*** End PARTNER TRANSACTION INC REPLICATION #{end_time}***"
    puts "*** Duration (min): #{duration_in_minutes.round(2)}"
  end

  desc "Replace all tables. Order is important!"
  task :replicate_all do
    Rake::Task["etl:causes_replicate"].invoke
    Rake::Task["etl:users_replicate"].invoke
    Rake::Task["etl:balances_replicate"].invoke
    Rake::Task["etl:partner_user_map_replicate"].invoke
    Rake::Task["etl:partner_codes_replicate"].invoke
#    Rake::Task["etl:burn_links_full_replicate"].invoke
#    Rake::Task["etl:balance_transactions_full_replicate"].invoke
#    Rake::Task["etl:partner_transactions_full_replicate"].invoke
    Rake::Task["etl:balance_transactions_inc_replicate"].invoke
    Rake::Task["etl:burn_links_inc_replicate"].invoke
    Rake::Task["etl:partner_transactions_inc_replicate"].invoke

    Rake::Task["etl:causes_replicate"].reenable
    Rake::Task["etl:users_replicate"].reenable
    Rake::Task["etl:balances_replicate"].reenable
    Rake::Task["etl:partner_user_map_replicate"].reenable
    Rake::Task["etl:partner_codes_replicate"].reenable
#    Rake::Task["etl:burn_links_full_replicate"].reenable
#    Rake::Task["etl:balance_transactions_full_replicate"].reenable
#    Rake::Task["etl:partner_transactions_full_replicate"].reenable
    Rake::Task["etl:balance_transactions_inc_replicate"].reenable
    Rake::Task["etl:burn_links_inc_replicate"].reenable
    Rake::Task["etl:partner_transactions_inc_replicate"].reenable
  end

  # No longer needed?
  task :partner_transaction_fields_replicate => :environment do
    etl_filename = 'etl/partner_transaction_fields.etl'
    script_content = IO.read(etl_filename)
    # pass etl_filename to line numbers on errors
    job_definition = Kiba.parse(script_content, etl_filename)

    puts "no longer used - here for reference.  Stop trying to run me!"
    #Kiba.run(job_definition)
  end
end

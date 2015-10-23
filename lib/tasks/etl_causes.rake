
task :causes_replicate => :environment do
  start_time = Time.now
  etl_filename = 'etl/causes.etl'
  script_content = IO.read(etl_filename)
  # pass etl_filename to line numbers on errors
  job_definition = Kiba.parse(script_content, etl_filename)

  ENV['BATCH_SIZE'] = "50000"
  ENV['LAST_CAUSE_ID'] = ""
  config = YAML.load(IO.read('config/database.yml'))
  @mysql = Mysql2::Client.new(config['replica'])
  rowCount = @mysql.query('select count(*) as cnt from causes')
  ActiveRecord::Base.establish_connection(Rails.env).connection
  ActiveRecord::Base.connection.execute("DELETE FROM causes;")

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
      ENV['LAST_CAUSE_ID'] = ActiveRecord::Base.connection.execute("SELECT MAX(user_id) as max FROM users").first['max']
    end
    ENV['BATCH_SIZE'] = remainder.to_s
    Kiba.run(job_definition)


    end_time = Time.now
    duration_in_minutes = (end_time - start_time)/60
    puts ""
    puts "*** End USERS REPLICATION #{end_time}***"
    puts "*** Duration (min): #{duration_in_minutes.round(2)}"

end

task :balances_replicate => :environment do
  etl_filename = 'etl/balances.etl'
  script_content = IO.read(etl_filename)
  # pass etl_filename to line numbers on errors
  job_definition = Kiba.parse(script_content, etl_filename)
  Kiba.run(job_definition)
end


task :balance_transactions_replicate => :environment do
  etl_filename = 'etl/balance_transactions.etl'
  script_content = IO.read(etl_filename)
  # pass etl_filename to line numbers on errors
  job_definition = Kiba.parse(script_content, etl_filename)
  Kiba.run(job_definition)
end


task :burn_links_replicate => :environment do
  etl_filename = 'etl/burn_links.etl'
  script_content = IO.read(etl_filename)
  # pass etl_filename to line numbers on errors
  job_definition = Kiba.parse(script_content, etl_filename)
  Kiba.run(job_definition)
end



task :partner_codes_replicate => :environment do
  etl_filename = 'etl/partner_codes.etl'
  script_content = IO.read(etl_filename)
  # pass etl_filename to line numbers on errors
  job_definition = Kiba.parse(script_content, etl_filename)
  Kiba.run(job_definition)
end


task :partner_transaction_fields_replicate => :environment do
  etl_filename = 'etl/partner_transaction_fields.etl'
  script_content = IO.read(etl_filename)
  # pass etl_filename to line numbers on errors
  job_definition = Kiba.parse(script_content, etl_filename)
  Kiba.run(job_definition)
end


task :partner_transactions_replicate => :environment do
  etl_filename = 'etl/partner_transactions.etl'
  script_content = IO.read(etl_filename)
  # pass etl_filename to line numbers on errors
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

task :etl => :environment do
  etl_filename = 'etl/causes.etl'
  script_content = IO.read(etl_filename)
  # pass etl_filename to line numbers on errors
  job_definition = Kiba.parse(script_content, etl_filename)
  Kiba.run(job_definition)
end

task :causes_replicate => :environment do
  etl_filename = 'etl/causes.etl'
  script_content = IO.read(etl_filename)
  # pass etl_filename to line numbers on errors
  job_definition = Kiba.parse(script_content, etl_filename)
  Kiba.run(job_definition)
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

task :users_replicate => :environment do
  etl_filename = 'etl/users.etl'
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

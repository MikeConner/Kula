require 'pg'

class BurnLinkDestination
  # connect_url should look like;
  #  mysql://user:pass@localhost/dbname

  def initialize(connect_url)
    @conn = PG.connect(connect_url)
    #TODO - Insert Cause Statement
    @conn.prepare('insert_pg_stmt', 'INSERT INTO replicated_burn_links(
            burn_link_id, burn_balance_transaction_id, earn_balance_transaction_id,
            type, cut_payee_id, amount, cut_percent, cut_amount, matched,
            updated)
    VALUES ($1, $2, $3,
            $4, $5, $6, $7, $8, $9,
            $10);')




    #INSERT INTO replicated_causes(cause_id, org_name) VALUES ($1, $2)
  end

  def write(row)
    time = Time.now
    @conn.exec_prepared('insert_pg_stmt',
    [
      row[:burn_link_id],
      row[:burn_balance_transaction_id],
      row[:earn_balance_transaction_id],
      row[:type],
      row[:cut_payee_id],
      row[:amount],

      row[:cut_percent],
      row[:cut_amount],
      row[:matched],
      row[:updated]     ]
      )
      #, time
  rescue PG::Error => ex
    puts "ERROR for burn link updated at: #{row[:updated]}"
    puts ex.message
    # Maybe, write to db table or file
  end

  def close
    @conn.close
    @conn = nil
  end
end

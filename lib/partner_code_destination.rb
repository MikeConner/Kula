require 'pg'

class PartnerCodeDestination
  # connect_url should look like;
  #  mysql://user:pass@localhost/dbname

  def initialize(connect_url)
    @conn = PG.connect(connect_url)
    #TODO - Insert Cause Statement
    @conn.prepare('insert_pg_stmt', 'INSERT INTO replicated_partner_codes(
            code, balance_transaction_id, partner_id, value, currency, user_id,
            created, claimed, batch_id, cut_percent, active, activated, batch_partner_id)
    VALUES ($1, $2, $3, $4, $5, $6,
            $7, $8, $9, $10, $11, $12, $13);')




    #INSERT INTO replicated_causes(cause_id, org_name) VALUES ($1, $2)
  end

  def write(row)
    time = Time.now
    @conn.exec_prepared('insert_pg_stmt',
    [
      row[:code],
      row[:balance_transaction_id],
      row[:partner_id],
      row[:value],
      row[:currency],
      row[:user_id],
      row[:created],
      row[:claimed],
      row[:batch_id],
      row[:cut_percent],
      row[:active],
      row[:activated],
      row[:batch_partner_id] ]
      )
      #, time
  rescue PG::Error => ex
    puts "ERROR for code : #{row[:code]}"
    puts ex.message
    # Maybe, write to db table or file
  end

  def close
    @conn.close
    @conn = nil
  end
end

require 'pg'

class PartnerTransactionFieldDestination
  # connect_url should look like;
  #  mysql://user:pass@localhost/dbname

  def initialize(connect_url)
    @conn = PG.connect(connect_url)
    #TODO - Insert Cause Statement
    @conn.prepare('insert_pg_stmt', 'INSERT INTO replicated_partner_transaction_field(
            partner_transaction_id, name, value)
    VALUES ($1, $2, $3);')




    #INSERT INTO replicated_causes(cause_id, org_name) VALUES ($1, $2)
  end

  def write(row)
    time = Time.now
    @conn.exec_prepared('insert_pg_stmt',
    [
      row[:partner_transaction_id],
      row[:name],
      row[:value] ]
      )
      #, time
  rescue PG::Error => ex
    puts "ERROR for partner transaction ID: #{row[:partner_transaction_id]}"
    puts ex.message
    # Maybe, write to db table or file
  end

  def close
    @conn.close
    @conn = nil
  end
end

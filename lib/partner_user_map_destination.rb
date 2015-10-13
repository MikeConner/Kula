require 'pg'

class PartnerUserMapDestination
  # connect_url should look like;
  #  mysql://user:pass@localhost/dbname

  def initialize(connect_url)
    @conn = PG.connect(connect_url)
    #TODO - Insert Cause Statement
    @conn.prepare('insert_pg_stmt', 'INSERT INTO replicated_partner_user_map(
            user_id, partner_id, partner_identity_id)
            VALUES ($1, $2, $3);')




    #INSERT INTO replicated_causes(cause_id, org_name) VALUES ($1, $2)
  end

  def write(row)
    time = Time.now
    @conn.exec_prepared('insert_pg_stmt',
    [
      row[:user_id],
      row[:partner_id],
      row[:partner_identity_id]
    ]
      )
      #, time
  rescue PG::Error => ex
    puts "ERROR for map user ID: #{row[:user_id]}"
    puts ex.message
    # Maybe, write to db table or file
  end

  def close
    @conn.close
    @conn = nil
  end
end

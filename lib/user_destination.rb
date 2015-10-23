require 'pg'

class UserDestination
  # connect_url should look like;
  #  mysql://user:pass@localhost/dbname

  def initialize(conn_url)

     
    @conn =  PG.connect(conn_url)

    @conn.prepare('insert_pg_stmt', 'INSERT INTO replicated_users(
            user_id, email, facebook_id, password, birthday, gender, first_name,
            last_name, name_prefix, donor_type, group_name, last_login, last_activity,
            account_created, address1, address2, city, region, country, postal_code,
            newsletter, program_email, tax_receipts)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9,
            $10, $11, $12, $13,
            $14, $15, $16, $17, $18, $19, $20, $21, $22, $23);')




    #INSERT INTO replicated_causes(cause_id, org_name) VALUES ($1, $2)
  end

  def write(row)
    time = Time.now
    @conn.exec_prepared('insert_pg_stmt',
    [
      row[:user_id],
      row[:email],
      row[:facebook_id],
      row[:password],
      row[:birthday],
      row[:gender],
      row[:first_name],
      row[:last_name],
      row[:name_prefix],
      row[:donor_type],
      row[:group_name],
      row[:last_login],
      row[:last_activity],
      row[:account_created],
      row[:address1],
      row[:address2],
      row[:city],
      row[:region],
      row[:country],
      row[:postal_code],
      row[:newsletter],
      row[:program_email],
      row[:tax_receipts] ]
      )
      #, time
  rescue PG::Error => ex
    puts "ERROR for user with id: #{row[:user_id]}"
    puts ex.message
    # Maybe, write to db table or file
  end

  def close
    @conn.close
    @conn = nil
  end
end

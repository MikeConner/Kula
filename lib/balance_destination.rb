require 'pg'

class BalanceDestination
  def initialize(connect_url)
    @conn = PG.connect(connect_url)
    @conn.prepare('insert_pg_stmt', 'INSERT INTO replicated_balances(
            user_id, partner_id, currency, amount, updated, created)
    VALUES ($1, $2, $3, $4, $5, $6);')
  end

  def write(row)
    time = Time.now
    @conn.exec_prepared('insert_pg_stmt',
    [
      row[:user_id],
      row[:partner_id],
      row[:currency],
      row[:amount],
      row[:updated],
      row[:created] ]
      )
      #, time
  rescue PG::Error => ex
    puts "ERROR for balance created at: #{row[:created]}"
    puts ex.message
    # Maybe, write to db table or file
  end

  def close
    @conn.close
    @conn = nil
  end
end

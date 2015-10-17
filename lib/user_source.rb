require 'mysql2'
require 'uri'



class UserSource
  # connect_url should look like;
  # mysql://user:password@localhost/dbname


  def initialize(connect_hash)
    @mysql = Mysql2::Client.new(connect_hash)
  end

#connect_hash(connect_url)
  def each
    results = @mysql.query('select
	u.*, 
	b12.amount as Partner12_balance,
	b14.amount as Partner14_balance,
	b22.amount as Partner22_balance,
	b24.amount as Partner24_balance,
	b10.amount as Partner10_balance,
	b11.amount as Partner11_balance

from users u
	left outer join balances b12 on b12.partner_id = 12 and b12.user_id = u.user_id
	left outer join balances b14 on b12.partner_id = 14 and b12.user_id = u.user_id
	left outer join balances b22 on b12.partner_id = 22 and b12.user_id = u.user_id
	left outer join balances b24 on b12.partner_id = 24 and b12.user_id = u.user_id
	left outer join balances b10 on b12.partner_id = 10 and b12.user_id = u.user_id
	left outer join balances b11 on b12.partner_id = 11 and b12.user_id = u.user_id ', as: :hash, symbolize_keys: true)
    results.each do |row|

      yield(row)
    end
  end


end

require 'mysql2'
require 'uri'



class UserSource
  DEFAULT_BATCH_SIZE = 10000


  def initialize(connect_hash)
    @mysql = Mysql2::Client.new(connect_hash)
    @batch_size = ENV['BATCH_SIZE'].to_i || DEFAULT_BATCH_SIZE
    @last_user_id = ENV['LAST_USER_ID']
  end

#connect_hash(connect_url)
  def each

    query = "select * from kula.users "

    unless @last_user_id.nil?
      query += " WHERE user_id > '#{@last_user_id}'"
    end
    query += " ORDER BY user_id ASC LIMIT #{@batch_size}"
    #puts query
    results = @mysql.query(query, as: :hash, symbolize_keys: true)
    results.each do |row|
      yield(row)
    end
  end







end
#select u.*, b12.amount as Partner12_balance, b14.amount as Partner14_balance, b22.amount as Partner22_balance, b24.amount as Partner24_balance, b10.amount as Partner10_balance, b11.amount as Partner11_balance

# from users u
# left outer join balances b12 on b12.partner_id = 12 and b12.user_id = u.user_id
# left outer join balances b14 on b12.partner_id = 14 and b12.user_id = u.user_id
# left outer join balances b22 on b12.partner_id = 22 and b12.user_id = u.user_id
# left outer join balances b24 on b12.partner_id = 24 and b12.user_id = u.user_id
# left outer join balances b10 on b12.partner_id = 10 and b12.user_id = u.user_id
# left outer join balances b11 on b12.partner_id = 11 and b12.user_id = u.user_id

require 'mysql2'
require 'uri'



class BalanceTransactionSource
  DEFAULT_BATCH_SIZE = 10000

  def initialize(connect_hash)
    @mysql = Mysql2::Client.new(connect_hash)
    @batch_size = ENV['BATCH_SIZE'].to_i || DEFAULT_BATCH_SIZE
    @last_txn_id = ENV['LAST_TXN_ID']
  end

  def each
    query = "select * from balance_transactions "
    unless @last_txn_id.nil?
      query += " WHERE transaction_id > #{@last_txn_id}"
    end
    query += " ORDER BY transaction_id ASC LIMIT #{@batch_size}"
    #puts query
    results = @mysql.query(query, as: :hash, symbolize_keys: true)
    results.each do |row|
      yield(row)
    end
  end

end

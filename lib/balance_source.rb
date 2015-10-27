require 'mysql2'
require 'uri'

class BalanceSource
  def initialize(connect_hash)
    @mysql = Mysql2::Client.new(connect_hash)
  end

  def each
    results = @mysql.query('select * from balances  ', as: :hash, symbolize_keys: true)
    results.each do |row|
      yield(row)
    end
  end
end

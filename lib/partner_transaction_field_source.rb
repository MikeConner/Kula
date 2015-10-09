require 'mysql2'
require 'uri'



class PartnerTransactionFieldSource
  # connect_url should look like;
  # mysql://user:password@localhost/dbname


  def initialize(connect_hash)
    @mysql = Mysql2::Client.new(connect_hash)
  end

#connect_hash(connect_url)
  def each
    results = @mysql.query('select * from partner_transaction_field  ', as: :hash, symbolize_keys: true)
    results.each do |row|

      yield(row)
    end
  end


end

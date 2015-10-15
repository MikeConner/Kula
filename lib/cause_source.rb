require 'mysql2'
require 'uri'

class CauseSource
  DEFAULT_BATCH_SIZE = 10000

  # connect_url should look like;
  # mysql://user:password@localhost/dbname
  def initialize(connect_hash)
    @mysql = Mysql2::Client.new(connect_hash)
    @batch_size = ENV['BATCH_SIZE'].to_i || DEFAULT_BATCH_SIZE
    @last_cause_id = ENV['LAST_CAUSE_ID']
  end

#connect_hash(connect_url)
  def each
    query = "select * from kula.causes "

    unless @last_cause_id.nil?
      query += " WHERE cause_id > '#{@last_cause_id}'"
    end
    query += " ORDER BY cause_id ASC LIMIT #{@batch_size}"
    puts query
    results = @mysql.query(query, as: :hash, symbolize_keys: true)
    results.each do |row|
      yield(row)
    end
  end
end

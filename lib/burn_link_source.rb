require 'mysql2'
require 'uri'



class BurnLinkSource
  DEFAULT_BATCH_SIZE = 10000
  def initialize(connect_hash)
    @mysql = Mysql2::Client.new(connect_hash)
    @batch_size = ENV['BATCH_SIZE'].to_i || DEFAULT_BATCH_SIZE
    @last_burn_id = ENV['LAST_BURN_ID']
  end

#connect_hash(connect_url)
  def each
    query = "select * from kula.burn_links "

    unless @last_burn_id.nil?
      query += " WHERE burn_link_id > '#{@last_burn_id}'"
    end
    query += " ORDER BY burn_link_id ASC LIMIT #{@batch_size}"
    puts query
    results = @mysql.query(query, as: :hash, symbolize_keys: true)
    results.each do |row|
      yield(row)
    end
  end







end

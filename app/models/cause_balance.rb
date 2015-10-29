# == Schema Information
#
# Table name: cause_balances
#
#  id                  :integer          not null, primary key
#  partner_id          :integer          not null
#  cause_id            :integer          not null
#  year                :integer          not null
#  balance_type        :string(16)
#  jan                 :decimal(8, 2)    default(0.0), not null
#  feb                 :decimal(8, 2)    default(0.0), not null
#  mar                 :decimal(8, 2)    default(0.0), not null
#  apr                 :decimal(8, 2)    default(0.0), not null
#  may                 :decimal(8, 2)    default(0.0), not null
#  jun                 :decimal(8, 2)    default(0.0), not null
#  jul                 :decimal(8, 2)    default(0.0), not null
#  aug                 :decimal(8, 2)    default(0.0), not null
#  sep                 :decimal(8, 2)    default(0.0), not null
#  oct                 :decimal(8, 2)    default(0.0), not null
#  nov                 :decimal(8, 2)    default(0.0), not null
#  dec                 :decimal(8, 2)    default(0.0), not null
#  total               :decimal(8, 2)    default(0.0), not null
#  created_at          :datetime
#  updated_at          :datetime
#  prior_year_rollover :decimal(8, 2)    default(0.0), not null
#

require 'csv'

class CauseBalance < ActiveRecord::Base
  PAYMENT = 'Payment'
  GROSS = 'Gross'
  DISCOUNT = 'Discount' # Discount fee
  NET = 'Net'
  ADJUSTMENT = 'Adjustment'
  DONEE_AMOUNT = 'Donee Amount'
  KULA_FEE = 'Kula Fee'
  FOUNDATION_FEE = 'Foundation Fee'
  DISTRIBUTOR_FEE = 'Distributor Fee'
  CREDIT_CARD_FEE = 'Credit Fee'
  
  DEFAULT_ACH_PAYMENT_THRESHOLD = 10
  DEFAULT_CHECK_PAYMENT_THRESHOLD = 25
  
  BALANCE_TYPES = [PAYMENT, GROSS, DISCOUNT, NET, KULA_FEE, FOUNDATION_FEE, DISTRIBUTOR_FEE, CREDIT_CARD_FEE, ADJUSTMENT, DONEE_AMOUNT]
  MAX_TYPE_LEN = 16
    
  belongs_to :partner
  belongs_to :cause
  
  validates :year, :numericality => { :only_integer => true, :greater_than => 2000 }
  validates_inclusion_of :balance_type, :in => BALANCE_TYPES
  validates :jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec, :total, 
              :numericality => { :greater_than_or_equal_to => 0 }, :unless => Proc.new { |b| (PAYMENT == b.balance_type) or (ADJUSTMENT == b.balance_type) }
  validates_numericality_of :prior_year_rollover, :allow_nil => true
  
  scope :payments, -> { where("balance_type = ?", PAYMENT).group(:year, :partner_id) }
  scope :transactional, -> { where("balance_type in (?)", [GROSS, DISCOUNT, NET, KULA_FEE, FOUNDATION_FEE, DISTRIBUTOR_FEE, CREDIT_CARD_FEE, DONEE_AMOUNT]) }
  
  def self.generate_payment_batch(user_id, partner, month, year, has_ach, minimum_due = 10)
    # Get the ids of those with ACH info; this should be smaller
    ach_causes = Cause.where(:has_ach_info => true).map(&:cause_identifier)
    sum_clause = get_sum_clause(month)
    payment_method = has_ach ? Payment::ACH : Payment::CHECK
    
    sql = "SELECT * FROM" + 
          "(SELECT cause_id, #{sum_clause} as balance_due from cause_balances" +
          " WHERE partner_id = #{partner} and year <= #{year} and balance_type in ('#{PAYMENT}', '#{ADJUSTMENT}', '#{DONEE_AMOUNT}') " +
          "GROUP BY cause_id) as firstPass WHERE balance_due > #{minimum_due}"
    
    records = ActiveRecord::Base.connection.execute(sql)

    ActiveRecord::Base.transaction do
      begin
        partner = Partner.find(partner)
        batch = partner.batches.create!(:user_id => user_id, 
                                        :date => Time.now, 
                                        :name => "Generated payment batch #{Time.now.to_s}",
                                        :description => "month=#{month}; year=#{year}; has_ach=#{has_ach}; minimum_due=#{minimum_due}") 
        # This assuming we're downloading it vs. creating the batch here
        CSV.generate do |csv|
          csv << ['check_num', 'cause_id', 'name', 'address_1', 'address_2', 'address_3', 'city', 'region', 'country', 'postal_code',
                  'mailing_address', 'mailing_city', 'mailing_state', 'mailing_postal_code',
                  'balance_due', 'payment type']

          records.each do |rec|
            cid = rec['cause_id'].to_i
            
            # Skip if ach_info doesn't match
            next if ach_causes.include?(cid) ^ has_ach
            
            # Generate payment
            cause = Cause.find(cid)
            address = cause.mailing_address.blank? ? "#{cause.address_1} #{cause.address_2} #{cause.address_3}" : cause.mailing_address || ""
            address += "; " unless address.blank?
            address += cause.mailing_city.blank? ? cause.city || "" : cause.mailing_city || ""
            address += ", " unless address.blank?
            address += cause.mailing_state.blank? ? cause.region || "" : cause.mailing_state || ""
            address += " " unless address.blank?
            address += cause.mailing_postal_code.blank? ? cause.postal_code || "" : cause.mailing_postal_code || ""
            
            payment = batch.payments.create!(:cause_id => cid, 
                                             :amount => rec['balance_due'].to_f, 
                                             :date => Time.now, 
                                             :payment_method => payment_method,
                                             :address => address,
                                             :check_num => 0)
            payment.update_attribute(:check_num, payment.id)
            balance = partner.cause_balances.create!(:cause_id => cid, :year => payment.date.year, :balance_type => PAYMENT, :total => payment.amount)
            case payment.date.month
              when 1
                balance.update_attribute(:jan, payment.amount)
              when 2
                balance.update_attribute(:feb, payment.amount)
              when 3
                balance.update_attribute(:mar, payment.amount)
              when 4
                balance.update_attribute(:apr, payment.amount)
              when 5
                balance.update_attribute(:may, payment.amount)
              when 6
                balance.update_attribute(:jun, payment.amount)
              when 7
                balance.update_attribute(:jul, payment.amount)
              when 8
                balance.update_attribute(:aug, payment.amount)
              when 9
                balance.update_attribute(:sep, payment.amount)
              when 10
                balance.update_attribute(:oct, payment.amount)
              when 11
                balance.update_attribute(:nov, payment.amount)
              when 12
                balance.update_attribute(:dec, payment.amount)
            end
                                             
            csv << [payment.id, cid, cause.org_name, cause.address_1, cause.address_2, cause.address_3, cause.city, cause.region, cause.country, cause.postal_code,
                    cause.mailing_address, cause.mailing_city, cause.mailing_state, cause.mailing_postal_code,
                    rec['balance_due'].to_f, payment_method]
          end
        end
      end
    end
  end

  def update_balance(month, amount)
    case month
    when 1
      update_attribute(:jan, self.jan + amount)
    when 2
      update_attribute(:feb, self.feb + amount)
    when 3
      update_attribute(:mar, self.mar + amount)
    when 4
      update_attribute(:apr, self.apr + amount)
    when 5
      update_attribute(:may, self.may + amount)
    when 6
      update_attribute(:jun, self.jun + amount)
    when 7
      update_attribute(:jul, self.jul + amount)
    when 8
      update_attribute(:aug, self.aug + amount)
    when 9
      update_attribute(:sep, self.sep + amount)
    when 10
      update_attribute(:oct, self.oct + amount)
    when 11
      update_attribute(:nov, self.nov + amount)
    when 12
      update_attribute(:dec, self.dec + amount)
    else
      raise "Invalid month #{month}"
    end                          
  end
  
private
  def self.get_sum_clause(month)
    case month
    when 1
      "SUM(jan)"
    when 2
      "SUM(jan+feb)"
    when 3
      "SUM(jan+feb+mar)"
    when 4
      "SUM(jan+feb+mar+apr)"
    when 5
      "SUM(jan+feb+mar+apr+may)"
    when 6
      "SUM(jan+feb+mar+apr+may+jun)"
    when 7
      "SUM(jan+feb+mar+apr+may+jun+jul)"
    when 8
      "SUM(jan+feb+mar+apr+may+jun+jul+aug)"
    when 9
      "SUM(jan+feb+mar+apr+may+jun+jul+aug+sep)"
    when 10
      "SUM(jan+feb+mar+apr+may+jun+jul+aug+sep+oct)"
    when 11
      "SUM(jan+feb+mar+apr+may+jun+jul+aug+sep+oct+nov)"
    when 12
      "SUM(jan+feb+mar+apr+may+jun+jul+aug+sep+oct+nov+dec)"
    end
  end

  def self.payment_batch_check_query
    <<-EOT
      SELECT 
        SUM(prior_year_rollover) AS prior_year,cause_id,
        SUM(jan) AS jan_sum,
        SUM(feb) AS feb_sum,
        SUM(mar) AS mar_sum,
        SUM(apr) AS apr_sum,
        SUM(may) AS may_sum,
        SUM(jun) AS jun_sum,
        SUM(jul) AS jul_sum,
        SUM(aug) AS aug_sum,
        SUM(sep) AS sep_sum,
        SUM(oct) AS oct_sum,
        SUM(nov) AS nov_sum,
        SUM(dec) AS dec_sum
      FROM cause_balances
      WHERE year = ##YEAR AND partner_id = ##PARTNER_ID AND balance_type IN ('Donee Amount','Payment','Adjustment') 
      GROUP BY cause_id
    EOT
  end
  
  def self.payment_batch_ach_query
    <<-EOT
      SELECT 
        SUM(prior_year_rollover) AS prior_year,b.cause_id,
        SUM(jan) AS jan_sum,
        SUM(feb) AS feb_sum,
        SUM(mar) AS mar_sum,
        SUM(apr) AS apr_sum,
        SUM(may) AS may_sum,
        SUM(jun) AS jun_sum,
        SUM(jul) AS jul_sum,
        SUM(aug) AS aug_sum,
        SUM(sep) AS sep_sum,
        SUM(oct) AS oct_sum,
        SUM(nov) AS nov_sum,
        SUM(dec) AS dec_sum
      FROM cause_balances b
      INNER JOIN causes c ON b.cause_id = c.cause_identifier 
      WHERE year = ##YEAR AND partner_id = ##PARTNER_ID AND c.has_ach_info = 1 AND balance_type IN ('Donee Amount','Payment','Adjustment') 
      GROUP BY b.cause_id
    EOT
  end
  
  def self.cause_index_query
    <<-EOT
      SELECT partner_id, cb.cause_id, c.org_name, 
        SUM(prior_year_rollover) AS prior_year_total,
        SUM(jan) AS jan_total,
        SUM(feb) AS feb_total,
        SUM(mar) AS mar_total, 
        SUM(apr) as apr_total,
        SUM(may) as may_total, 
        SUM(jun) as jun_total, 
        SUM(jul) as jul_total,
        SUM(aug) as aug_total,
        SUM(sep) as sep_total,
        SUM(oct) as oct_total,
        SUM(nov) as nov_total,
        SUM(dec) AS dec_total, 
        SUM(prior_year_rollover) + SUM(jan) +SUM(feb) +SUM(mar)  AS q1_total,
        SUM(prior_year_rollover) + SUM(jan) +SUM(feb) +SUM(mar) + SUM(apr) + SUM(may) + SUM(jun) AS q2_total,
        SUM(prior_year_rollover) + SUM(jan) +SUM(feb) +SUM(mar) + SUM(apr) + SUM(may) + SUM(jun) + SUM(jul) + SUM(aug) + SUM(sep) AS q3_total,
        SUM(prior_year_rollover) + SUM(jan) +SUM(feb) +SUM(mar) + SUM(apr) + SUM(may) + SUM(jun) + SUM(jul) + SUM(aug) + SUM(sep) + SUM(oct) + SUM(nov)+ SUM(dec) AS q4_total
       
        FROM cause_balances cb
        INNER JOIN causes c ON c.cause_identifier = cb.cause_id
      
        WHERE year = ##YEAR AND balance_type in ('Payment', 'Adjustment', 'Donee Amount') 
              ##NAME_FILTER ##PARTNER_FILTER ##ACH_FILTER
       
        GROUP BY partner_id, cb.cause_id, c.org_name
        ORDER BY partner_id
    EOT
  end
end

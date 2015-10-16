# == Schema Information
#
# Table name: cause_balances
#
#  id           :integer          not null, primary key
#  partner_id   :integer          not null
#  cause_id     :integer          not null
#  year         :integer          not null
#  balance_type :string(16)
#  jan          :decimal(8, 2)    default(0.0), not null
#  feb          :decimal(8, 2)    default(0.0), not null
#  mar          :decimal(8, 2)    default(0.0), not null
#  apr          :decimal(8, 2)    default(0.0), not null
#  may          :decimal(8, 2)    default(0.0), not null
#  jun          :decimal(8, 2)    default(0.0), not null
#  jul          :decimal(8, 2)    default(0.0), not null
#  aug          :decimal(8, 2)    default(0.0), not null
#  sep          :decimal(8, 2)    default(0.0), not null
#  oct          :decimal(8, 2)    default(0.0), not null
#  nov          :decimal(8, 2)    default(0.0), not null
#  dec          :decimal(8, 2)    default(0.0), not null
#  total        :decimal(8, 2)    default(0.0), not null
#  created_at   :datetime
#  updated_at   :datetime
#

require 'csv'

class CauseBalance < ActiveRecord::Base
  PAYMENT = 'Payment'
  GROSS = 'Gross'
  DISCOUNT = 'Discount' # Discount fee
  NET = 'Net'
  FEE = 'Fees'
  ADJUSTMENT = 'Adjustment'
  DONEE_AMOUNT = 'Donee Amount'
  
  BALANCE_TYPES = [PAYMENT, GROSS, DISCOUNT, NET, FEE, ADJUSTMENT, DONEE_AMOUNT]
  MAX_TYPE_LEN = 16
    
  belongs_to :partner
  belongs_to :cause
  
  validates :year, :numericality => { :only_integer => true, :greater_than => 2000 }
  validates_inclusion_of :balance_type, :in => BALANCE_TYPES
  validates :jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec, :total, 
              :numericality => { :greater_than_or_equal_to => 0 }, :unless => Proc.new { |b| (PAYMENT == b.balance_type) or (ADJUSTMENT == b.balance_type) }
  
  scope :payments, -> { where("balance_type = ?", PAYMENT).group(:year, :partner_id) }
  scope :transactional, -> { where("balance_type in (?)", [PAYABLE, GROSS, DISCOUNT, NET, FEE, DONEE_AMOUNT]) }
  
  def self.generate_payment_batch(user_id, partner, month, year, has_ach, minimum_due = 10)
    # Get the ids of those with ACH info; this should be smaller
    ach_causes = ReplicatedCause.where(:has_ach_info => true).map(&:cause_identifier)
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
                                             
            csv << [payment.id, cid, cause.name, cause.address_1, cause.address_2, cause.address_3, cause.city, cause.region, cause.country, cause.postal_code,
                    cause.mailing_address, cause.mailing_city, cause.mailing_state, cause.mailing_postal_code,
                    rec['balance_due'].to_f, payment_method]
          end
        end
      end
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
end

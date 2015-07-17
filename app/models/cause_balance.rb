# == Schema Information
#
# Table name: cause_balances
#
#  id           :integer          not null, primary key
#  partner_id   :integer
#  cause_id     :integer
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

class CauseBalance < ActiveRecord::Base
  PAYABLE = 'Payable'
  PAYMENT = 'Payment'
  GROSS = 'Gross'
  DISCOUNT = 'Discount'
  NET = 'Net'
  FEE = 'Fee'
  ADJUSTMENT = 'Adjustment'
  DONEE_AMOUNT = 'Donee Amount'
  
  BALANCE_TYPES = [PAYABLE, PAYMENT, GROSS, DISCOUNT, NET, FEE, ADJUSTMENT, DONEE_AMOUNT]
  MAX_TYPE_LEN = 16
    
  belongs_to :partner
  belongs_to :cause
  
  validates :year, :numericality => { :only_integer => true, :greater_than => 2000 }
  validates_inclusion_of :balance_type, :in => BALANCE_TYPES
  validates :jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec, :total, :numericality => { :greater_than_or_equal_to => 0.0 }
  
  scope :payments, -> { where("balance_type = ?", PAYMENT).group(:year, :partner_id) }
end

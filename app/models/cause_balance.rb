# == Schema Information
#
# Table name: cause_balances
#
#  id         :integer          not null, primary key
#  partner_id :integer
#  cause_id   :integer
#  year       :integer          not null
#  cause_type :string(16)
#  jan        :decimal(8, 2)    default(0.0), not null
#  feb        :decimal(8, 2)    default(0.0), not null
#  mar        :decimal(8, 2)    default(0.0), not null
#  apr        :decimal(8, 2)    default(0.0), not null
#  may        :decimal(8, 2)    default(0.0), not null
#  jun        :decimal(8, 2)    default(0.0), not null
#  jul        :decimal(8, 2)    default(0.0), not null
#  aug        :decimal(8, 2)    default(0.0), not null
#  sep        :decimal(8, 2)    default(0.0), not null
#  oct        :decimal(8, 2)    default(0.0), not null
#  nov        :decimal(8, 2)    default(0.0), not null
#  dec        :decimal(8, 2)    default(0.0), not null
#  total      :decimal(8, 2)    default(0.0), not null
#  created_at :datetime
#  updated_at :datetime
#

class CauseBalance < ActiveRecord::Base
  CAUSE_TYPES = ['Payable', 'Payment', 'Gross', 'Discount', 'Net', 'Fees', 'Adjustments', 'Donee Amount']
  MAX_TYPE_LEN = 16
  
  belongs_to :partner
  belongs_to :cause
  
  validates :year, :numericality => { :only_integer => true, :greater_than => 2000 }
  validates_inclusion_of :cause_type, :in => CAUSE_TYPES
  validates :jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec, :total, :numericality => { :greater_than_or_equal_to => 0.0 }
end

# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  batch_id       :integer
#  status         :string(16)       default("Outstanding"), not null
#  amount         :decimal(8, 2)    not null
#  date           :datetime
#  confirmation   :string(255)
#  payment_method :string(8)        default("Check"), not null
#  address        :string(255)
#  comment        :text
#  created_at     :datetime
#  updated_at     :datetime
#  cause_id       :integer          not null
#  check_num      :integer          not null
#  month          :integer          not null
#  year           :integer          not null
#

class Payment < ActiveRecord::Base
  MAX_METHOD_LEN = 8
  MAX_STATUS_LEN = 16
  CLEARED = 'Cleared'
  OUTSTANDING = 'Outstanding'
  CANCELLED = 'Cancelled'
  REISSUED = 'Reissued'
  RETURNED = 'Returned'
  VOID = 'Void'
  DELETED = 'Deleted'
  
  ACH = 'ACH'
  CHECK = 'Check'
  
  VALID_METHODS = [ACH, CHECK]
  VALID_CHECK_STATUSES = [OUTSTANDING, CLEARED, CANCELLED, REISSUED, VOID]
  VALID_ACH_STATUSES = [OUTSTANDING, CLEARED, RETURNED, REISSUED]
  
  belongs_to :batch
  belongs_to :cause
  has_one :partner, :through => :batch

  # For pagination
  self.per_page = 100
  
  validates_inclusion_of :status, :in => VALID_CHECK_STATUSES + [DELETED], :if => :check_payment?
  validates_inclusion_of :status, :in => VALID_ACH_STATUSES + [DELETED], :if => :ach_payment?
  
  validates :amount, :numericality => { :greater_than => 0 }
  validates_inclusion_of :payment_method, :in => VALID_METHODS
  validates_presence_of :check_num
  validates :month, :numericality => { :only_integer => true },
                    :inclusion => { :in => 1..12 }
  validates :year, :numericality => { :only_integer => true, :greater_than => 2000 }

  def check_payment?
    Payment::CHECK == self.payment_method
  end
  
  def ach_payment?
    Payment::ACH == self.payment_method
  end
  
  def deleted?
    DELETED == self.status
  end
end

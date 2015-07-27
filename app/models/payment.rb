# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  batch_id       :integer
#  status         :string(16)
#  amount         :decimal(8, 2)    not null
#  date           :datetime
#  confirmation   :string(255)
#  payment_method :string(8)
#  address        :string(255)
#  comment        :text(65535)
#  created_at     :datetime
#  updated_at     :datetime
#  cause_id       :integer
#

class Payment < ActiveRecord::Base
  MAX_METHOD_LEN = 8
  MAX_STATUS_LEN = 16
  PENDING = 'Pending'
  ACH = 'ACH'
  CHECK = 'Check'
  
  VALID_STATUSES = [PENDING, 'Approved', 'Sent', 'Cleared', 'Hold']
  VALID_METHODS = [ACH, CHECK]
  
  belongs_to :batch
  belongs_to :cause
  
  validates_inclusion_of :status, :in => VALID_STATUSES
  validates :amount, :numericality => { :greater_than => 0 }
  validates_inclusion_of :payment_method, :in => VALID_METHODS
end

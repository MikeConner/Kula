# == Schema Information
#
# Table name: adjustments
#
#  id         :integer          not null, primary key
#  batch_id   :integer
#  amount     :decimal(8, 2)    not null
#  date       :datetime
#  comment    :text
#  created_at :datetime
#  updated_at :datetime
#  cause_id   :integer
#

class Adjustment < ActiveRecord::Base
  belongs_to :batch
  belongs_to :cause
  
  validates :amount, :numericality => { :only_integer => false }
end

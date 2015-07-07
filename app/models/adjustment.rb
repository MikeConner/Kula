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
#

class Adjustment < ActiveRecord::Base
  belongs_to :batch
  
  validates :amount, :numericality => { :only_integer => false }
end

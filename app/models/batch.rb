# == Schema Information
#
# Table name: batches
#
#  id          :integer          not null, primary key
#  partner_id  :integer
#  user_id     :integer
#  name        :string(128)
#  date        :datetime
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Batch < ActiveRecord::Base
  MAX_NAME_LEN = 32
  
  belongs_to :partner
  belongs_to :user
  
  has_many :payments, :dependent => :restrict_with_exception
  has_many :adjustments, :dependent => :restrict_with_exception

  accepts_nested_attributes_for :payments, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :adjustments, :allow_destroy => true, :reject_if => :all_blank
end

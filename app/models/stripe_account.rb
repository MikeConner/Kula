# == Schema Information
#
# Table name: stripe_accounts
#
#  id         :integer          not null, primary key
#  cause_id   :integer
#  token      :string(32)       not null
#  created_at :datetime
#  updated_at :datetime
#

class StripeAccount < ActiveRecord::Base
  MAX_TOKEN_LEN = 32
  
  belongs_to :cause
  
  validates :token, :presence => true, :length => { :maximum => MAX_TOKEN_LEN }
end

# == Schema Information
#
# Table name: distributors
#
#  id           :integer          not null, primary key
#  partner_id   :integer
#  name         :string(64)       not null
#  display_name :string(64)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# CHARTER
#   Identify a distributor, which can be associated with a partner and affects the associated Kula fees
#
# USAGE
#
# NOTES AND WARNINGS
#
class Distributor < ActiveRecord::Base
  MAX_NAME_LEN = 64

  belongs_to :partner
  
  validates :name, :presence => true, :length => { :maximum => MAX_NAME_LEN }
  validates :display_name, :length => { :maximum => MAX_NAME_LEN }
end

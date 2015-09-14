# == Schema Information
#
# Table name: transactions
#
#  transaction_identifier :integer          not null
#  partner_identifier     :integer
#  month                  :integer          not null
#  year                   :integer          not null
#  gross_amount           :decimal(8, 2)
#  net_amount             :decimal(8, 2)
#  donee_amount           :decimal(8, 2)
#  discounts_amount       :decimal(6, 2)
#  fees_amount            :decimal(6, 2)
#  calc_kula_fee          :decimal(6, 2)
#  calc_foundation_fee    :decimal(6, 2)
#  calc_distributor_fee   :decimal(6, 2)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

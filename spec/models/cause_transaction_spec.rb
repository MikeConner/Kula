# == Schema Information
#
# Table name: cause_transactions
#
#  id                   :integer          not null, primary key
#  partner_identifier   :integer          not null
#  cause_identifier     :integer          not null
#  month                :integer          not null
#  year                 :integer          not null
#  gross_amount         :decimal(8, 2)    default(0.0)
#  legacy_net           :decimal(8, 2)    default(0.0)
#  legacy_donee         :decimal(8, 2)    default(0.0)
#  legacy_discounts     :decimal(8, 2)    default(0.0)
#  legacy_fees          :decimal(8, 2)    default(0.0)
#  calc_kula_fee        :decimal(8, 2)    default(0.0)
#  calc_foundation_fee  :decimal(8, 2)    default(0.0)
#  calc_distributor_fee :decimal(8, 2)    default(0.0)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  calc_credit_card_fee :decimal(8, 2)    default(0.0)
#  donee_amount         :decimal(8, 2)
#

require 'rails_helper'

RSpec.describe CauseTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

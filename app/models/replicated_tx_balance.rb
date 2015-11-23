# == Schema Information
#
# Table name: replicated_tx_balances
#
#  id             :integer          not null, primary key
#  partnerid      :integer
#  month          :integer
#  year           :integer
#  grossamount    :decimal(, )
#  discountamount :decimal(, )
#  netamount      :decimal(, )
#  kulafees       :decimal(, )
#  doneeamount    :decimal(, )
#  causeid        :integer
#  causename      :string
#  country        :string
#  causetype      :integer
#  created        :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# This is only used for testing Rake tasks dealing with replicated data (specifically, stepwise import)
class ReplicatedTxBalance < ActiveRecord::Base
end

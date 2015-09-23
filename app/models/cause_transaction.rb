# == Schema Information
#
# Table name: cause_transactions
#
#  transaction_identifier :integer          not null, primary key
#  partner_identifier     :integer          not null
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
#  cause_identifier       :integer          not null
#

class CauseTransaction < ActiveRecord::Base
  self.primary_key = 'transaction_identifier'
  
  validates :partner_identifier, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :month, :numericality => { :only_integer => true },
                    :inclusion => { :in => 1..12 }
  validates :year, :numericality => { :only_integer => true, :greater_than => 2000 }
  validates_numericality_of :gross_amount, :net_amount, :donee_amount, :discounts_amount, :fees_amount
  validates_numericality_of :calc_kula_fee, :calc_foundation_fee, :calc_distributor_fee
end

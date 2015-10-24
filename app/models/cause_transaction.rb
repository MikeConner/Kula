# == Schema Information
#
# Table name: cause_transactions
#
#  id                   :integer          not null, primary key
#  partner_identifier   :integer          not null
#  cause_identifier     :integer          not null
#  month                :integer          not null
#  year                 :integer          not null
#  gross_amount         :decimal(8, 2)
#  net_amount           :decimal(8, 2)
#  donee_amount         :decimal(8, 2)
#  discounts_amount     :decimal(6, 2)
#  fees_amount          :decimal(6, 2)
#  calc_kula_fee        :decimal(6, 2)
#  calc_foundation_fee  :decimal(6, 2)
#  calc_distributor_fee :decimal(6, 2)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  calc_credit_card_fee :decimal(6, 2)
#

class CauseTransaction < ActiveRecord::Base
  LAST_MONTH_LABEL = 'Import Last Month'
  
  validates :partner_identifier, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :month, :numericality => { :only_integer => true },
                    :inclusion => { :in => 1..12 }
  validates :year, :numericality => { :only_integer => true, :greater_than => 2000 }
  validates_numericality_of :gross_amount, :net_amount, :donee_amount, :discounts_amount, :fees_amount
  validates_numericality_of :calc_kula_fee, :calc_foundation_fee, :calc_distributor_fee, :calc_credit_card_fee

  def self.query_step1
    <<-EOT
      SELECT
        partner_id as PartnerId, Extract(MONTH from bt.created) as Month, Extract( Year from bt.created) as Year,
        COALESCE(SUM(bt.amount),0) as GrossAmount,
        COALESCE(SUM(bl_codes.total_cut_amount),0) AS DiscountAmount,
        COALESCE(SUM(bl_cause_less_codes.total_cut_amount),0) AS NetAmount,
        COALESCE(SUM(bl_kula.total_cut_amount),0)  AS KulaFees,
        COALESCE(SUM(bl_cause_less_codes_and_kula.total_cut_amount),0) AS DoneeAmount,
        c.cause_id AS CauseId,
    c.org_name as CauseName,

    c.country AS Country,
    c.cause_type as CauseType
    FROM
        replicated_balance_transactions bt

    INNER JOIN causes c 
      ON bt.cause_id = c.cause_id

    LEFT JOIN (SELECT  burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM replicated_burn_links WHERE type = 2 GROUP BY burn_balance_transaction_id)
      AS bl_codes ON bt.transaction_id = bl_codes.burn_balance_transaction_id
    LEFT JOIN (SELECT  burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM replicated_burn_links WHERE type = 4 GROUP BY burn_balance_transaction_id)
             AS bl_negative_correction_less_codes ON bt.transaction_id = bl_negative_correction_less_codes.burn_balance_transaction_id
    LEFT JOIN (SELECT burn_balance_transaction_id,SUM(cut_amount) AS total_cut_amount FROM replicated_burn_links WHERE type IN (5 , 8) GROUP BY burn_balance_transaction_id)
      AS bl_kula ON bt.transaction_id = bl_kula.burn_balance_transaction_id
    LEFT JOIN (SELECT burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM replicated_burn_links WHERE type = 6 GROUP BY burn_balance_transaction_id)
      AS bl_cause_less_codes ON bt.transaction_id = bl_cause_less_codes.burn_balance_transaction_id
    LEFT JOIN (SELECT burn_balance_transaction_id, SUM(cut_amount) AS total_cut_amount FROM replicated_burn_links WHERE type = 7 GROUP BY burn_balance_transaction_id)
      AS bl_cause_less_codes_and_kula ON bt.transaction_id = bl_cause_less_codes_and_kula.burn_balance_transaction_id

    WHERE bt.type = 1 AND bt.status = 1
            AND bt.user_id NOT IN (34156,96194,34161,34162,74812, 34413 , 34414) AND
            (bt.created BETWEEN ##START_DATE AND ##END_DATE)
            ##PARTNER_CLAUSE

            AND NOT (bt.user_id = 34371 AND bt.partner_id = 10 AND bt.created = '2013-06-26 00:05:29')
            AND NOT (bt.user_id = 34356 AND bt.partner_id = 10 AND bt.created = '2013-06-26 01:15:07')
            AND NOT (bt.user_id = 34371 AND bt.partner_id = 10 AND bt.created = '2013-06-26 22:41:33')
            AND NOT (bt.user_id = 34356 AND bt.partner_id = 10 AND bt.created = '2013-11-27 23:24:48')
      GROUP BY Extract(MONTH from bt.created)  , Extract( Year from bt.created), partner_id, c.cause_id
    EOT
  end

  def self.query_step2
    <<-EOT
      SELECT partner_id, SUM(amount) AS amount, EXTRACT(month FROM bt_created) AS month, EXTRACT(year FROM bt_created) as year, distributor_id, cause_id FROM
          (SELECT partner_id, amount, batch_partner_id AS distributor_id,
              (SELECT cause_id FROM replicated_balance_transactions where transaction_id = burn_balance_transaction_id) AS cause_id,
                  (SELECT created from replicated_balance_transactions where transaction_id = burn_balance_transaction_id) AS bt_created
           FROM replicated_burn_links bl
             LEFT OUTER JOIN replicated_partner_codes pc ON pc.balance_transaction_id = bl.earn_balance_transaction_id
               WHERE type = 2 AND batch_partner_id NOT IN (18,19)) as bob
                 GROUP BY partner_id, cause_id, distributor_id, year, month
                 ORDER BY year, month
    EOT
  end
end

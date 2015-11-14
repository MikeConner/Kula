class RenameLegacyFields < ActiveRecord::Migration
  def change
    rename_column :cause_transactions, :discounts_amount, :legacy_discounts
    rename_column :cause_transactions, :net_amount, :legacy_net
    rename_column :cause_transactions, :fees_amount, :legacy_fees
    rename_column :cause_transactions, :donee_amount, :legacy_donee
  end
end

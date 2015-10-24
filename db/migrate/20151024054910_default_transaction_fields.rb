class DefaultTransactionFields < ActiveRecord::Migration
  def up
    change_column :cause_transactions, :gross_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :cause_transactions, :net_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :cause_transactions, :donee_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :cause_transactions, :discounts_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :cause_transactions, :fees_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :cause_transactions, :calc_kula_fee, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :cause_transactions, :calc_foundation_fee, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :cause_transactions, :calc_distributor_fee, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :cause_transactions, :calc_credit_card_fee, :decimal, :precision => 8, :scale => 2, :default => 0
  end
  
  def down
    change_column :cause_transactions, :gross_amount, :decimal, :precision => 8, :scale => 2
    change_column :cause_transactions, :net_amount, :decimal, :precision => 8, :scale => 2
    change_column :cause_transactions, :donee_amount, :decimal, :precision => 8, :scale => 2
    change_column :cause_transactions, :discounts_amount, :decimal, :precision => 8, :scale => 2
    change_column :cause_transactions, :fees_amount, :decimal, :precision => 8, :scale => 2
    change_column :cause_transactions, :calc_kula_fee, :decimal, :precision => 8, :scale => 2
    change_column :cause_transactions, :calc_foundation_fee, :decimal, :precision => 8, :scale => 2
    change_column :cause_transactions, :calc_distributor_fee, :decimal, :precision => 8, :scale => 2
    change_column :cause_transactions, :calc_credit_card_fee, :decimal, :precision => 8, :scale => 2 
  end
end

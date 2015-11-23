class AddDoneeAmountToCauseTransactions < ActiveRecord::Migration
  def change
    add_column :cause_transactions, :donee_amount, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end

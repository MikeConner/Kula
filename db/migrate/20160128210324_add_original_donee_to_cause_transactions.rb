class AddOriginalDoneeToCauseTransactions < ActiveRecord::Migration
  def change
    add_column :cause_transactions, :original_donee_amount, :decimal, :precision => 8, :scale => 2
  end
end

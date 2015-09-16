class RenameTransactionsTable < ActiveRecord::Migration
  def change
    rename_table :transactions, :cause_transactions
  end
end

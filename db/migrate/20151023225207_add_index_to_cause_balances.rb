class AddIndexToCauseBalances < ActiveRecord::Migration
  def change
    add_index :cause_balances, [:cause_id, :balance_type]
  end
end

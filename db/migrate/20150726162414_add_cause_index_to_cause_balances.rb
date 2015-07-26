class AddCauseIndexToCauseBalances < ActiveRecord::Migration
  def change
    add_index :cause_balances, :cause_id
  end
end

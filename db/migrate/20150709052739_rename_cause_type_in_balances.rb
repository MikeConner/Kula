class RenameCauseTypeInBalances < ActiveRecord::Migration
  def change
    rename_column :cause_balances, :cause_type, :balance_type
  end
end

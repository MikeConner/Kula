class AddRolloverToCauseBalances < ActiveRecord::Migration
  def change
    add_column :cause_balances, :prior_year_rollover, :decimal, :precision => 8, :scale => 2
  end
end

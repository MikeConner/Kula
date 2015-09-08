class IncreaseFeePrecision < ActiveRecord::Migration
  def up
    change_column :kula_fees, :kula_rate, :decimal, :precision => 6, :scale => 4
    change_column :kula_fees, :discount_rate, :decimal, :precision => 6, :scale => 4
  end
  
  def down
    change_column :kula_fees, :kula_rate, :decimal, :precision => 6, :scale => 3
    change_column :kula_fees, :discount_rate, :decimal, :precision => 6, :scale => 3    
  end
end

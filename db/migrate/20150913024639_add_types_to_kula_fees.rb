class AddTypesToKulaFees < ActiveRecord::Migration
  def up
    add_column :kula_fees, :us_school_rate, :decimal, :precision => 6, :scale => 4
    add_column :kula_fees, :us_charity_rate, :decimal, :precision => 6, :scale => 4
    add_column :kula_fees, :intl_charity_rate, :decimal, :precision => 6, :scale => 4
    remove_column :kula_fees, :kula_rate
    remove_column :kula_fees, :discount_rate
  end
  
  def down
    add_column :kula_fees, :kula_rate, :decimal, :precision => 6, :scale => 4    
    add_column :kula_fees, :discount_rate, :decimal, :precision => 6, :scale => 4
  end
end

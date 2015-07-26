class AddDiscountRateToKulaFees < ActiveRecord::Migration
  def change
    rename_column :kula_fees, :rate, :kula_rate
    add_column :kula_fees, :discount_rate, :decimal, :precision => 6, :scale => 3, :null => false
  end
end

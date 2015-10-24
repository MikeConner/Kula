class AddMcrccFeeToKulaFees < ActiveRecord::Migration
  def up
    add_column :kula_fees, :mcr_cc_rate, :decimal, :precision => 6, :scale => 4
    
    change_column :kula_fees, :us_school_rate, :decimal, :precision => 6, :scale => 4, :default => 0
    change_column :kula_fees, :us_charity_rate, :decimal, :precision => 6, :scale => 4, :default => 0
    change_column :kula_fees, :intl_charity_rate, :decimal, :precision => 6, :scale => 4, :default => 0
    change_column :kula_fees, :us_school_kf_rate, :decimal, :precision => 6, :scale => 4, :default => 0
    change_column :kula_fees, :us_charity_kf_rate, :decimal, :precision => 6, :scale => 4, :default => 0
    change_column :kula_fees, :intl_charity_kf_rate, :decimal, :precision => 6, :scale => 4, :default => 0
    change_column :kula_fees, :distributor_rate, :decimal, :precision => 6, :scale => 4, :default => 0
    change_column :kula_fees, :mcr_cc_rate, :decimal, :precision => 6, :scale => 4, :default => 0
    
    add_column :cause_transactions, :calc_credit_card_fee, :decimal, :precision => 6, :scale => 2
  end
  
  def down
    remove_column :kula_fees, :mcr_cc_rate
    
    change_column :kula_fees, :us_school_rate, :decimal, :precision => 6, :scale => 4
    change_column :kula_fees, :us_charity_rate, :decimal, :precision => 6, :scale => 4
    change_column :kula_fees, :intl_charity_rate, :decimal, :precision => 6, :scale => 4
    change_column :kula_fees, :us_school_kf_rate, :decimal, :precision => 6, :scale => 4
    change_column :kula_fees, :us_charity_kf_rate, :decimal, :precision => 6, :scale => 4
    change_column :kula_fees, :intl_charity_kf_rate, :decimal, :precision => 6, :scale => 4
    change_column :kula_fees, :distributor_rate, :decimal, :precision => 6, :scale => 4
    change_column :kula_fees, :mcr_cc_rate, :decimal, :precision => 6, :scale => 4  

    remove_column :cause_transactions, :calc_credit_card_fee
  end
end

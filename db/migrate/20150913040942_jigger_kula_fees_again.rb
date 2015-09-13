class JiggerKulaFeesAgain < ActiveRecord::Migration
  def change
    add_column :kula_fees, :us_school_kf_rate, :decimal, :precision => 6, :scale => 4
    add_column :kula_fees, :us_charity_kf_rate, :decimal, :precision => 6, :scale => 4
    add_column :kula_fees, :intl_charity_kf_rate, :decimal, :precision => 6, :scale => 4
    add_column :kula_fees, :distributor_rate, :decimal, :precision => 6, :scale => 4
    add_column :kula_fees, :distributor_kf_rate, :decimal, :precision => 6, :scale => 4
    add_column :kula_fees, :distributor_id, :integer
  end
end

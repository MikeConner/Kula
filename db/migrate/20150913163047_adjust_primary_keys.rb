class AdjustPrimaryKeys < ActiveRecord::Migration
  def change
    rename_column :kula_fees, :partner_id, :partner_identifier
    rename_column :kula_fees, :distributor_id, :distributor_identifier
  end
end

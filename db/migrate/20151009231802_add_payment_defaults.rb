class AddPaymentDefaults < ActiveRecord::Migration
  def up
    change_column :payments, :status, :string, :null => false, :limit => 16, :default => Payment::PENDING
    change_column :payments, :payment_method, :string, :null => false, :limit => 8, :default => Payment::CHECK
    change_column :payments, :cause_id, :integer, :null => false
  end

  def down
    change_column :payments, :status, :string, :null => true, :limit => 16
    change_column :payments, :payment_method, :string, :null => true, :limit => 8
    change_column :payments, :cause_id, :integer, :null => true
  end
end

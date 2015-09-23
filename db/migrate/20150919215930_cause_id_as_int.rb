class CauseIdAsInt < ActiveRecord::Migration
  def up
    remove_column :causes, :cause_identifier
    Cause.reset_column_information
    add_column :causes, :cause_identifier, :integer, :null => false
    
    change_column :cause_balances, :partner_id, :integer, :null => false
    change_column :cause_balances, :cause_id, :integer, :null => false
  end
  
  def down
    remove_column :causes, :cause_identifier
    Cause.reset_column_information
    add_column :causes, :cause_identifier, :string, :null => false, :limit => 64
    
    change_column :cause_balances, :partner_id, :integer, :null => true
    change_column :cause_balances, :cause_id, :integer, :null => true
  end

  remove_index :causes, :cause_identifier
  add_index :causes, :cause_identifier, :unique => true
end

class AddCauseIdToCauseTx < ActiveRecord::Migration
  def up
    add_column :cause_transactions, :cause_identifier, :integer, :null => false
    change_column :cause_transactions, :partner_identifier, :integer, :null => false
    
    CauseTransaction.reset_column_information
    
    add_index :cause_transactions, :cause_identifier
    add_index :cause_transactions, :year
  end
  
  def down
    remove_index :cause_transactions, :cause_identifier
    remove_index :cause_transactions, :year
    
    remove_column :cause_transactions, :cause_identifier
    change_column :cause_transactions, :partner_identifier, :integer, :null => true
  end
end

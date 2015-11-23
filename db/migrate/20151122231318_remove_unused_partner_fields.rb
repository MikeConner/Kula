class RemoveUnusedPartnerFields < ActiveRecord::Migration
  def up
    remove_column :users, :partner_10_balance
    remove_column :users, :partner_11_balance
    remove_column :users, :partner_12_balance
    remove_column :users, :partner_14_balance
    remove_column :users, :partner_22_balance
    remove_column :users, :partner_24_balance
  end
  
  def down
    add_column :users, :partner_10_balance, :integer
    add_column :users, :partner_11_balance, :integer
    add_column :users, :partner_12_balance, :integer
    add_column :users, :partner_14_balance, :integer
    add_column :users, :partner_22_balance, :integer
    add_column :users, :partner_24_balance, :integer
  end
end

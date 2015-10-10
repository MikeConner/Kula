class AddCheckNumToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :check_num, :integer
    
    Payment.reset_column_information
    
    Payment.where('check_num IS NULL').each do |p|
      p.update_attribute(:check_num, p.id)
    end
    
    change_column :payments, :check_num, :integer, :null => false
  end
  
  def down
    remove_column :payments, :check_num
  end
end

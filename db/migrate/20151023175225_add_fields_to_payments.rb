class AddFieldsToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :month, :integer
    add_column :payments, :year, :integer   
    
    Payment.reset_column_information
    
    Payment.all.each do |payment|
      if 'Sent' == payment.status
        payment.update_attribute(:status, Payment::CLEARED)
      end
      
      payment.update_attributes!(:month => payment.date.month, :year => payment.date.year)
    end 
    
    change_column :payments, :month, :integer, :null => false
    change_column :payments, :year, :integer, :null => false
  end

  def down
    remove_column :payments, :month
    remove_column :payments, :year   
  end
end

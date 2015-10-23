class AddFieldsToAdjustments < ActiveRecord::Migration
  def up
    add_column :adjustments, :month, :integer
    add_column :adjustments, :year, :integer
    
    Adjustment.reset_column_information
    
    Adjustment.all.each do |adjustment|
      adjustment.update_attributes!(:month => adjustment.date.month, :year => adjustment.date.year)
    end 
    
    change_column :adjustments, :month, :integer, :null => false
    change_column :adjustments, :year, :integer, :null => false
  end
  
  def down
    remove_column :adjustments, :month
    remove_column :adjustments, :year   
  end
end

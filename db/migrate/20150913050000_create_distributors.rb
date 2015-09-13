class CreateDistributors < ActiveRecord::Migration
  def change
    create_table :distributors, :id => false do |t|
      t.integer :distributor_identifier, :null => false
      t.string :name, :null => false, :limit => 64
      t.string :display_name, :limit => 64

      t.timestamps null: false
    end
    
    add_index :distributors, :distributor_identifier, :unique => true
  end
end

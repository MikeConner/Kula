class AddRoleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role, :string, :limit => 16
    add_reference :users, :partner, :index => true  
    add_reference :users, :cause, :index => true  
  end
end

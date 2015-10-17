class AddNameIndexToCauses < ActiveRecord::Migration
  def change
    add_index :causes, :org_name
  end
end

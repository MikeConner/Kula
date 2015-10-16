class CreateReplicatedCauses < ActiveRecord::Migration
  def change
    create_table :replicated_causes do |t|

      t.timestamps null: false
    end
    
    rename_column :replicated_causes, :type, :cause_type
  end
end

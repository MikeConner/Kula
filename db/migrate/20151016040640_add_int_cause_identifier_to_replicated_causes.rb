class AddIntCauseIdentifierToReplicatedCauses < ActiveRecord::Migration
  def change
    add_column :replicated_causes, :cause_identifier, :integer
    
    add_index :replicated_causes, :cause_id, :unique => true
    add_index :replicated_causes, :cause_identifier, :unique => true
  end
end

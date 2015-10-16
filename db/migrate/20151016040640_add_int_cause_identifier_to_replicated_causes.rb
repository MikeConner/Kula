class AddIntCauseIdentifierToReplicatedCauses < ActiveRecord::Migration
  def change
    add_column :replicated_causes, :cause_identifier, :integer
    
    ReplicatedCause.reset_column_information
 
    ReplicatedCause.all.each do |cause|
      cause.cause_identifier = cause.cause_id.to_i
    end
  end
end

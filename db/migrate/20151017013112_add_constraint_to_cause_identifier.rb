class AddConstraintToCauseIdentifier < ActiveRecord::Migration
  def change
    change_column :replicated_causes, :cause_identifier, :integer, :null => false
  end
end

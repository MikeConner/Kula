class RenameCausesTable < ActiveRecord::Migration
  def change
    rename_table :replicated_causes, :causes
  end
end

class AddBatchIndices < ActiveRecord::Migration
  def change
    add_index :payments, :batch_id
    add_index :adjustments, :batch_id
  end
end

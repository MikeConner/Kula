class LengthenBatchName < ActiveRecord::Migration
  def change
    change_column :batches, :name, :string, :limit => 64
  end
end

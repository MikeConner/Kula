class AllowBiggerBatchDescription < ActiveRecord::Migration
  def up
    change_column :batches, :name, :string, :limit => 128
  end
  
  def down
    change_column :batches, :name, :string, :limit => 64
  end
end

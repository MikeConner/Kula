class IncreaseNameSizeDelayedRake < ActiveRecord::Migration
  def change
    change_column :delayed_rakes, :name, :string, :limit => 32
  end
end

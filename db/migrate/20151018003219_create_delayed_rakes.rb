class CreateDelayedRakes < ActiveRecord::Migration
  def change
    create_table :delayed_rakes do |t|
      t.integer :job_identifier
      t.string :name, :limit => 16
      t.text :params

      t.timestamps null: false
    end    
  end
end

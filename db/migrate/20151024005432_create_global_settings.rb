class CreateGlobalSettings < ActiveRecord::Migration
  def change
    create_table :global_settings do |t|
      t.date :current_period, :null => false
      t.text :other

      t.timestamps null: false
    end
  end
end

class CreateAdjustments < ActiveRecord::Migration
  def change
    create_table :adjustments do |t|
      t.references :batch
      
      t.decimal :amount, :null => false, :precision => 8, :scale => 2
      t.datetime :date
      t.text :comment

      t.timestamps
    end
  end
end

class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.references :partner
      t.references :user
      t.string :name, :limit => 32
      t.datetime :date
      t.string :description

      t.timestamps
    end
  end
end

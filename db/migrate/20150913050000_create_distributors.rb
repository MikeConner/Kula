class CreateDistributors < ActiveRecord::Migration
  def change
    create_table :distributors do |t|
      t.references :partner
      t.string :name, :null => false, :limit => 64
      t.string :display_name, :limit => 64

      t.timestamps null: false
    end
  end
end

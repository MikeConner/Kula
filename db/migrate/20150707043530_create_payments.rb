class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :batch
      
      t.string :status, :limit => 16
      t.decimal :amount, :null => false, :precision => 8, :scale => 2
      t.datetime :date
      t.string :confirmation
      t.string :payment_method, :limit => 8
      t.string :address
      t.text :comment

      t.timestamps
    end
  end
end

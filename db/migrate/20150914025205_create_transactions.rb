class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions, :id => false do |t|
      t.integer :transaction_identifier, :null => false
      t.integer :partner_identifier
      t.integer :month, :null => false
      t.integer :year, :null => false
      t.decimal :gross_amount, :precision => 8, :scale => 2
      t.decimal :net_amount, :precision => 8, :scale => 2
      t.decimal :donee_amount, :precision => 8, :scale => 2
      t.decimal :discounts_amount, :precision => 6, :scale => 2
      t.decimal :fees_amount, :precision => 6, :scale => 2
      t.decimal :calc_kula_fee, :precision => 6, :scale => 2
      t.decimal :calc_foundation_fee, :precision => 6, :scale => 2
      t.decimal :calc_distributor_fee, :precision => 6, :scale => 2

      t.timestamps null: false
    end
    
    add_index :transactions, :transaction_identifier, :unique => true
    add_index :transactions, :partner_identifier
    add_index :transactions, [:month, :year]
  end
end

class CreateReplicatedTxBalances < ActiveRecord::Migration
  def change
    create_table :replicated_tx_balances do |t|
      t.integer :partnerid
      t.integer :month
      t.integer :year
      t.decimal :grossamount
      t.decimal :discountamount
      t.decimal :netamount
      t.decimal :kulafees
      t.decimal :doneeamount
      t.integer :causeid
      t.string :causename
      t.string :country
      t.integer :causetype
      t.datetime :created

      t.timestamps null: false
    end
  end
end

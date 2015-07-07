class CreateStripeAccounts < ActiveRecord::Migration
  def change
    create_table :stripe_accounts do |t|
      t.references :cause
      t.string :token, :null => false, :limit => 32

      t.timestamps
    end
    
    add_index :stripe_accounts, :token, :unique => true
  end
end

class CreatePartners < ActiveRecord::Migration
  def change
    create_table :partners, :id => false do |t|
      t.primary_key :partner_identifier
      t.string :name, :limit => 64, :null => false
      t.string :display_name, :limit => 64, :null => false
      t.string :domain, :limit => 64, :null => false
      t.string :currency, :limit => 3, :null => false, :default => 'USD'
      
      t.timestamps
    end
  end
end

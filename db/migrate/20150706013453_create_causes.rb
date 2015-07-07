class CreateCauses < ActiveRecord::Migration
  def change
    create_table :causes, :id => false, :primary_key => 'cause_identifier' do |t|
      t.string :cause_identifier, :limit => 64, :null => false
      t.string :name, :null => false
      t.integer :cause_type, :null => false
      t.boolean :has_ach_info, :null => false, :default => false
      t.string :email
      t.string :phone, :limit => 64
      t.string :fax, :limit => 64
      t.string :tax_id, :limit => 64
      t.string :address_1, :limit => 128
      t.string :address_2, :limit => 128
      t.string :address_3, :limit => 128
      t.string :city, :limit => 64
      t.string :region, :limit => 64
      t.string :country, :limit => 2, :null => false
      t.string :postal_code, :limit => 16
      t.string :mailing_address, :limit => 128
      t.string :mailing_city, :limit => 64
      t.string :mailing_state, :limit => 64
      t.string :mailing_postal_code, :limit => 16
      t.string :site_url
      t.string :logo_url
      t.decimal :latitude
      t.decimal :longitude
      t.text :mission
          
      t.timestamps
    end
    
    add_index :causes, :cause_identifier, :unique => true
  end
end

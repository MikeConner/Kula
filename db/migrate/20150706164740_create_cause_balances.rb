class CreateCauseBalances < ActiveRecord::Migration
  def change
    create_table :cause_balances do |t|
      t.references :partner
      t.references :cause
      t.integer :year, :null => false
      t.string :cause_type, :limit => 16
      t.decimal :jan, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :feb, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :mar, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :apr, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :may, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :jun, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :jul, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :aug, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :sep, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :oct, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :nov, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :dec, :null => false, :default => 0, :precision => 8, :scale => 2
      t.decimal :total, :null => false, :default => 0, :precision => 8, :scale => 2

      t.timestamps
    end

    add_index :cause_balances, [:partner_id, :cause_id, :year, :cause_type], :unique => true, :name => 'cause_balances_primary_key'
  end
end

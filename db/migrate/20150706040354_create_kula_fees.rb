class CreateKulaFees < ActiveRecord::Migration
  def change
    create_table :kula_fees do |t|
      t.references :partner
      t.decimal :rate, :precision => 6, :scale => 3, :null => false
      t.date :effective_date
      t.date :expiration_date

      t.timestamps
    end
  end
end

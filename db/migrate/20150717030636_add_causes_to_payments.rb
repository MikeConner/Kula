class AddCausesToPayments < ActiveRecord::Migration
  def change
    add_reference :payments, :cause
    add_reference :adjustments, :cause
  end
end

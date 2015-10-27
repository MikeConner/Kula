class PaymentDefaultChange < ActiveRecord::Migration
  def change
    change_column :payments, :status, :string, :limit => 16, :null => false, :default => 'Outstanding'
  end
end

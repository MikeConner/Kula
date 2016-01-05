class UpdateAchField < ActiveRecord::Migration
  def change
    rename_column :causes, :has_ach_info, :has_eft_bank_info
  end
end

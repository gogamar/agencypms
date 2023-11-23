class FixMasterRateAndAvailability < ActiveRecord::Migration[7.0]
  def change
    remove_column :vrentals, :master_rate
    rename_column :vrentals, :master_vrental_id, :rate_master_id
    add_column :vrentals, :availability_master_id, :integer

    add_foreign_key :vrentals, :vrentals, column: :rate_master_id
    add_foreign_key :vrentals, :vrentals, column: :availability_master_id
  end
end

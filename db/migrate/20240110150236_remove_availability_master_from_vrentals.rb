class RemoveAvailabilityMasterFromVrentals < ActiveRecord::Migration[7.0]
  def change
    remove_column :vrentals, :availability_master_id
  end
end

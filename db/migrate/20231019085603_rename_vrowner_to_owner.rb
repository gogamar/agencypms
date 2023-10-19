class RenameVrownerToOwner < ActiveRecord::Migration[7.0]
  def change
    rename_table :vrowners, :owners
    rename_column :vrentals, :vrowner_id, :owner_id
    rename_index :vrentals, "index_vrentals_on_vrowner_id", "index_vrentals_on_owner_id"
  end
end

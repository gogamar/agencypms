class RenameDescription < ActiveRecord::Migration[7.0]
  def change
    rename_column :vrentals, :description, :description_ca
  end
end

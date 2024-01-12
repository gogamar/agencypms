class AddDefaultValueToFeatured < ActiveRecord::Migration[7.0]
  def change
    change_column :vrentals, :featured, :boolean, default: false
  end
end

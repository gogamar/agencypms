class AddLatLongFeaturedToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :latitude, :float
    add_column :vrentals, :longitude, :float
    add_column :vrentals, :featured, :boolean
  end
end

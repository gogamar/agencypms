class AddColumnsToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :property_type, :string
    add_column :vrentals, :min_price, :decimal, precision: 8, scale: 2
  end
end

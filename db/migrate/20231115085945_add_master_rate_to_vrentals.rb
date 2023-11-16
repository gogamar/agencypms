class AddMasterRateToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :master_rate, :boolean, default: false
    add_column :vrentals, :master_vrental_id, :integer
    add_column :vrentals, :rate_offset, :decimal
    add_column :vrentals, :rate_offset_type, :string
    add_column :vrentals, :price_per, :string
    add_column :vrentals, :weekly_discount, :decimal
    add_column :vrentals, :weekly_discount_included, :boolean, default: false
  end
end

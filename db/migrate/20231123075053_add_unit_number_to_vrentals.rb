class AddUnitNumberToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :unit_number, :integer
  end
end

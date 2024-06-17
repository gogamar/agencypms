class AddColumnsParkingAndFull < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :parking_details, :string
    add_column :cleaning_schedules, :full, :boolean, default: true
  end
end

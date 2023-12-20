class ChangeHoursToStrings < ActiveRecord::Migration[7.0]
  def change
    change_column :vrentals, :checkin_start_hour, :string
    change_column :vrentals, :checkin_end_hour, :string
    change_column :vrentals, :checkout_end_hour, :string
  end
end

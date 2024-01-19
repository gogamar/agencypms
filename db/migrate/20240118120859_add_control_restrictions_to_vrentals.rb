class AddControlRestrictionsToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :control_restrictions, :string
    add_column :vrentals, :no_checkin, :integer, default: 7
  end
end

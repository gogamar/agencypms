class UpdateAvailabilitiesTable < ActiveRecord::Migration[7.0]
  def change
    change_column :availabilities, :multiplier, :integer, default: 100
    change_column :availabilities, :override, :integer, default: 0
  end
end

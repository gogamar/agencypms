class AddLockedToBookings < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :locked, :boolean, default: false
  end
end

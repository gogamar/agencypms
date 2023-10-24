class RenameVrownerBookings < ActiveRecord::Migration[7.0]
  def change
    rename_column :vragreements, :vrowner_bookings, :owner_bookings
  end
end

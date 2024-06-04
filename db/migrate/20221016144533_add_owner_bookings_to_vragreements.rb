class AddOwnerBookingsToVragreements < ActiveRecord::Migration[7.0]
  def change
    add_column :vragreements, :owner_bookings, :text
  end
end

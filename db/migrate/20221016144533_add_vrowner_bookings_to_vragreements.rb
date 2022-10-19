class AddVrownerBookingsToVragreements < ActiveRecord::Migration[7.0]
  def change
    add_column :vragreements, :vrowner_bookings, :text
  end
end

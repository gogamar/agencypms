class AddFirstnameAndLastnameToBooking < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :firstname, :string
    add_column :bookings, :lastname, :string
  end
end

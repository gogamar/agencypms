class AddTouristToBooking < ActiveRecord::Migration[7.0]
  def change
    add_reference :bookings, :tourist, null: false, foreign_key: true
  end
end

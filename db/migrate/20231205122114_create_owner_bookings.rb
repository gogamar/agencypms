class CreateOwnerBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :owner_bookings do |t|
      t.string :status
      t.date :checkin
      t.date :checkout
      t.text :note
      t.string :beds_booking_id
      t.references :vrental, foreign_key: true

      t.timestamps
    end
  end
end

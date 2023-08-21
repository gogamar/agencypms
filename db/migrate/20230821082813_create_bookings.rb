class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.string :status
      t.date :checkin
      t.date :checkout
      t.integer :nights
      t.integer :adults
      t.integer :children
      t.string :referrer
      t.decimal :price, precision: 10, scale: 2
      t.decimal :commission, precision: 10, scale: 2
      t.string :beds_booking_id
      t.references :vrental, null: false, foreign_key: true

      t.timestamps
    end
  end
end

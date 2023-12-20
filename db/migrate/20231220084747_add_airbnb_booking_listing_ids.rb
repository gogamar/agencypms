class AddAirbnbBookingListingIds < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :airbnb_listing_id, :string
    add_column :vrentals, :bookingcom_hotel_id, :string
    add_column :vrentals, :bookingcom_room_id, :string
    add_column :vrentals, :bookingcom_rate_id, :string
  end
end

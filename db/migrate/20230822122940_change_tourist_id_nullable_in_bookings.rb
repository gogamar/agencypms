class ChangeTouristIdNullableInBookings < ActiveRecord::Migration[7.0]
  def change
    change_column_null :bookings, :tourist_id, true
  end
end

json.extract! booking, :id, :status, :checkin, :checkout, :price, :commission, :referrer, :beds_booking_id, :created_at, :updated_at
json.url booking_url(booking, format: :json)

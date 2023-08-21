json.extract! charge, :id, :description, :quantity, :price, :booking_id, :created_at, :updated_at
json.url charge_url(charge, format: :json)

json.extract! payment, :id, :description, :quantity, :price, :booking_id, :created_at, :updated_at
json.url payment_url(payment, format: :json)

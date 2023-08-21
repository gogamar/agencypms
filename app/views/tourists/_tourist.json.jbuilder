json.extract! tourist, :id, :firstname, :lastname, :phone, :email, :address, :country_code, :country, :document, :created_at, :updated_at
json.url tourist_url(tourist, format: :json)

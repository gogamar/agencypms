class Company < ApplicationRecord
  belongs_to :admin, class_name: "User", foreign_key: "user_id"
  has_many :users
  has_many :offices
  has_many :rate_plans
  # validate :user_can_create_only_one_company, on: :create

  def get_availability_from_beds(beds_owner_id, checkin, checkout, guests, prop_ids)
    begin
      client = BedsHelper::Beds.new

      options = {
        "ownerId": beds_owner_id,
        "checkIn": checkin.delete("-"),
        "checkOut": checkout.delete("-"),
        "numAdult": guests,
        "propIds": prop_ids
      }

      response = client.get_availabilities(options)

      # Handle any errors that might occur during JSON parsing or API calls
      if response.code != 200
        raise StandardError, "Error: HTTP request failed with status code #{response.code}"
      end

      parsed_response = JSON.parse(response.body)

      metadata = parsed_response.slice("checkIn", "lastNight", "checkOut", "ownerId", "numAdult")
      beds24_availabilities = parsed_response.reject { |key, _| metadata.key?(key) }

      result = []

      beds24_availabilities.each do |room_id, avail_details|
        if avail_details["roomsavail"] == 1
          vrental = Vrental.find_by(beds_prop_id: avail_details["propId"]).id
          if vrental
            property_hash = {
              vrental => avail_details["price"]
            }
            result << property_hash
          end
        end
      end

      return result
    rescue StandardError => e
      # Handle any exceptions that occurred during execution
      puts "Error: #{e.message}"
      return [] # Return an empty array or handle the error as needed
    end
  end


  private

  # def user_can_create_only_one_company
  #   if current_user&.admin? && current_user.owned_company.present?
  #     errors.add(:base, "Només es pot crear una empresa per usuari.")
  #   end
  # end
end

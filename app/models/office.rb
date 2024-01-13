class Office < ApplicationRecord
  belongs_to :company
  has_many :vrentals
  has_many :coupons
  has_many_attached :office_photos
  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :beds_key, presence: true, uniqueness: true
  validates :beds_owner_id, presence: true, uniqueness: true
  encrypts :beds_key, deterministic: true

  def import_properties_from_beds(no_import=nil, import_name)
    client = BedsHelper::Beds.new(beds_key)

    begin
      beds24rentals = client.get_properties
      # select only the ones that are not already imported
      new_beds24rentals = beds24rentals.select { |bedsrental| !Vrental.find_by(beds_prop_id: bedsrental["propId"]).present? }
      puts "these are the new beds24rentals: #{new_beds24rentals}"
      new_beds24rentals.each do |bedsrental|
        # secure_prop_key = SecureRandom.alphanumeric(16)
        # secure_prop_key = bedsrental["propId"] + "2t0h2i3s1i0s2s4ecure"
        bedsrental["roomTypes"].each do |room|

          if no_import.present?
            words_array = no_import.split(', ').map(&:downcase)
            match_found = words_array.any? do |word|
              bedsrental["name"].downcase.include?(word) || room["name"].downcase.include?(word)
            end
          end
          next if no_import.present? && match_found

          vrental_name = import_name == "property" ? bedsrental["name"] : room["name"]
          vrental = Vrental.find_by(beds_room_id: room["roomId"])
          unless vrental.present?
            # new_owner = Owner.create!(
            #   fullname: bedsrental["template1"],
            #   language: "ca",
            #   document: bedsrental["template5"],
            #   address: bedsrental["template2"],
            #   email: bedsrental["template4"],
            #   phone: bedsrental["template3"],
            #   account: bedsrental["template6"],
            #   beds_room_id: bedsrental["roomTypes"][0]["roomId"],
            #   )
            new_vrental = Vrental.create(
              name: vrental_name,
              property_type: Vrental::PROPERTY_TYPES[bedsrental["propTypeId"]],
              address: bedsrental["address"] + ', ' + bedsrental["postcode"] + ' ' + bedsrental["city"],
              beds_prop_id: bedsrental["propId"],
              beds_room_id: room["roomId"],
              max_guests: room["maxPeople"].to_i,
              # prop_key: secure_prop_key,
              status: "active",
              office_id: id,
              town_id: Town.where("name ILIKE ?", "%#{bedsrental["city"]}%").first&.id || Town.create(name: bedsrental["city"]).id,
              latitude: bedsrental["latitude"],
              longitude: bedsrental["longitude"],
              # owner: new_owner || company.admin,
              cadastre: bedsrental["template7"].present? ? bedsrental["template7"].split("/")[0] : '',
              habitability: bedsrental["template7"].present? ? bedsrental["template7"].split("/")[1] : '',
              commission: bedsrental["template8"].present? ? bedsrental["template8"] : ''
            )
          end
          # VrentalApiService.new(new_vrental).get_content_from_beds
          sleep 2
        end
      end
    rescue StandardError => e
      Rails.logger.error("Error al importar immobles de Beds24: #{e.message}")
    end
  end

  def export_properties_to_beds(encrypted_key)
    office_beds_key = get_beds_key(encrypted_key)
    client = BedsHelper::Beds.new(office_beds_key)
    beds24rentals_prop_names = Set.new(client.get_properties.map { |bedsrental| bedsrental["name"] })

    if beds24rentals_prop_names.include?(name)
      return
      # update the property on Beds
    end

    new_bedrentals = []
    new_bedrental = {
      name: name,
      prop_key: prop_key,
      roomTypes: [
        {
          name: name,
          qty: 1,
          minPrice: 30
        }
      ]
    }
    new_bedrentals << new_bedrental
    response = client.create_properties(createProperties: new_bedrentals)

    beds_prop_id = response[0]["propId"]
    beds_room_id = response[0]["roomTypes"][0]["roomId"]
    save!
  end

  def get_availability_from_beds(checkin, checkout, guests, prop_ids)
    client = BedsHelper::Beds.new
    begin
      if checkin
        formatted_checkin = Date.parse(checkin).strftime("%Y%m%d")
      end
      if checkout
        formatted_checkout = Date.parse(checkout).strftime("%Y%m%d")
      end
      options = {
        "ownerId": beds_owner_id,
        "checkIn": formatted_checkin,
        "checkOut": formatted_checkout,
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

      beds24_availabilities.each do |_room_id, avail_details|
        if avail_details["roomsavail"] != "0"
          vrental = Vrental.find_by(beds_prop_id: avail_details["propId"]).id
          if vrental
            property_hash = {
              vrental.to_s => avail_details["price"]
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

end

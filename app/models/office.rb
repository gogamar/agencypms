class Office < ApplicationRecord
  belongs_to :company
  has_many :vrentals
  validates :name, presence: true, uniqueness: { scope: :company_id }

  def import_properties_from_beds
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])

    begin
      beds24rentals = client.get_properties
      beds24rentals.each do |bedsrental|
        vrental = Vrental.find_by(beds_prop_id: bedsrental["propId"])
        unless vrental.present?
          new_vrowner = Vrowner.create!(
            fullname: bedsrental["template1"],
            language: "ca",
            document: bedsrental["template5"],
            address: bedsrental["template2"],
            email: bedsrental["template4"],
            phone: bedsrental["template3"],
            account: bedsrental["template6"],
            beds_room_id: bedsrental["roomTypes"][0]["roomId"],
            user_id: vrental.user_id
            )
          vrental = Vrental.create!(
            name: bedsrental["name"],
            address: bedsrental["address"] + ', ' + bedsrental["postcode"] + ' ' + bedsrental["city"],
            beds_prop_id: bedsrental["propId"],
            beds_room_id: bedsrental["roomTypes"][0]["roomId"],
            max_guests: bedsrental["roomTypes"][0]["maxPeople"].to_i,
            user_id: current_user.id,
            prop_key: bedsrental["name"].delete(" ").delete("'").downcase + "2022987123654",
            status: "active",
            office_id: id,
            town_id: Town.find_by(name: bedsrental["city"])&.id || Town.create(name: bedsrental["city"]).id,
            vrowner: new_vrowner,
            cadastre: bedsrental["template7"].split("/")[0],
            habitability: bedsrental["template7"].split("/")[1],
            commission: bedsrental["template8"],
            permit: bedsrental["permit"]
          )
        end
        vrental.get_content_from_beds
        sleep 2
      end
    rescue StandardError => e
      Rails.logger.error("Error al importar immobles de Beds24: #{e.message}")
    end
  end

  def export_properties_to_beds
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])
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
end

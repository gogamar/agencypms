class Office < ApplicationRecord
  belongs_to :company
  has_many :vrentals
  validates :name, presence: true, uniqueness: { scope: :company_id }

  def import_properties_from_beds
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])

    begin
      beds24rentals = client.get_properties
      puts "This is the first property: #{beds24rentals.first}"
      beds24rentals.each do |bedsrental|
        vrental = Vrental.find_by(beds_prop_id: bedsrental["propId"])
        puts "this is the vrental: #{vrental}"
        if vrental
          vrental.update!(
            name: bedsrental["name"],
            address: bedsrental["address"] + ', ' + bedsrental["postcode"] + ' ' + bedsrental["city"],
            max_guests: bedsrental["roomTypes"][0]["maxPeople"].to_i,
            status: "active",
            office_id: id,
            town_id: Town.find_by(name: bedsrental["city"])&.id || Town.create(name: bedsrental["city"]).id
          )
        else
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
            town_id: Town.find_by(name: bedsrental["city"])&.id || Town.create(name: bedsrental["city"]).id
          )
        end
        get_content_from_beds(vrental)
        # remove
        break
        sleep 2
      end
    rescue StandardError => e
      Rails.logger.error("Error al importar immobles de Beds24: #{e.message}")
    end
  end

  def get_content_from_beds(vrental)
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])
    prop_key = vrental.prop_key
    begin
      beds24content = client.get_property_content(prop_key, images: true, roomIds: true, texts: true)
      if beds24content[0]["roomIds"]
        vrental.update!(
          description_ca: beds24content[0]["roomIds"].first[1]["texts"]["contentDescriptionText"]["CA"],
          description_es: beds24content[0]["roomIds"].first[1]["texts"]["contentDescriptionText"]["ES"],
          description_fr: beds24content[0]["roomIds"].first[1]["texts"]["contentDescriptionText"]["FR"],
          description_en: beds24content[0]["roomIds"].first[1]["texts"]["contentDescriptionText"]["EN"]
        )
        puts "Imported descriptions for #{vrental.name}!"
      end

      if beds24content[0]["images"]["external"].present?
        beds24photos = beds24content[0]["images"]["external"].select { |key, image| image["url"] != "" }
        beds24_image_urls = beds24photos.map { |key, image| image["url"] }
        vrental.image_urls.each do |image_url|
          unless beds24_image_urls.include?(image_url.url)
            image_url.destroy
          end
        end

        beds24photos.each do |key, image|
          image_url = vrental.image_urls.find_by(url: image["url"])
          if image_url
            image_url.update!(
              order: key.to_i,
            )
          else
            ImageUrl.create!(
              url: image["url"],
              order: key.to_i,
              vrental_id: vrental.id
            )
          end
        end
        puts "Imported images for #{vrental.name}!"
      end

      if beds24content[0]["roomIds"].first[1]["featureCodes"].present?
        beds24bedrooms = beds24content[0]["roomIds"].first[1]["featureCodes"].select { |feature| feature.any? { |word| word.starts_with?("BEDROOM") } }

        beds24bedrooms.each_with_index do |room_data, index|
          room_type = room_data.select { |word| word.starts_with?("BEDROOM") }.first
          room_bed_types = room_data.select { |word| word.starts_with?("BED_") }

          bedroom = vrental.bedrooms[index]

          if bedroom
            room_bed_types.each do |bed_type|
              bedroom.beds.find_or_create_by(bed_type: bed_type, bedroom: bedroom)
            end
          else
            bedroom = vrental.bedrooms.create!(bedroom_type: room_type, vrental_id: vrental.id)
            room_bed_types.each do |bed_type|
              bedroom.beds.create!(bed_type: bed_type, bedroom: bedroom)
            end
          end
        end

        if beds24bedrooms.length < vrental.bedrooms.length
          vrental.bedrooms.last(vrental.bedrooms.length - beds24bedrooms.length).each do |bedroom|
            bedroom.destroy
          end
        end

        beds24bathrooms = beds24content[0]["roomIds"].first[1]["featureCodes"].select { |feature| feature.any? { |word| word.starts_with?("BATHROOM") } }

        puts "these are the bathrooms needs selecting: #{beds24content[0]["roomIds"].first[1]["featureCodes"]}"

        beds24bathrooms.each_with_index do |bathroom_data, index|
          bathroom = vrental.bathrooms[index]
          bathroom_type = case
          when bathroom_data.include?("BATH_TUB")
            "BATH_TUB"
          when bathroom_data.include?("BATH_SHOWER")
            "BATH_SHOWER"
          else
            "TOILET"
          end

          if bathroom && bathroom.bathroom_type != bathroom_type
            bathroom.update!(bathroom_type: bathroom_type)
          else
            vrental.bathrooms.create!(bathroom_type: bathroom_type, vrental_id: self.id)
          end
        end

        if beds24bathrooms.length < vrental.bathrooms.length
          vrental.bathrooms.last(vrental.bathrooms.length - beds24bedrooms.length).each do |bathroom|
            bathroom.destroy
          end
        end
        puts "Imported bedrooms and bathrooms for #{vrental.name}!"
      end
    rescue => e
      puts "Error importing content for #{vrental.name}: #{e.message}"
    end
    sleep 2
  end
end

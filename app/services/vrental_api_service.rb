class VrentalApiService
  def initialize(vrental)
    @vrental = vrental
  end

  # return error messages to controller so that an appropriate flash message can be displayed

  def get_availability_from_beds(checkin, checkout, guests)
    vrental_instance = @vrental.availability_master.present? ? @vrental.availability_master : @vrental
    begin
      client = BedsHelper::Beds.new

      if checkin
        formatted_checkin = Date.parse(checkin).strftime("%Y%m%d")
      end
      if checkout
        formatted_checkout = Date.parse(checkout).strftime("%Y%m%d")
      end

      options = {
        "propId": vrental_instance.beds_prop_id,
        "checkIn": formatted_checkin,
        "checkOut": formatted_checkout,
        "numAdult": guests || 1
      }

      response = client.get_availabilities(options)

      if response.code != 200
        raise StandardError, "Error: HTTP request failed with status code #{response.code}"
      end

      parsed_response = JSON.parse(response.body)

      result = {}
      if parsed_response[vrental_instance.beds_room_id]["roomsavail"] != "0"
        vrental_rate_price = vrental_instance.rate_price(checkin, checkout)
        updated_price = parsed_response[vrental_instance.beds_room_id]["price"]
        coupon_price = vrental_instance.price_with_coupon(updated_price)
        result["ratePrice"] = vrental_rate_price.round(2) if vrental_rate_price
        result["updatedPrice"] = updated_price
        result["couponPrice"] = coupon_price.round(2).to_f if coupon_price
        if (parsed_response[vrental_instance.beds_room_id]["price"]).nil?
          result["notAvailable"] = "No availability"
        end
      elsif parsed_response[vrental_instance.beds_room_id]["roomsavail"] == "0"
        result["notAvailable"] = "No availability"
      end
      puts "this is the result: #{result}"
      return result

    rescue StandardError => e
      puts "Error: #{e.message}"
      return {}
    end
  end

  def update_vrental_from_beds
    client = BedsHelper::Beds.new(@vrental.office.beds_key)
    begin
      property = client.get_property(@vrental.prop_key, includeRooms: true)[0]
      vrental_room = property["roomTypes"].find { |room| room["roomId"] == @vrental.beds_room_id }
        @vrental.update!(
          # name: property["name"],
          property_type: PROPERTY_TYPES[property["propTypeId"]],
          address: property["address"] + ', ' + property["postcode"] + ' ' + property["city"],
          max_guests: vrental_room["maxPeople"].to_i,
          status: "active",
          town_id: Town.where("name ILIKE ?", "%#{property["city"]}%").first&.id || Town.create(name: property["city"]).id
        )
        sleep 2
      get_content_from_beds
      sleep 2
    rescue StandardError => e
      Rails.logger.error("Error al importar canvis de Beds24: #{e.message}")
    end
  end

  def update_vrental_on_beds
    client = BedsHelper::Beds.new(@vrental.office.beds_key)
    beds24rentals_prop_names = Set.new(client.get_properties.map { |bedsrental| bedsrental["name"] })

    if beds24rentals_prop_names.include?(@vrental.name)
      bedsrental = [
          {
            "action": "modify",
            "roomTypes": [
              {
                "action": "modify",
                "roomId": @vrental.beds_room_id
              }.merge(@vrental.beds_room_type)
            ]
          }
      ]
      client.set_property(@vrental.prop_key, setProperty: bedsrental)
    else
      new_bedrentals = []
      new_bedrental = {
        name: @vrental.name,
        prop_key: @vrental.prop_key,
        roomTypes: [
          @vrental.beds_room_type
        ]
      }
      new_bedrentals << new_bedrental
      response = client.create_properties(createProperties: new_bedrentals)

      @vrental.beds_prop_id = response[0]["propId"]
      @vrental.beds_room_id = response[0]["roomTypes"][0]["roomId"]
      @vrental.save!
    end
  end

  def delete_non_valid_images_on_beds
    client = BedsHelper::Beds.new(office.beds_key)
    begin
      beds24photos_property = get_property_photos_from_beds
      beds24photos_room = get_room_photos_from_beds

      beds24photos = beds24photos_property.merge(beds24photos_room)

      valid_photos = []

      beds24photos.each do |key, photo|
        url = URI.parse(photo["url"])
        response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
          http.head(url.path)
        end
        if response.code.to_i == 200
          valid_photos << url.to_s
        end
      end

      external = {}

      valid_photos = valid_photos.uniq

      valid_photos.each_with_index do |url, index|
        external["#{index + 1}"] = {
          url: url,
          map: [
            {
              propId: "#{@vrental.beds_prop_id}",
              position: "#{index + 1}"
            }
          ]
        }
      end

      (valid_photos.length + 1).upto(99) do |index|
        external["#{index}"] = {
          url: "",
          map: [
            {
              propId: "#{@vrental.beds_prop_id}",
              position: "#{index}"
            }
          ]
        }
      end

      images_array = []
      property_images = {
        action: "modify",
        images: {
          external: external
        }
      }
      images_array << property_images

      client.set_property_content(@vrental.prop_key, setPropertyContent: images_array)
    rescue => e
      puts "Error deleting photos for #{@vrental.name}: #{e.message}"
    end
    sleep 2
  end

  def import_photos_from_beds
    beds24photos_property = get_property_photos_from_beds
    beds24photos_room = get_room_photos_from_beds

    beds24photos = beds24photos_property.merge(beds24photos_room)

    valid_photos = []

    beds24photos.each do |key, photo|
      url = URI.parse(photo["url"])
      response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
        http.head(url.path)
      end
      if response.code.to_i == 200
        valid_photos << {"url" => url.to_s, "position" => photo["map"][0]["position"]}
      end
    end

    valid_photos = valid_photos.uniq
    valid_photos.each do |photo_hash|
      new_url = photo_hash["url"]

      if new_url.include?('cloudinary') && !new_url.include?('/upload/q_auto:good/')
        new_url.gsub!('/upload/', '/upload/q_auto:good/')
      end

      image_url = @vrental.image_urls.find_or_initialize_by(url: new_url)

      if image_url.persisted?
        image_url.update!(position: photo_hash["position"])
      else
        image_url.position = photo_hash["position"]
        image_url.vrental_id = @vrental.id
        image_url.save!
      end
    end
  end

  def send_photos_to_beds
    images_array = []
    external = {}

    @vrental.image_urls.each_with_index do |image, index|
      if image.url.include?("cloudinary") && !image.url.include?("q_auto:good")
        url = image.url.gsub(/\/upload\//, '/upload/q_auto:good/')
      else
        url = image.url
      end
      external["#{index + 1}"] = {
        url: url,
        map: [
          {
            propId: "#{@vrental.beds_prop_id}",
            position: "#{image.position}"
          }
        ]
      }
    end

    if @vrental.town.present? && @vrental.town.photos.attached?
      @vrental.town.photos.each do |photo|
        external["#{external.length + 1}"] = {
          url: photo.url.gsub(/\/upload\//, '/upload/q_auto:good/'),
          map: [
            {
              propId: "#{@vrental.beds_prop_id}",
              position: "#{external.length + 1}"
            }
          ]
        }
      end
    end

    empty_spaces = 99 - external.length

    empty_spaces.times do |i|
      external["#{external.length + 1}"] = {
        url: "",
        map: [
          {
            propId: "#{@vrental.beds_prop_id}",
            position: "#{external.length + 1}"
          }
        ]
      }
    end

    property_images = {
      action: "modify",
      images: {
        external: external
      }
    }
    images_array << property_images

    client = BedsHelper::Beds.new(@vrental.office.beds_key)
    client.set_property_content(@vrental.prop_key, setPropertyContent: images_array)
  end

  def update_owner_from_beds
    client = BedsHelper::Beds.new(@vrental.office.beds_key)
    begin
      property = client.get_property(@vrental.prop_key)[0]
      existing_owner = Owner.find_by(fullname: property["template1"])
      if @vrental.owner.present?
        if existing_owner.present? && existing_owner != @vrental.owner
          @vrental.update!(owner: existing_owner)
        elsif existing_owner.present? && existing_owner == @vrental.owner
          @vrental.owner.update!(
            fullname: property["template1"],
            document: property["template5"],
            address: property["template2"],
            email: property["template4"],
            phone: property["template3"],
            account: property["template6"],
            beds_room_id: property["roomTypes"][0]["roomId"],
            )
        end
      elsif !@vrental.owner.present? && existing_owner.present?
        @vrental.update!(owner: existing_owner)
      else
        Owner.create!(
          fullname: property["template1"],
          language: "ca",
          document: property["template5"],
          address: property["template2"],
          email: property["template4"],
          phone: property["template3"],
          account: property["template6"],
          beds_room_id: property["roomTypes"][0]["roomId"],
          user: @vrental.user,
          vrental_id: @vrental.id
          )
      end
      sleep 2
    rescue StandardError => e
      Rails.logger.error("Error al importar propietari de Beds24: #{e.message}")
    end
  end

  def get_content_from_beds
    # add check for minimum stay, and set min_stay and rental_term accordingly
    # also get the booking conditions (deposit payment (30%?) cancellation policy (14 days?))
    # also set status to inactive if no rates or no bookings this year, whatever's easier
    client = BedsHelper::Beds.new(@vrental.office.beds_key)
    begin
      vrental_property = client.get_property_content(@vrental.prop_key, roomIds: true, texts: true, includeAirbnb: true)[0]
      vrental_room = vrental_property["roomIds"][@vrental.beds_room_id]

      @vrental.update!(
        licence: vrental_property["permit"],
        title_ca: vrental_room["airbnb"]["name"]["CA"].present? ? vrental_room["airbnb"]["name"]["CA"] : vrental_room["texts"]["contentHeadlineText"]["CA"],
        title_es: vrental_room["airbnb"]["name"]["ES"].present? ? vrental_room["airbnb"]["name"]["ES"] : vrental_room["texts"]["contentHeadlineText"]["ES"],
        title_fr: vrental_room["airbnb"]["name"]["FR"].present? ? vrental_room["airbnb"]["name"]["FR"] : vrental_room["texts"]["contentHeadlineText"]["FR"],
        title_en: vrental_room["airbnb"]["name"]["EN"].present? ? vrental_room["airbnb"]["name"]["EN"] : vrental_room["texts"]["contentHeadlineText"]["EN"],
        description_ca: vrental_room["texts"]["contentDescriptionText"]["CA"].present? ? vrental_room["texts"]["contentDescriptionText"]["CA"] : vrental_room["airbnb"]["summaryText"]["CA"],
        description_es: vrental_room["texts"]["contentDescriptionText"]["ES"].present? ? vrental_room["texts"]["contentDescriptionText"]["ES"] : vrental_room["airbnb"]["summaryText"]["ES"],
        description_fr: vrental_room["texts"]["contentDescriptionText"]["FR"].present? ? vrental_room["texts"]["contentDescriptionText"]["FR"] : vrental_room["airbnb"]["summaryText"]["FR"],
        description_en: vrental_room["texts"]["contentDescriptionText"]["EN"].present? ? vrental_room["texts"]["contentDescriptionText"]["EN"] : vrental_room["airbnb"]["summaryText"]["EN"]
      )

      if vrental_room["featureCodes"].present?
        accepted_features = Feature::FEATURES
        # beds24features = vrental_room["featureCodes"].flatten.map(&:downcase)
        beds24features = vrental_room["featureCodes"].flatten.map do |code|
          code.downcase == 'ocean_view' ? 'sea_view' : code.downcase
        end

        selected_features = beds24features.select { |feature| accepted_features.include?(feature) }

        if selected_features.include?("beach_view")
          @vrental.features << Feature.where(name: "sea_view")
        end

        selected_features.each do |feature|
          existing_feature = Feature.find_or_create_by(name: feature)
          @vrental.features << existing_feature unless @vrental.features.include?(existing_feature)
        end

        @vrental.save!

        @vrental.features.each do |feature|
          unless selected_features.include?(feature.name)
            @vrental.features.delete(feature)
            @vrental.save!
          end
        end

        beds24bedrooms = vrental_room["featureCodes"].select { |feature| feature.any? { |word| word.starts_with?("BEDROOM") } }

        beds24bedrooms.each_with_index do |room_data, index|
          room_type = room_data.select { |word| word.starts_with?("BEDROOM") }.first
          room_bed_types = room_data.select { |word| word.starts_with?("BED_") }

          bedroom = @vrental.bedrooms[index]

          if bedroom
            room_bed_types.each do |bed_type|
              bedroom.beds.find_or_create_by(bed_type: bed_type, bedroom: bedroom)
            end
          else
            bedroom = @vrental.bedrooms.create!(bedroom_type: room_type, vrental_id: id)
            room_bed_types.each do |bed_type|
              bedroom.beds.create!(bed_type: bed_type, bedroom: bedroom)
            end
          end
        end

        if beds24bedrooms.length < @vrental.bedrooms.length
          @vrental.bedrooms.last(@vrental.bedrooms.length - beds24bedrooms.length).each do |bedroom|
            bedroom.destroy
          end
        end

        beds24bathrooms = vrental_room["featureCodes"].select { |feature| feature.any? { |word| word.starts_with?("BATHROOM") } }
        existing_bathrooms = {}
        @vrental.bathrooms.each { |bathroom| existing_bathrooms[bathroom.bathroom_type] ||= [] }
        @vrental.bathrooms.each { |bathroom| existing_bathrooms[bathroom.bathroom_type] << bathroom }

        beds24bathrooms.each do |bathroom_data|
          bathroom_type = case
          when bathroom_data.include?("BATH_TUB")
            "BATH_TUB"
          when bathroom_data.include?("BATH_SHOWER")
            "BATH_SHOWER"
          else
            "TOILET"
          end

          if existing_bathrooms.key?(bathroom_type) && existing_bathrooms[bathroom_type].any?
            existing_bathrooms[bathroom_type].shift.update!(bathroom_type: bathroom_type)
          else
            @vrental.bathrooms.create!(bathroom_type: bathroom_type, vrental_id: id)
          end
        end
        existing_bathrooms.values.flatten.each(&:destroy)
      end
    rescue => e
      puts "Error importing content for #{@vrental.name}: #{e.message}"
    end
    sleep 2
  end

  def get_availabilities_from_beds_24
    master_availability_vrental = @vrental.availability_master.present? ? @vrental.availability_master : @vrental

    master_future_rates = master_availability_vrental.rate_master.present? ? master_availability_vrental.rate_master.future_rates : master_availability_vrental.future_rates

    return if master_future_rates.empty?

    last_rate_lastnight = master_future_rates.order(lastnight: :desc).first.lastnight
    options = {
      "roomId": master_availability_vrental.beds_room_id,
      "from": Date.today.strftime("%Y%m%d").to_s,
      "to": last_rate_lastnight.strftime("%Y%m%d").to_s,
      "incMultiplier": 1,
      "incOverride": 1,
      "allowInventoryNegative": 1
    }

    client = BedsHelper::Beds.new(master_availability_vrental.office.beds_key)

    begin
      availability_data = client.get_room_dates(master_availability_vrental.prop_key, options)
      availability_data.each do |date, attributes|
        formatted_date = Date.parse(date.to_s)
        existing_availability = @vrental.availabilities.find_by(date: formatted_date)
        if existing_availability
          existing_availability.update!(
            inventory: attributes["i"].to_i,
            multiplier: attributes["x"].to_i || 100,
            override: attributes["o"].to_i || 0
          )
        else
          Availability.create(
            date: formatted_date,
            inventory: attributes["i"].to_i,
            multiplier: attributes["x"].to_i || 100,
            override: attributes["o"].to_i || 0,
            vrental_id: @vrental.id
          )
        end
      end
    rescue => e
      puts "Error importing availability data for #{master_availability_vrental.name}: #{e.message}"
    end
    sleep 2
  end

  def prevent_gaps_on_beds(days_after_checkout)
    return if @vrental.future_bookings.empty?
    master_availability_vrental = @vrental.availability_master.present? ? @vrental.availability_master : @vrental
    master_future_rates = master_availability_vrental.rate_master.present? ? master_availability_vrental.rate_master.future_rates : master_availability_vrental.future_rates
    last_rate_lastnight = master_future_rates.order(lastnight: :desc).first.lastnight
    checkout_date = @vrental.bookings.order(checkin: :desc).first.checkout
    no_check_in_from = checkout_date + days_after_checkout.days

    dates = {}

    # reset the dates from checkout to no_check_in_from
    (checkout_date...no_check_in_from).each do |date|
      availability = @vrental.availabilities.find_or_create_by(date: date)
      availability.update(override: 0)
      dates[availability.date.strftime("%Y%m%d")] = {
        "o": availability.override.to_s
      }
    end

    (no_check_in_from..last_rate_lastnight).each do |date|
      availability = @vrental.availabilities.find_or_create_by(date: date)
      availability.update(override: 2)
      dates[availability.date.strftime("%Y%m%d")] = {
        "o": availability.override.to_s
      }
    end

    options = {
      "roomId": @vrental.beds_room_id,
      "dates": dates
    }
    client = BedsHelper::Beds.new(@vrental.office.beds_key)
    begin
      set_availability_data = client.set_room_dates(@vrental.prop_key, options)
    rescue => e
      puts "Error preventing gaps for #{@vrental.name}: #{e.message}"
    end
    sleep 2
  end

  def send_availabilities_to_beds_24
    # this one needs fixing!
    master_vrental = @vrental.availability_master.present? ? @vrental.availability_master : @vrental
    client = BedsHelper::Beds.new(master_vrental.office.beds_key)

    master_future_rates = master_vrental.rate_master.present? ? master_vrental.rate_master.future_rates : master_vrental.future_rates

    last_rate_lastnight = master_future_rates.order(lastnight: :desc).first.lastnight

    dates = {}

    master_vrental.availabilities.each do |availability|
      dates[availability.date.strftime("%Y%m%d")] = {
        "x": availability.multiplier.to_s,
        "o": availability.override.to_s
      }
    end

    options = {
      "roomId": master_vrental.beds_room_id,
      "dates": dates
    }

    set_availability_data = client.set_room_dates(@vrental.prop_key, options)

    begin
      availability_data = client.get_room_dates(master_vrental.prop_key, options)
      availability_data.each do |date, attributes|
        formatted_date = Date.parse(date.to_s)
        existing_availability = @vrental.availabilities.find_by(date: formatted_date)
        if existing_availability
          existing_availability.update!(
            inventory: attributes["i"],
            multiplier: attributes["x"],
            override: attributes["o"]
          )
        else
          Availability.create(
            date: formatted_date,
            inventory: attributes["i"].to_i,
            multiplier: attributes["x"].to_i,
            override: attributes["o"],
            vrental_id: @vrental.id
          )
        end
      end
    rescue => e
      puts "Error importing availability data for #{@vrental.name}: #{e.message}"
    end
    sleep 2
  end

  def get_bookings_from_beds(from_date = nil)
    from_date = from_date || Date.today.beginning_of_year.to_s
    client = BedsHelper::Beds.new(@vrental.office.beds_key)
    options = {
      "arrivalFrom": from_date,
      # "arrivalTo": Date.today.to_s,
      "includeInvoice": true,
    }
    beds24bookings = client.get_bookings(@vrental.prop_key, options)

    if beds24bookings.success?
      parsed_response = beds24bookings.parsed_response
      found_error = false
      if parsed_response.is_a?(Hash) && parsed_response.key?("error")
        found_error = true
        error_message = parsed_response["error"]
        error_code = parsed_response["errorCode"]
        return error_message
      end

      unless found_error
        if beds24bookings.empty?
          return
        end

        confirmed_bookings = beds24bookings.select { |beds_booking| beds_booking["status"] == "1" || beds_booking["status"] == "2" }
        cancelled_bookings = beds24bookings.select { |beds_booking| beds_booking["status"] == "0" }
        cancelled_bookings_with_positive_payments = cancelled_bookings.select do |beds_booking|
          total_payment = beds_booking["invoice"]&.select { |item| item["qty"] == "-1" }.sum { |item| item["price"].to_f }
          total_payment > 0
        end

        selected_bookings = confirmed_bookings + cancelled_bookings_with_positive_payments

        selected_bookings.each do |beds_booking|
          if booking = @vrental.bookings.find_by(beds_booking_id: beds_booking["bookId"].to_i)
            if !beds_booking["guestEmail"].blank?
              existing_tourist = Tourist.find_by(email: beds_booking["guestEmail"])
              add_tourist_to_booking(beds_booking, existing_tourist)
            else
              tourist = nil
            end

            update_booking(booking, beds_booking, tourist)

            destroy_deleted_charges_payments(booking, beds_booking["invoice"])
            update_charges_and_payments(booking, beds_booking["invoice"])
            add_description_charges_payments(booking)
            add_earning(booking)
          else
            if !beds_booking["guestEmail"].blank?
              existing_tourist = Tourist.find_by(email: beds_booking["guestEmail"])

              add_tourist_to_booking(beds_booking, existing_tourist)
            else
              tourist = nil
            end

            booking = add_booking(beds_booking, tourist)

            if beds_booking["invoice"]&.empty?
              next
            else
              beds_booking["invoice"].each do |entry|
                create_charges_and_payments(booking, entry)
              end
              add_description_charges_payments(booking)
            end
            add_earning(booking)
          end
        end

        bookings_to_delete = @vrental.bookings.where('checkin >= ?', from_date.to_date).where.not(beds_booking_id: selected_bookings.map { |beds_booking| beds_booking['bookId'] })

        if bookings_to_delete.any?
          bookings_to_delete.destroy_all
        end
      end
    else
      return
    end
    sleep 3
  end

  def delete_this_year_rates_on_beds
    client = BedsHelper::Beds.new(@vrental.office.beds_key)
    beds24rates = client.get_rates(@vrental.prop_key)
    rates_to_delete = []
    beds24rates.each do |rate|
      if rate["lastNight"].to_date > Date.today
        rate_to_delete = {
          action: "delete",
          rateId: "#{rate["rateId"]}",
          roomId: "#{rate["roomId"]}"
      }
        rates_to_delete << rate_to_delete
      end
    end
    client.set_rates(@vrental.prop_key, setRates: rates_to_delete)
    rates_to_send_again = Rate.where("lastnight > ?", Date.today)
    rates_to_send_again.each do |rate|
      rate.sent_to_beds = nil
      rate.date_sent_to_beds = nil
      rate.save!
    end
  end

  def get_rates_from_beds
    client = BedsHelper::Beds.new(@vrental.office.beds_key)

    beds24rates = client.get_rates(@vrental.prop_key)

    if beds24rates.success?
      parsed_response = beds24rates.parsed_response
      found_error = false
      if parsed_response.is_a?(Hash) && parsed_response.key?("error")
        found_error = true
        error_message = parsed_response["error"]
        return error_message
      end

      unless found_error
        if beds24rates.empty?
          return
        end
        selected_rates = []

        if @vrental.price_per == "week"
          selected_rates.concat(beds24rates.select { |rate| rate["pricesPer"] == "7" && rate["restrictionStrategy"] == "0"  })
        elsif @vrental.price_per == "night"
          selected_rates.concat(beds24rates.select { |rate| rate["pricesPer"] == "1" && rate["restrictionStrategy"] == "0" })
        end

        selected_rates.each do |rate|
          if Date.parse(rate["lastNight"]) > Date.today.last_year

            existing_rate = @vrental.rates.find_by(beds_rate_id: rate["rateId"])
            if existing_rate
              existing_rate.update!(
                firstnight: rate["firstNight"],
                lastnight: rate["lastNight"],
                pricenight: @vrental.price_per == "night" ? rate["roomPrice"].to_f : nil,
                priceweek: @vrental.price_per == "week" ? rate["roomPrice"].to_f : nil,
                beds_room_id: rate["roomId"],
                min_stay: rate["minNights"].to_i,
                arrival_day: 'everyday'
              )
              if rate["pricesPer"] == "7"
                existing_rate.create_nightly_rate unless @vrental.rates.find_by(weekly_rate_id: existing_rate.id).present?
              end
            else
              new_rate = Rate.create!(
                beds_rate_id: rate["rateId"],
                vrental_id: @vrental.id,
                firstnight: rate["firstNight"],
                lastnight: rate["lastNight"],
                pricenight: rate["pricesPer"] == "1" ? rate["roomPrice"].to_f : nil,
                priceweek: rate["pricesPer"] == "7" ? rate["roomPrice"].to_f : nil,
                beds_room_id: rate["roomId"],
                min_stay: rate["minNights"].to_i,
                arrival_day: 'everyday'
              )
              if rate["pricesPer"] == "7"
                new_rate.create_nightly_rate
              end
            end
          end
        end

        selected_beds_rate_ids = selected_rates.map { |rate| rate["rateId"] }
        rates_to_delete = @vrental.rates.where.not(beds_rate_id: selected_beds_rate_ids)
        rates_to_delete.destroy_all
      else
        return
      end
    end

    rate_years = @vrental.rates.map(&:firstnight).map(&:year).uniq

    # fixme temporary fix for estartit
    if @vrental.office.name.downcase.include?('estartit')
      rate_years.each do |year|
        first_july = Date.new(year, 7, 1)
        first_august = Date.new(year, 8, 1)

        second_sat_july = first_july + (6 - first_july.wday) + 7
        last_friday_august = first_august + (5 - first_august.wday) + 21

        @vrental.rates.each do |rate|
          if rate.firstnight >= second_sat_july && rate.lastnight <= last_friday_august
            rate.min_stay = 7
            rate.arrival_day = "saturdays"
          else
            rate.min_stay = 5
          end
          rate.save!
        end
      end
    end
  end

  def send_rates_to_beds
    client = BedsHelper::Beds.new(@vrental.office.beds_key)

    beds24rates = client.get_rates(@vrental.prop_key)
    # Then we select the rates older than 2 years for deletion
    rates_to_delete = []

    beds24rates.each do |rate|
      if rate["firstNight"].to_date.year < (Date.today.year - 2) || !@vrental.future_rates.pluck(:beds_rate_id).include?(rate['rateId'])
        rate_to_delete = {
          action: "delete",
          rateId: "#{rate["rateId"]}",
          roomId: "#{rate["roomId"]}"
      }
        rates_to_delete << rate_to_delete
      end
    end

    client.set_rates(@vrental.prop_key, setRates: rates_to_delete)

    vrental_rates = []

    @vrental.future_rates.each do |rate|
      rate_exists_on_beds_id = beds24rates.any? { |beds_rate| beds_rate["rateId"] == rate.beds_rate_id }

      if rate.restriction.present?
        rate_restriction = rate.restriction == "gap_fill" ? "2" : "0"
      end

      vrental_rate =
        {
        action: rate_exists_on_beds_id ? "modify" : "new",
        roomId: "#{@vrental.beds_room_id}",
        firstNight: "#{rate.firstnight}",
        lastNight: "#{rate.lastnight}",
        name: "Tarifa #{rate.restriction.present? && rate.restriction == 'gap_fill' ? 'omplir forats' : ''} #{rate.pricenight.present? ? 'per nit' : 'setmanal'} #{I18n.l(rate.firstnight, format: :short)} - #{I18n.l(rate.lastnight, format: :short)} #{@vrental.weekly_discount.present? ? @vrental.weekly_discount.to_s + '% descompte setmanal només web propia' : ''}",
        minNights: rate.pricenight.present? ? rate.min_stay.to_s : "7",
        maxNights: rate.max_stay.present? ? rate.max_stay.to_s : "365",
        minAdvance: rate.min_advance.to_s,
        restrictionStrategy: rate_restriction,
        allowEnquiry: "1",
        pricesPer: rate.pricenight.present? ? "1" : "7",
        color: "#{SecureRandom.hex(3)}",
        roomPrice: rate.pricenight.present? ? rate.pricenight : rate.priceweek,
        roomPriceEnable: "1",
        roomPriceGuests: "0",
        disc6Nights: "7",
        disc6Percent: @vrental.weekly_discount.present? ? @vrental.weekly_discount.to_s : "0"
        }
      vrental_rates << vrental_rate
    end

    response = client.set_rates(@vrental.prop_key, setRates: vrental_rates)
    return unless response.code == 200

    if @vrental.vrgroup.present? && @vrental.rate_master_id.nil?
      rate_links = []
      @vrental.future_rates.each do |rate|
        beds24_rate_links = client.get_rate_links(@vrental.prop_key, rateId: rate.beds_rate_id)

        @vrental.vrgroup.vrentals.where(rate_master_id: @vrental.id).each do |linked_vrental|
          this_link_exists = beds24_rate_links.any? { |link| link["rateId"] == rate.beds_rate_id && link["roomId"] == linked_vrental.beds_room_id }
          rate_link = {
            "action": this_link_exists ? "modify" : "new",
            "rateId": rate.beds_rate_id,
            "roomId": linked_vrental.beds_room_id,
            "offerId": "1",
            "linkType": linked_vrental.rate_offset.present? ? "1" : "5",
            "offset": linked_vrental.rate_offset.present? ? linked_vrental.rate_offset.to_s : "",
          }
          rate_links << rate_link
        end
      end
      client.set_rate_links(@vrental.prop_key, setRateLinks: rate_links)
    end

    # fixme: need to rescue errors here

    @vrental.future_rates.each do |rate|
      rate.sent_to_beds = true
      rate.date_sent_to_beds = Time.zone.now
      rate.save!
    end
  end

  private

  attr_reader :vrental

  def api_call_get_property_content
    @cached_property_content ||= nil
    if @cached_property_content.nil?
      client = BedsHelper::Beds.new(@vrental.office.beds_key)
      begin
        @cached_property_content = client.get_property_content(@vrental.prop_key, images: true, roomIds: true)[0]
      rescue => e
        puts "Error getting property content for #{@vrental.name}: #{e.message}"
      end
      sleep 2
    end

    @cached_property_content
  end

  def get_property_photos_from_beds
    beds24content = api_call_get_property_content
    if beds24content
      return beds24content["images"]["external"].select { |key, image| image["url"] != "" }
    else
      return {}
    end
  end

  def get_room_photos_from_beds
    beds24content = api_call_get_property_content

    if beds24content
      return beds24content["roomIds"][@vrental.beds_room_id]["images"]["external"].select { |key, image| image["url"] != "" }
    else
      return {}
    end
  end

  def add_booking(beds_booking, tourist)
    status = beds_booking["status"] == "2" ? "1" : beds_booking["status"]
    Booking.create!(
      vrental_id: @vrental.id,
      status: status,
      firstname: tourist&.firstname || beds_booking["guestFirstName"],
      lastname: tourist&.lastname || beds_booking["guestName"],
      tourist_id: tourist.present? ? tourist.id : nil,
      checkin: Date.parse(beds_booking["firstNight"]),
      checkout: Date.parse(beds_booking["lastNight"]) + 1.day,
      nights: Date.parse(beds_booking["lastNight"]) + 1.day - Date.parse(beds_booking["firstNight"]),
      adults: beds_booking["numAdult"],
      children: beds_booking["numChild"],
      beds_booking_id: beds_booking["bookId"],
      referrer: beds_booking["referer"],
      commission: beds_booking["commission"],
      price: beds_booking["price"]
    )
  end

  def update_booking(booking, beds_booking, tourist)
    status = beds_booking["status"] == "2" ? "1" : beds_booking["status"]
    booking.update!(
      status: status,
      firstname: tourist&.firstname || beds_booking["guestFirstName"],
      lastname: tourist&.lastname || beds_booking["guestName"],
      checkin: Date.parse(beds_booking["firstNight"]),
      checkout: Date.parse(beds_booking["lastNight"]) + 1.day,
      nights: Date.parse(beds_booking["lastNight"]) + 1.day - Date.parse(beds_booking["firstNight"]),
      adults: beds_booking["numAdult"],
      children: beds_booking["numChild"],
      referrer: beds_booking["referer"],
      commission: beds_booking["commission"],
      price: beds_booking["price"],
      tourist_id: tourist.present? ? tourist.id : nil
    )
  end

  def update_charges_and_payments(booking, beds_booking_invoice)
    beds_booking_invoice.each do |entry|
      return if booking.locked == true

      if (charge = booking.charges.find_by(beds_id: entry["invoiceId"]))
        charge.update!(
          description: entry["description"],
          quantity: 1,
          price: entry["price"].to_f * entry["qty"].to_f
        )
      elsif (payment = booking.payments.find_by(beds_id: entry["invoiceId"]))
        payment.update!(
          description: entry["description"],
          quantity: -1,
          price: entry["price"].to_f * entry["qty"].to_f
          )
      else
        create_charges_and_payments(booking, entry)
      end
    end
  end

  def create_charges_and_payments(booking, entry)
    if entry["qty"] == "1"
      Charge.create!(
      description: entry["description"],
      beds_id: entry["invoiceId"],
      quantity: 1,
      price: entry["price"].to_f * entry["qty"].to_f,
      booking_id: booking.id
      )
    elsif entry["qty"] == "-1"
      Payment.create!(
        description: entry["description"],
        beds_id: entry["invoiceId"],
        quantity: -1,
        price: entry["price"].to_f * entry["qty"].to_f,
        booking_id: booking.id
      )
    elsif entry["qty"] != "-1" && entry["qty"] != "1"
      Charge.create!(
        description: entry["description"],
        beds_id: entry["invoiceId"],
        quantity: 1,
        price: entry["price"].to_f * entry["qty"].to_f,
        booking_id: booking.id
      )
    end
  end

  def add_description_charges_payments(booking)
    max_charge = booking.charges.order(price: :desc).first
    max_charge.update(charge_type: "rent") if max_charge
    booking.charges.each do |charge|
      if charge.description.match?(/0,99|tax|taxa|taxe|tasa|impuesto|impost|0\.99/i)
        charge.update(charge_type: "city_tax")
      elsif charge.description.match?(/neteja|cleaning|nettoyage|limpieza/i)
        charge.update(charge_type: "cleaning")
      elsif charge != max_charge
        charge.update(charge_type: "other")
      end
    end
  end

  def destroy_deleted_charges_payments(booking, beds_booking_invoice)
    if beds_booking_invoice.nil? || beds_booking_invoice.empty?
      (booking.charges + booking.payments).each do |item|
        item.destroy
      end
    else
      beds_charges_payments = Set.new(beds_booking_invoice.map { |entry| entry["invoiceId"] })

      (booking.charges + booking.payments).each do |item|
        unless beds_charges_payments.include?(item.beds_id)
          item.destroy
        end
      end
    end
  end

  def add_earning(booking)
    vrental_rate_price = booking.vrental.rate_price(booking.checkin, booking.checkout)&.round(2)
    if vrental_rate_price.present?
      price = [booking.net_price, vrental_rate_price].min

      discount = vrental_rate_price == 0 ? 0 : (vrental_rate_price - price) / vrental_rate_price

      discount = [0, discount].max # Ensure it's not negative
      discount = [1, discount].min # Ensure it's not greater than 1
    else
      price = booking.net_price
      discount = 0
    end

    if booking.earning.present?
      if booking.earning.locked == true
        return
      else
        booking.earning.update!(
          date: booking.checkin,
          amount: price,
          discount: discount
        )
      end
    else
      Earning.create!(
        date: booking.checkin,
        amount: price,
        discount: discount,
        booking_id: booking.id,
        vrental_id: booking.vrental_id
      )
    end
  end

  def add_tourist_to_booking(beds_booking, existing_tourist)
    if existing_tourist
      tourist = existing_tourist
      tourist.update!(
        firstname: beds_booking["guestFirstName"],
        lastname: beds_booking["guestName"],
        phone: beds_booking["guestPhone"],
        email: beds_booking["guestEmail"],
        address: beds_booking["guestAddress"],
        country_code: beds_booking["guestCountry"]
      )
    else
      tourist = Tourist.create!(
        firstname: beds_booking["guestFirstName"],
        lastname: beds_booking["guestName"],
        phone: beds_booking["guestPhone"],
        email: beds_booking["guestEmail"],
        address: beds_booking["guestAddress"],
        country_code: beds_booking["guestCountry"]
      )
    end
  end
end

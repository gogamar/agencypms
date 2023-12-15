class VrentalApiService
  def initialize(target)
    @target = target
  end

  # fixme return error messages to controller so that an appropriate flash message can be displayed

  # called on office

  def import_properties_from_beds(no_import = nil, import_name)
    client = BedsHelper::Beds.new(beds_key)
    begin
      beds24rentals = client.get_properties
      # select only the ones that are not already imported
      new_beds24rentals = beds24rentals.select { |bedsrental| !Vrental.find_by(beds_prop_id: bedsrental["propId"]).present? }

      new_beds24rentals.each do |bedsrental|
        bedsrental["roomTypes"].each do |room|
          if no_import.present?
            words_array = no_import.split(', ').map(&:downcase)
            match_found = words_array.any? do |word|
              bedsrental["name"].downcase.include?(word) || room["name"].downcase.include?(word)
            end
            next if match_found
          end

          vrental_name = import_name == "property" ? bedsrental["name"] : room["name"]

          new_vrental = Vrental.create(
            status: "active",
            name: vrental_name,
            beds_prop_id: bedsrental["propId"],
            beds_room_id: room["roomId"],
            property_type: Vrental::PROPERTY_TYPES[bedsrental["propTypeId"]],
            address: bedsrental["address"] + ', ' + bedsrental["postcode"] + ' ' + bedsrental["city"],
            max_guests: room["maxPeople"].to_i,
            min_price: bedsrental["roomTypes"][0]["minPrice"],
            office_id: @target.id,
            town_id: Town.where("name ILIKE ?", "%#{bedsrental["city"]}%").first&.id || Town.create(name: bedsrental["city"]).id,
            latitude: bedsrental["latitude"],
            longitude: bedsrental["longitude"]
          )

          VrentalApiService.new(new_vrental).update_vrental_from_beds
          sleep 2
          VrentalApiService.new(new_vrental).get_content_from_beds
          sleep 2
        end
      end
    rescue StandardError => e
      Rails.logger.error("Error al importar immobles de Beds24: #{e.message}")
    end
  end

  # called on vrental

  # Import properties and content

  def update_vrental_from_beds
    client = BedsHelper::Beds.new(@target.office.beds_key)
    begin
      bedsrental = client.get_property(@target.prop_key, includeRooms: true)[0]
      room = bedsrental["roomTypes"].find { |room| room["roomId"] == @target.beds_room_id }

      @target.update(
        name: bedsrental["name"],
        property_type: Vrental::PROPERTY_TYPES[bedsrental["propTypeId"]],
        address: bedsrental["address"] + ', ' + bedsrental["postcode"] + ' ' + bedsrental["city"],
        max_guests: room["maxPeople"].to_i,
        min_stay: room["minStay"],
        rental_term: room["minStay"] >= 32 ? "medium_term" : "short_term",
        min_price: bedsrental["roomTypes"][0]["minPrice"],
        town_id: Town.where("name ILIKE ?", "%#{bedsrental["city"]}%").first&.id || Town.create(name: bedsrental["city"]).id,
        latitude: bedsrental["latitude"],
        longitude: bedsrental["longitude"],
        cut_off_hour: bedsrental["cutOffHour"],
        cleaning_fee: room["cleaningFee"]
      )
      sleep 2
      VrentalApiService.new(new_vrental).get_content_from_beds
      sleep 2
    rescue StandardError => e
      Rails.logger.error("Error al importar canvis de Beds24: #{e.message}")
    end
  end

  def get_content_from_beds
    # also get the booking conditions cancellation policy (14 days?))
    # also set status to inactive if no rates or no bookings this year, whatever's easier
    client = BedsHelper::Beds.new(@target.office.beds_key)
    begin
      bedsrental = client.get_property_content(@target.prop_key, bookingData: true, roomIds: true, texts: true, includeAirbnb: true)[0]
      room = bedsrental["roomIds"][@target.beds_room_id]

      @target.update!(
        licence: bedsrental["permit"],
        res_fee: bedsrental["depositPercent1"].to_f / 100,
        checkin_start_hour: bedsrental["checkInStartHour"],
        checkin_end_hour: bedsrental["checkInEndHour"],
        checkout_end_hour: bedsrental["checkOutEndHour"],
        title_ca: room["airbnb"]["name"]["CA"].present? ? room["airbnb"]["name"]["CA"] : room["texts"]["contentHeadlineText"]["CA"],
        title_es: room["airbnb"]["name"]["ES"].present? ? room["airbnb"]["name"]["ES"] : room["texts"]["contentHeadlineText"]["ES"],
        title_fr: room["airbnb"]["name"]["FR"].present? ? room["airbnb"]["name"]["FR"] : room["texts"]["contentHeadlineText"]["FR"],
        title_en: room["airbnb"]["name"]["EN"].present? ? room["airbnb"]["name"]["EN"] : room["texts"]["contentHeadlineText"]["EN"],
        short_description_ca: room["airbnb"]["summaryText"]["CA"],
        short_description_es: room["airbnb"]["summaryText"]["ES"],
        short_description_fr: room["airbnb"]["summaryText"]["FR"],
        short_description_en: room["airbnb"]["summaryText"]["EN"],
        description_ca: room["airbnb"]["spaceText"]["CA"].present? ? room["airbnb"]["spaceText"]["CA"] : room["texts"]["contentDescriptionText"]["CA"],
        description_es: room["airbnb"]["spaceText"]["ES"].present? ? room["airbnb"]["spaceText"]["ES"] : room["texts"]["contentDescriptionText"]["ES"],
        description_fr: room["airbnb"]["spaceText"]["FR"].present? ? room["airbnb"]["spaceText"]["FR"] : room["texts"]["contentDescriptionText"]["FR"],
        description_en: room["airbnb"]["spaceText"]["EN"].present? ? room["airbnb"]["spaceText"]["EN"] : room["texts"]["contentDescriptionText"]["EN"]
      )

      if room["featureCodes"].present?
        accepted_features = Feature::FEATURES

        beds24features = room["featureCodes"].flatten.map do |code|
          code.downcase == 'ocean_view' ? 'sea_view' : code.downcase
        end

        selected_features = beds24features.select { |feature| accepted_features.include?(feature) }

        if selected_features.include?("beach_view")
          @target.features << Feature.where(name: "sea_view")
        end

        selected_features.each do |feature|
          existing_feature = Feature.find_or_create_by(name: feature)
          @target.features << existing_feature unless @target.features.include?(existing_feature)
        end

        @target.save!

        @target.features.each do |feature|
          unless selected_features.include?(feature.name)
            @target.features.delete(feature)
            @target.save!
          end
        end

        beds24bedrooms = room["featureCodes"].select { |feature| feature.any? { |word| word.starts_with?("BEDROOM") } }

        beds24bedrooms.each_with_index do |room_data, index|
          room_type = room_data.select { |word| word.starts_with?("BEDROOM") }.first
          room_bed_types = room_data.select { |word| word.starts_with?("BED_") }

          bedroom = @target.bedrooms[index]

          if bedroom
            room_bed_types.each do |bed_type|
              bedroom.beds.find_or_create_by(bed_type: bed_type, bedroom: bedroom)
            end
          else
            bedroom = @target.bedrooms.create!(bedroom_type: room_type, vrental_id: id)
            room_bed_types.each do |bed_type|
              bedroom.beds.create!(bed_type: bed_type, bedroom: bedroom)
            end
          end
        end

        if beds24bedrooms.length < @target.bedrooms.length
          @target.bedrooms.last(@target.bedrooms.length - beds24bedrooms.length).each do |bedroom|
            bedroom.destroy
          end
        end

        beds24bathrooms = room["featureCodes"].select { |feature| feature.any? { |word| word.starts_with?("BATHROOM") } }
        existing_bathrooms = {}
        @target.bathrooms.each { |bathroom| existing_bathrooms[bathroom.bathroom_type] ||= [] }
        @target.bathrooms.each { |bathroom| existing_bathrooms[bathroom.bathroom_type] << bathroom }

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
            @target.bathrooms.create!(bathroom_type: bathroom_type, vrental_id: id)
          end
        end
        existing_bathrooms.values.flatten.each(&:destroy)
      end
    rescue => e
      puts "Error importing content for #{@target.name}: #{e.message}"
    end
    sleep 2
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
              propId: "#{@target.beds_prop_id}",
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
              propId: "#{@target.beds_prop_id}",
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

      client.set_property_content(@target.prop_key, setPropertyContent: images_array)
    rescue => e
      puts "Error deleting photos for #{@target.name}: #{e.message}"
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

      image_url = @target.image_urls.find_or_initialize_by(url: new_url)

      if image_url.persisted?
        image_url.update!(position: photo_hash["position"])
      else
        image_url.position = photo_hash["position"]
        image_url.vrental_id = @target.id
        image_url.save!
      end
    end
  end

  def update_owner_from_beds
    client = BedsHelper::Beds.new(@target.office.beds_key)
    begin
      property = client.get_property(@target.prop_key)[0]
      existing_owner = Owner.find_by(fullname: property["template1"])
      if @target.owner.present?
        if existing_owner.present? && existing_owner != @target.owner
          @target.update!(owner: existing_owner)
        elsif existing_owner.present? && existing_owner == @target.owner
          @target.owner.update!(
            fullname: property["template1"],
            document: property["template5"],
            address: property["template2"],
            email: property["template4"],
            phone: property["template3"],
            account: property["template6"],
            beds_room_id: property["roomTypes"][0]["roomId"],
            )
        end
      elsif !@target.owner.present? && existing_owner.present?
        @target.update!(owner: existing_owner)
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
          vrental_id: @target.id
          )
      end
      sleep 2
    rescue StandardError => e
      Rails.logger.error("Error al importar propietari de Beds24: #{e.message}")
    end
  end

  # Export Properties and Content

  def update_vrental_on_beds
    client = BedsHelper::Beds.new(@target.office.beds_key)

    begin
      beds24rentals_prop_ids = Set.new(client.get_properties.map { |bedsrental| bedsrental["propId"] })
      puts "these are beds24rentals_prop_ids: #{beds24rentals_prop_ids}"
      puts "and this is @target.beds_prop_id: #{@target.beds_prop_id}"
      if @target.beds_prop_id && beds24rentals_prop_ids.include?(@target.beds_prop_id)
        bedsrental = [
            {
              action: "modify",
              name: @target.name,
              propTypeId: Vrental::PROPERTY_TYPES.key(@target.property_type),
              address: @target.address,
              city: @target.town&.name,
              latitude: @target.latitude,
              longitude: @target.longitude,
              cutOffHour: @target.cut_off_hour,
              currency: "EUR",
              roomTypes: [
                {
                  action: "modify",
                  roomId: @target.beds_room_id,
                }.merge(@target.beds_room_type)
              ]
            }
        ]
        set_property_response = client.set_property(@target.prop_key, setProperty: bedsrental)
        puts "this is the set_property_response: #{set_property_response}"
      else
        new_bedrentals = []

        if @target.prop_key.present?
          assigned_prop_key = @target.prop_key
        else
          assigned_prop_key = SecureRandom.hex(16)
          @target.prop_key = assigned_prop_key
          @target.save!
        end

        new_bedrental = {
          name: @target.name,
          propKey: assigned_prop_key,
          notifyUrl: "https://sistachrentals.com/api/webhooks?property=[PROPERTYID]&checkin=[FIRSTNIGHTYYYY-MM-DD]&checkout=[LEAVINGDAYYYYY-MM-DD]&nights=[NUMNIGHT]&firstname=[GUESTFIRSTNAME]&lastname=[GUESTNAME]&adults=[NUMADULT]&children=[NUMCHILD]&referrer=[REFERRER]&price=[PRICE]",
          notifyHeader: "X-Webhook-Token: 6sgwlain2t0h2i3s1i0s2",
          propTypeId: Vrental::PROPERTY_TYPES.key(@target.property_type),
          address: @target.address,
          city: @target.town&.name,
          latitude: @target.latitude,
          longitude: @target.longitude,
          cutOffHour: @target.cut_off_hour,
          currency: "EUR",
          roomTypes: [
            @target.beds_room_type
          ]
        }
        new_bedrentals << new_bedrental
        create_property_response = client.create_properties(createProperties: new_bedrentals)
        puts "this is the create property response: #{create_property_response}"

        @target.beds_prop_id = create_property_response[0]["propId"]
        @target.beds_room_id = create_property_response[0]["roomTypes"][0]["roomId"]
        @target.save!
      end
      VrentalApiService.new(@target).set_content_on_beds
    rescue => e
      puts "Error exporting property #{@target.name}: #{e.message}"
    end
    sleep 2
  end

  def set_content_on_beds
    client = BedsHelper::Beds.new(@target.office.beds_key)
    begin
      content_array = [
                        { "action": "modify",
                          "bookingType": "3",
                          "bookingNearTypeDays": "-1",
                          "bookingNearType": "0",
                          "bookingExceptType": "4",
                          "bookingExceptTypeStart": Date.today.strftime("%Y-%m-%d"),
                          "bookingExceptTypeEnd": Date.tomorrow.strftime("%Y-%m-%d"),
                          "bookingRequestStatus": "0",
                          "depositNonPayment": "1",
                          "depositPercent1": @target.res_fee * 100.to_s || "30",
                          "depositPercent2": "100",
                          "depositFixed1": "0.00",
                          "depositFixed2": "0.00",
                          "paymentGatewayAgodapayEnable": "0",
                          "paymentGatewayAsiapayEnable": "0",
                          "paymentGatewayAuthorizenetEnable": "0",
                          "paymentGatewayBitpayEnable": "0",
                          "paymentGatewayBorgunEnable": "0",
                          "paymentGatewayCreditcardEnable": "0",
                          "paymentGatewayCustomgatewayEnable": "0",
                          "paymentGatewayGlobalpayments1Enable": "0",
                          "paymentGatewayGlobalpayments2Enable": "0",
                          "paymentGatewayOfflinepaymentEnable": "8",
                          "paymentGatewayPaymillEnable": "0",
                          "paymentGatewayPaypalEnable": "0",
                          "paymentGatewayStripeEnable": "10",
                          "cardRequireCVV": "0",
                          "cardAcceptAmex": "1",
                          "cardAcceptDiners": "1",
                          "cardAcceptDiscover": "1",
                          "cardAcceptEnroute": "0",
                          "cardAcceptJcb": "1",
                          "cardAcceptMaestro": "1",
                          "cardAcceptMaster": "1",
                          "cardAcceptUnionpay": "1",
                          "cardAcceptVisa": "1",
                          "cardAcceptVoyager": "0",
                          "checkInStartHour": @target.checkin_start_hour || "15",
                          "checkInEndHour": @target.checkin_end_hour || "20",
                          "checkOutEndHour": @target.checkout_end_hour || "10",
                          "name": @target.name,
                          "permit": @target.licence,
                          "roomChargeDisplay": "0",
                          # "groupKeywords": "8,apartament,nocompool,noprivpool,nowifigr,apts_centre,apts_vista,noaircon,Otros_estadistiques",
                          "sellPriority": "10",
                          "offerType": "room",
                          "bookingPageMultiplier": "",
                          "oneTimeVouchers": "",
                          "discountVoucherCode": {
                            "1": {
                            "phrase": "",
                            "amount": "0.00",
                            "type": "0"
                            },
                          },
                          "texts": {
                            "propertyDescription1": {
                              "EN": "#{@target.full_description_en}",
                              "CA": "#{@target.full_description_ca}",
                              "ES": "#{@target.full_description_es}",
                              "FR": "#{@target.full_description_fr}"
                            }
                          },
                          "bookingData": {
                            "question": {
                            "guestTitle": "-2",
                            "guestFirstName": "1",
                            "guestName": "1",
                            "guestEmail": "1",
                            "guestPhone": "-1",
                            "guestMobile": "0",
                            "guestFax": "-2",
                            "guestCompany": "-1",
                            "guestAddress": "0",
                            "guestCity": "0",
                            "guestState": "-2",
                            "guestPostcode": "0",
                            "guestCountry": "-1",
                            "guestCountry2": "1",
                            "guestArrivalTime": "0",
                            "guestComments": "0"
                            },
                            "upsell": {
                              "1": {
                                "type": "1",
                                # fixme
                                "price": "15.0000",
                                "unit": "0",
                                "period": "0",
                                "vat": "0.00",
                                "image": "0",
                                "description": {
                                "EN": "Baby cot and high-chair",
                                "CA": "Cuna i trona",
                                "ES": "Cuna y trona",
                                "FR": "Lit bébé et chaise haute"
                                },
                              },
                              "2": @target.pets_json ? @target.pets_json : {
                                "type": 0
                                },
                              "3": @target.city_tax_daily_json ? @target.city_tax_daily_json : {
                                "type": 0
                                },
                              "4": @target.city_tax_weekly_json ? @target.city_tax_weekly_json : {
                                "type": 0
                                },
                              "5": @target.portable_wifi_json ? @target.portable_wifi_json : {
                                "type": 0
                              }
                            },
                          },
                          "roomIds": {
                            "#{@target.beds_room_id}": {
                              "roomId": @target.beds_room_id,
                              "featureCodes": @target.feature_codes_bedroom_bathrooms,
                              "rackRate": "200.00",
                              "cleaningFee": "0.00",
                              "securityDeposit": "0.00",
                              "taxPercent": "0.00",
                              "taxPerson": "0.99",
                              "roomType": "6",
                              "sellPriority": "5",
                              "texts": {
                                "contentHeadlineText": {
                                  "EN": "#{@target.title_en}",
                                  "CA": "#{@target.title_ca}",
                                  "ES": "#{@target.title_es}",
                                  "FR": "#{@target.title_fr}"
                                },
                                "contentDescriptionText": {
                                  "EN": "#{@target.full_description_en}",
                                  "CA": "#{@target.full_description_ca}",
                                  "ES": "#{@target.full_description_es}",
                                  "FR": "#{@target.full_description_fr}"
                                },
                                "accommodationType": {
                                  "EN": I18n.t(@target.property_type, locale: :en),
                                  "CA": I18n.t(@target.property_type, locale: :ca),
                                  "ES": I18n.t(@target.property_type, locale: :es),
                                  "FR": I18n.t(@target.property_type, locale: :fr),
                                  },
                                  # fixme
                                "offers": {
                                  "1": {
                                    "name": {
                                    "EN": "",
                                    "CA": "",
                                    "ES": "",
                                    "FR": ""
                                    },
                                    "description1": {
                                    "EN": "At the check-in, the obligatory tourist tax will be charged: #{@target.town&.city_tax}€ per adult per night. It is paid only for the first 7 nights. ",
                                    "CA": "Al check-in se li cobrarà l’impost turístic: #{@target.town&.city_tax}€ per adult per nit. Es paga només per les 7 primeres nits.",
                                    "ES": "En el check-in se le cobrará el impuesto turístico: #{@target.town&.city_tax}€ por adulto por noche. Se paga sólo por las 7 primeras noches.",
                                    "FR": "Lors de l'enregistrement, vous devrez payer la taxe de séjour: #{@target.town&.city_tax}€ par adulte et par nuit. Vous ne payez que pour les 7 premières nuits."
                                    },
                                  },
                                }
                              },
                              "airbnb": {
                                  "name": {
                                      "EN": "#{@target.title_en}",
                                      "CA": "#{@target.title_ca}",
                                      "ES": "#{@target.title_es}",
                                      "FR": "#{@target.title_fr}"
                                  },
                                  "summaryText": {
                                    "EN": "#{@target.short_description_en}",
                                    "CA": "#{@target.short_description_ca}",
                                    "ES": "#{@target.short_description_es}",
                                    "FR": "#{@target.short_description_fr}"
                                  }
                              }
                            }
                          }
                        }
                      ]
      response = client.set_property_content(@target.prop_key, setPropertyContent: content_array)

      puts "this is the response: #{response}"
    rescue => e
      puts "Error setting content for #{@target.name}: #{e.message}"
    end
    sleep 2
  end

  def send_photos_to_beds
    images_array = []
    external = {}

    @target.image_urls.each_with_index do |image, index|
      if image.url.include?("cloudinary") && !image.url.include?("q_auto:good")
        url = image.url.gsub(/\/upload\//, '/upload/q_auto:good/')
      else
        url = image.url
      end
      external["#{index + 1}"] = {
        url: url,
        map: [
          {
            propId: "#{@target.beds_prop_id}",
            position: "#{image.position}"
          }
        ]
      }
    end

    if @target.town.present? && @target.town.photos.attached?
      @target.town.photos.each do |photo|
        external["#{external.length + 1}"] = {
          url: photo.url.gsub(/\/upload\//, '/upload/q_auto:good/'),
          map: [
            {
              propId: "#{@target.beds_prop_id}",
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
            propId: "#{@target.beds_prop_id}",
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

    client = BedsHelper::Beds.new(@target.office.beds_key)
    client.set_property_content(@target.prop_key, setPropertyContent: images_array)
  end

  # Rates

  def delete_this_year_rates_on_beds
    client = BedsHelper::Beds.new(@target.office.beds_key)
    beds24rates = client.get_rates(@target.prop_key)
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
    client.set_rates(@target.prop_key, setRates: rates_to_delete)
    rates_to_send_again = Rate.where("lastnight > ?", Date.today)
    rates_to_send_again.each do |rate|
      rate.sent_to_beds = nil
      rate.date_sent_to_beds = nil
      rate.save!
    end
  end

  def get_rates_from_beds
    client = BedsHelper::Beds.new(@target.office.beds_key)

    beds24rates = client.get_rates(@target.prop_key)

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

        # Then we select the rates older than 2 years for deletion
        old_rates = []

        beds24rates.each do |rate|
          if rate["firstNight"].to_date.year < (Date.today.year - 2) || !@target.future_rates.pluck(:beds_rate_id).include?(rate['rateId'])
            old_rate = {
              action: "delete",
              rateId: "#{rate["rateId"]}",
              roomId: "#{rate["roomId"]}"
          }
            old_rates << old_rate
          end
        end
        client.set_rates(@target.prop_key, setRates: old_rates)

        selected_rates = []

        if @target.price_per == "week"
          selected_rates.concat(beds24rates.select { |rate| rate["pricesPer"] == "7" && rate["restrictionStrategy"] == "0"  })
        elsif @target.price_per == "night"
          selected_rates.concat(beds24rates.select { |rate| rate["pricesPer"] == "1" && rate["restrictionStrategy"] == "0" })
        end

        selected_rates.each do |rate|
          if Date.parse(rate["lastNight"]) > Date.today.last_year

            existing_rate = @target.rates.find_by(beds_rate_id: rate["rateId"])
            if existing_rate
              existing_rate.update!(
                firstnight: rate["firstNight"],
                lastnight: rate["lastNight"],
                pricenight: @target.price_per == "night" ? rate["roomPrice"].to_f : nil,
                priceweek: @target.price_per == "week" ? rate["roomPrice"].to_f : nil,
                beds_room_id: rate["roomId"],
                min_stay: rate["minNights"].to_i,
                arrival_day: 'everyday'
              )
            else
              new_rate = Rate.create!(
                beds_rate_id: rate["rateId"],
                vrental_id: @target.id,
                firstnight: rate["firstNight"],
                lastnight: rate["lastNight"],
                pricenight: rate["pricesPer"] == "1" ? rate["roomPrice"].to_f : nil,
                priceweek: rate["pricesPer"] == "7" ? rate["roomPrice"].to_f : nil,
                beds_room_id: rate["roomId"],
                min_stay: rate["minNights"].to_i,
                arrival_day: 'everyday'
              )
            end
          end
        end

        selected_beds_rate_ids = selected_rates.map { |rate| rate["rateId"] }
        rates_to_delete = @target.rates.where.not(beds_rate_id: selected_beds_rate_ids)
        rates_to_delete.destroy_all
      else
        return
      end
    end

    rate_years = @target.rates.map(&:firstnight).map(&:year).uniq

    # fixme temporary fix for estartit
    if @target.office.name.downcase.include?('estartit')
      rate_years.each do |year|
        first_july = Date.new(year, 7, 1)
        first_august = Date.new(year, 8, 1)

        second_sat_july = first_july + (6 - first_july.wday) + 7
        last_friday_august = first_august + (5 - first_august.wday) + 21

        @target.rates.each do |rate|
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
    # fixme: check that nightprice exists for every rate before sending
    client = BedsHelper::Beds.new(@target.office.beds_key)

    beds24rates = client.get_rates(@target.prop_key)

    vrental_rates = []

    @target.future_rates.each do |rate|
      rate_exists_on_beds_id = beds24rates.any? { |beds_rate| beds_rate["rateId"] == rate.beds_rate_id }

      if rate.restriction.present?
        rate_restriction = rate.restriction == "gap_fill" ? "2" : "0"
      end

      vrental_rate =
        {
        action: rate_exists_on_beds_id ? "modify" : "new",
        roomId: "#{@target.beds_room_id}",
        firstNight: "#{rate.firstnight}",
        lastNight: "#{rate.lastnight}",
        name: "Tarifa #{rate.restriction.present? && rate.restriction == 'gap_fill' ? 'omplir forats' : ''} #{rate.pricenight.present? ? 'per nit' : 'setmanal'} #{I18n.l(rate.firstnight, format: :short)} - #{I18n.l(rate.lastnight, format: :short)} #{@target.weekly_discount.present? ? @target.weekly_discount.to_s + '% descompte setmanal només web propia' : ''}",
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
        disc6Percent: @target.weekly_discount.present? ? @target.weekly_discount.to_s : "0"
        }
      vrental_rates << vrental_rate
    end

    response = client.set_rates(@target.prop_key, setRates: vrental_rates)
    return unless response.code == 200

    if @target.vrgroup.present? && @target.rate_master_id.nil?
      rate_links = []
      @target.future_rates.each do |rate|
        beds24_rate_links = client.get_rate_links(@target.prop_key, rateId: rate.beds_rate_id)

        @target.vrgroup.vrentals.where(rate_master_id: @target.id).each do |linked_vrental|
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
      client.set_rate_links(@target.prop_key, setRateLinks: rate_links)
    end

    # fixme: need to rescue errors here

    @target.future_rates.each do |rate|
      rate.sent_to_beds = true
      rate.date_sent_to_beds = Time.zone.now
      rate.save!
    end
  end

  # Availability

  def get_bookings_from_beds(from_date = nil)
    from_date = from_date || Date.today.beginning_of_year.to_s
    client = BedsHelper::Beds.new(@target.office.beds_key)
    options = {
      "arrivalFrom": from_date,
      # "arrivalTo": Date.today.to_s,
      "includeInvoice": true,
    }
    beds24bookings = client.get_bookings(@target.prop_key, options)

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
          if booking = @target.bookings.find_by(beds_booking_id: beds_booking["bookId"].to_i)
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

        bookings_to_delete = @target.bookings.where('checkin >= ?', from_date.to_date).where.not(beds_booking_id: selected_bookings.map { |beds_booking| beds_booking['bookId'] })

        if bookings_to_delete.any?
          bookings_to_delete.destroy_all
        end
      end
    else
      return
    end
    sleep 3
  end

  def get_availabilities_from_beds_24
    master_availability_vrental = @target.availability_master.present? ? @target.availability_master : @target

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
        existing_availability = @target.availabilities.find_by(date: formatted_date)
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
            vrental_id: @target.id
          )
        end
      end
    rescue => e
      puts "Error importing availability data for #{master_availability_vrental.name}: #{e.message}"
    end
    sleep 2
  end

  def get_availability_from_beds(checkin, checkout, guests)
    vrental_instance = @target.availability_master.present? ? @target.availability_master : @target
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

  def send_availabilities_to_beds_24
    # this one needs fixing!
    master_vrental = @target.availability_master.present? ? @target.availability_master : @target
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

    set_availability_data = client.set_room_dates(@target.prop_key, options)

    begin
      availability_data = client.get_room_dates(master_vrental.prop_key, options)
      availability_data.each do |date, attributes|
        formatted_date = Date.parse(date.to_s)
        existing_availability = @target.availabilities.find_by(date: formatted_date)
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
            vrental_id: @target.id
          )
        end
      end
    rescue => e
      puts "Error importing availability data for #{@target.name}: #{e.message}"
    end
    sleep 2
  end

  def prevent_gaps_on_beds(days_after_checkout)
    return if @target.future_bookings.empty?
    master_availability_vrental = @target.availability_master.present? ? @target.availability_master : @target
    master_future_rates = master_availability_vrental.rate_master.present? ? master_availability_vrental.rate_master.future_rates : master_availability_vrental.future_rates
    last_rate_lastnight = master_future_rates.order(lastnight: :desc).first.lastnight
    checkout_date = @target.bookings.order(checkin: :desc).first.checkout
    no_check_in_from = checkout_date + days_after_checkout.days

    dates = {}

    # reset the dates from checkout to no_check_in_from
    (checkout_date...no_check_in_from).each do |date|
      availability = @target.availabilities.find_or_create_by(date: date)
      availability.update(override: 0)
      dates[availability.date.strftime("%Y%m%d")] = {
        "o": availability.override.to_s
      }
    end

    (no_check_in_from..last_rate_lastnight).each do |date|
      availability = @target.availabilities.find_or_create_by(date: date)
      availability.update(override: 2)
      dates[availability.date.strftime("%Y%m%d")] = {
        "o": availability.override.to_s
      }
    end

    options = {
      "roomId": @target.beds_room_id,
      "dates": dates
    }
    client = BedsHelper::Beds.new(@target.office.beds_key)
    begin
      set_availability_data = client.set_room_dates(@target.prop_key, options)
    rescue => e
      puts "Error preventing gaps for #{@target.name}: #{e.message}"
    end
    sleep 2
  end

  def send_owner_booking(owner_booking)
    booking_lastnight = owner_booking.checkout - 1.day
    options = {
      "bookId": owner_booking.beds_booking_id,
      "roomId": @target.beds_room_id,
      "status": owner_booking.status,
      "firstNight": owner_booking.checkin.strftime("%Y-%m-%d"),
      "lastNight": booking_lastnight.strftime("%Y-%m-%d"),
      "guestFirstName": I18n.t('owner'),
      "guestName": I18n.t('owner_booking'),
      "notes": owner_booking.note
    }
    client = BedsHelper::Beds.new(@target.office.beds_key)
    begin
      response = client.set_booking(@target.prop_key, options)
      if response["bookId"].present?
        owner_booking.update(beds_booking_id: response["bookId"])
      end
    rescue => e
      puts "Error preventing gaps for #{@target.name}: #{e.message}"
    end
  end

  private

  attr_reader :vrental

  def api_call_get_property_content
    @cached_property_content ||= nil
    if @cached_property_content.nil?
      client = BedsHelper::Beds.new(@target.office.beds_key)
      begin
        @cached_property_content = client.get_property_content(@target.prop_key, images: true, roomIds: true)[0]
      rescue => e
        puts "Error getting property content for #{@target.name}: #{e.message}"
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
      return beds24content["roomIds"][@target.beds_room_id]["images"]["external"].select { |key, image| image["url"] != "" }
    else
      return {}
    end
  end

  def add_booking(beds_booking, tourist)
    status = beds_booking["status"] == "2" ? "1" : beds_booking["status"]
    Booking.create!(
      vrental_id: @target.id,
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
      puts "Earning created for booking #{booking.id}"
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

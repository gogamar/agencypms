class Vrental < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  belongs_to :user
  belongs_to :vrowner, optional: true
  has_many :vragreements, dependent: :destroy
  has_many :rates, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :earnings, dependent: :destroy
  has_many :statements, dependent: :destroy
  has_and_belongs_to_many :features
  validates :name, presence: true
  validates :status, presence: true

  def unavailable_dates
    rates.pluck(:firstnight, :lastnight).map do |range|
      { from: range[0], to: range[1] }
    end
  end

  def commission_percentage
    number_to_percentage(commission * 100, precision: 2, separator: ',')
  end

  def default_checkin
    last_rate = rates.find_by(lastnight: rates.maximum('lastnight'))
    last_rate.present? ? last_rate.lastnight + 1.day : Date.today
  end

  def rate_price(checkin, checkout)

    overlapping_rates = rates.where(
      "lastnight >= ? AND firstnight <= ?", checkin, checkout
    )
    puts overlapping_rates

    total_price = 0.0
    overlapping_rates.each do |rate|
      rate_start = [checkin, rate.firstnight].max
      rate_end = [checkout, rate.lastnight].min

      days_overlap = (rate_end - rate_start + 1).to_i

      if rate.pricenight.present?
        total_price += rate.pricenight * days_overlap
      elsif rate.priceweek.present?
        total_price += (rate.priceweek / 7) * days_overlap
      end
    end
    return total_price
  end

  def self.import_properties_from_beds
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])
    begin
      beds24rentals = client.get_properties
      beds24rentals.each do |bedsrental|
        if Vrental.where(beds_prop_id: bedsrental["propId"]).exists?
          next
        else
          # user_id = User.find_by(admin: true).id
          user_id = 2
          Vrental.create!(
            name: bedsrental["name"],
            address: bedsrental["address"] + ', ' + bedsrental["postcode"] + ' ' + bedsrental["city"],
            beds_prop_id: bedsrental["propId"],
            beds_room_id: bedsrental["roomTypes"][0]["roomId"],
            max_guests: bedsrental["roomTypes"][0]["maxPeople"].to_i,
            user_id: user_id,
            prop_key: bedsrental["name"].delete(" ").delete("'").downcase + "2022987123654",
            status: "active"
          )
        end
        sleep 2
      end
    rescue StandardError => e
      Rails.logger.error("Error al importar immobles de Beds24: #{e.message}")
    end
  end

  def copy_rates_to_next_year(current_year)
    #for some reason this method doesn't work the same locally
    easter_season_firstnight = {
    2022 => Date.new(2022,4,2),
    2023 => Date.new(2023,4,1),
    2024 => Date.new(2024,3,23),
    2025 => Date.new(2025,4,12),
    2026 => Date.new(2026,3,28),
    2027 => Date.new(2027,3,20),
    2028 => Date.new(2028,4,8)
    }
    current_rates = rates.where("DATE_PART('year', firstnight) = ?", current_year)
    current_rates.each do |existingrate|
    next_year = existingrate.firstnight.year + 1
      # if Easter Rate is 10 days and the rate doesn't already exist for the next year
      if easter_season_firstnight.value?(existingrate.firstnight) && (existingrate.lastnight - existingrate.firstnight).to_i == 10 && !rates.where(firstnight: easter_season_firstnight[next_year]).exists?
        Rate.create!(
          firstnight: easter_season_firstnight[next_year],
          lastnight: easter_season_firstnight[next_year] + 10,
          pricenight: existingrate.pricenight,
          priceweek: existingrate.priceweek,
          beds_room_id: existingrate.beds_room_id,
          vrental_id: existingrate.vrental_id,
          min_stay: existingrate.min_stay,
          arrival_day: existingrate.arrival_day
        )
      # if Easter rate is longer than 10 days and the rate doesn't already exist for the next year
      elsif easter_season_firstnight.value?(existingrate.firstnight) && (existingrate.lastnight - existingrate.firstnight).to_i > 10 && !rates.where(firstnight: easter_season_firstnight[next_year]).exists?
        Rate.create!(
          firstnight: easter_season_firstnight[next_year],
          lastnight: existingrate.lastnight + 364,
          pricenight: existingrate.pricenight,
          priceweek: existingrate.priceweek,
          beds_room_id: existingrate.beds_room_id,
          vrental_id: existingrate.vrental_id,
          min_stay: existingrate.min_stay,
          arrival_day: existingrate.arrival_day
        )
      # if it's Before Easter rate and the rate doesn't already exist for the next year
      elsif easter_season_firstnight.value?(existingrate.lastnight + 1) && !rates.where(lastnight: easter_season_firstnight[next_year] - 1).exists?
        Rate.create!(
          firstnight: existingrate.firstnight + 364,
          lastnight: easter_season_firstnight[next_year] - 1,
          pricenight: existingrate.pricenight,
          priceweek: existingrate.priceweek,
          beds_room_id: existingrate.beds_room_id,
          vrental_id: existingrate.vrental_id,
          min_stay: existingrate.min_stay,
          arrival_day: existingrate.arrival_day
        )
      elsif !rates.where(firstnight: existingrate.firstnight + 364).present?
        Rate.create!(
          firstnight: existingrate.firstnight + 364,
          lastnight: existingrate.lastnight + 364,
          pricenight: existingrate.pricenight,
          priceweek: existingrate.priceweek,
          beds_room_id: existingrate.beds_room_id,
          vrental_id: existingrate.vrental_id,
          min_stay: existingrate.min_stay,
          arrival_day: existingrate.arrival_day
        )
      # else
      #   return
      end
    end
  end

  def get_content_from_beds
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])
    prop_key = self.prop_key
    beds24descriptions = client.get_property_content(prop_key, roomIds: true, texts: true)
    puts beds24descriptions[0]["name"]
  end

  def get_rates_from_beds
    rates.destroy_all
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])
    prop_key = self.prop_key
    beds24rates = client.get_rates(prop_key)

    beds24rates.each do |rate|
      if rate["firstNight"].delete("-").to_i > 20220101 && rate["pricesPer"] == "7"
        Rate.create!(
          firstnight: rate["firstNight"],
          lastnight: rate["lastNight"],
          priceweek: rate["roomPrice"],
          beds_room_id: rate["roomId"],
          vrental_id: self.id,
          min_stay: 5,
          arrival_day: 'everyday'
        )
      end
    end

    rate_years = rates.map(&:firstnight).map(&:year).uniq

    rate_years.each do |year|
      first_july = Date.new(year, 7, 1)
      first_august = Date.new(year, 8, 1)

      second_sat_july = first_july + (6 - first_july.wday) + 7
      last_friday_august = first_august + (5 - first_august.wday) + 21

      rates.each do |rate|
        if rate.firstnight >= second_sat_july && rate.lastnight <= last_friday_august
          rate.min_stay = 7
          rate.arrival_day = "saturdays"
          rate.save!
        end
      end
    end
  end

  def get_bookings_from_beds
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])
    prop_key = self.prop_key
    options = {
      "arrivalFrom": Date.today.beginning_of_year,
      "arrivalTo": Date.today,
      "includeInvoice": true,
      "status": "1"
    }
    beds24bookings = client.get_bookings(prop_key, options)

    if beds24bookings.success?
      parsed_response = beds24bookings.parsed_response
      found_error = false
      parsed_response.each do |hash|
        if hash.is_a?(Hash) && hash.key?("error")
          found_error = true
          error_message = hash["error"]
          error_code = hash["errorCode"]
          # Handle the error message and error code as needed
          puts "Error: #{error_message}, ErrorCode: #{error_code}"
          break  # No need to check further
        end
      end

      unless found_error
        if beds24bookings.empty?
          return
        end
        beds24bookings.each do |beds_booking|
          if booking = self.bookings.find_by(beds_booking_id: beds_booking["bookId"])
            if !beds_booking["guestEmail"].blank?
              existing_tourist = Tourist.find_by(email: beds_booking["guestEmail"])
              add_tourist_to_booking(beds_booking, existing_tourist)
            else
              tourist = nil
            end

            booking.update!(
              status: beds_booking["status"],
              firstname: tourist&.firstname || beds_booking["guestFirstName"],
              lastname: tourist&.lastname || beds_booking["guestName"],
              checkin: Date.parse(beds_booking["firstNight"]),
              checkout: Date.parse(beds_booking["lastNight"]) + 1.day,
              adults: beds_booking["numAdult"],
              children: beds_booking["numChild"],
              referrer: beds_booking["referer"],
              commission: beds_booking["commission"],
              price: beds_booking["price"],
              tourist_id: tourist.present? ? tourist.id : nil
            )

            if beds_booking["invoice"].nil? || beds_booking["invoice"].empty?
              next
            else
              beds_booking["invoice"].each do |entry|
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
                  create_charges_and_payments(booking, beds24_invoice)
                end
                add_description_charges_payments(booking)
              end
            end

            add_earning(booking)
          else
            if !beds_booking["guestEmail"].blank?
              existing_tourist = Tourist.find_by(email: beds_booking["guestEmail"])

              add_tourist_to_booking(beds_booking, existing_tourist)
            else
              tourist = nil
            end

            booking = Booking.create!(
              vrental_id: self.id,
              status: beds_booking["status"],
              firstname: tourist&.firstname || beds_booking["guestFirstName"],
              lastname: tourist&.lastname || beds_booking["guestName"],
              tourist_id: tourist.present? ? tourist.id : nil,
              checkin: Date.parse(beds_booking["firstNight"]),
              checkout: Date.parse(beds_booking["lastNight"]) + 1.day,
              adults: beds_booking["numAdult"],
              children: beds_booking["numChild"],
              beds_booking_id: beds_booking["bookId"],
              referrer: beds_booking["referer"],
              commission: beds_booking["commission"],
              price: beds_booking["price"]
            )

            if beds_booking["invoice"].nil? || beds_booking["invoice"].empty?
              next
            else
              create_charges_and_payments(booking, beds_booking["invoice"])
              add_description_charges_payments(booking)
            end
            add_earning(booking)
          end
        end
      end
    else
      return
    end
  end

  def create_charges_and_payments(booking, beds24_invoice)
    beds24_invoice.each do |entry|
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
  end

  def add_description_charges_payments(booking)
    max_charge = booking.charges.order(price: :desc).first
    max_charge.update(charge_type: "rent") if max_charge
    booking.charges.each do |charge|
      if charge.description.match?(/0,99|tax|taxa|taxe|tasa|0\.99/i)
        charge.update(charge_type: "city_tax")
      elsif charge.description.match?(/neteja|cleaning|nettoyage|limpieza/i)
        charge.update(charge_type: "cleaning")
      elsif charge != max_charge
        charge.update(charge_type: "other")
      end
    end
  end

  def add_earning(booking)
    rate_price = booking.vrental.rate_price(booking.checkin, booking.checkout)
    booking_net_price = booking.charges.where(charge_type: "rent").sum(:price) - booking.commission
    discount = rate_price == 0 ? 0 : (rate_price - booking_net_price) / rate_price

    discount = [0, discount].max # Ensure it's not negative
    discount = [1, discount].min # Ensure it's not greater than 1

    if booking.earning.present? && booking.earning.locked == false && booking.earning.paid == false
      booking.earning.update!(
        date: booking.checkin,
        description: "#{booking.lastname} (#{I18n.l(booking.checkin)} - #{I18n.l(booking.checkout)})",
        amount: booking.charges.where(charge_type: "rent").sum(:price) - booking.commission,
        discount: discount
      )
    else
      Earning.create!(
        date: booking.checkin,
        description: "#{booking.lastname} (#{I18n.l(booking.checkin)} - #{I18n.l(booking.checkout)})",
        amount: booking.charges.where(charge_type: "rent").sum(:price) - booking.commission,
        booking_id: booking.id,
        vrental_id: booking.vrental_id,
        discount: discount
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

  def delete_this_year_rates_on_beds
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])
    prop_key = self.prop_key
    beds24rates = client.get_rates(prop_key)
    rates_to_delete = []
    beds24rates.each do |rate|
      if rate["lastNight"].to_date > Date.today.beginning_of_year
        rate_to_delete = {
          action: "delete",
          rateId: "#{rate["rateId"]}",
          roomId: "#{rate["roomId"]}"
      }
        rates_to_delete << rate_to_delete
      end
    end
    client.set_rates(prop_key, setRates: rates_to_delete)
    rates_to_send_again = Rate.where("firstnight > ?", Date.today)
    rates_to_send_again.each do |rate|
      rate.sent_to_beds = nil
      rate.date_sent_to_beds = nil
      rate.save!
    end
  end

  def create_property_on_beds
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])
    beds24rentals_prop_names = Set.new(client.get_properties.map { |bedsrental| bedsrental["name"] })

    if beds24rentals_prop_names.include?(self.name)
      return
    end

    new_bedrentals = []
    new_bedrental = {
      name: self.name,
      prop_key: self.prop_key,
      roomTypes: [
        {
          name: self.name,
          qty: 1,
          minPrice: 30
        }
      ]
    }
    new_bedrentals << new_bedrental
    response = client.create_properties(createProperties: new_bedrentals)

    self.beds_prop_id = response[0]["propId"]
    self.beds_room_id = response[0]["roomTypes"][0]["roomId"]
    self.save!
  end

  def send_rates_to_beds
    client = BedsHelper::Beds.new(ENV["BEDSKEY"])
    prop_key = self.prop_key
    # First we get all the rates from Beds24
    beds24rates = client.get_rates(prop_key)
    # Then we select the rates older than 2 years for deletion
    rates_to_delete = []
    beds24rates.each do |rate|
      if rate["firstNight"].to_date.year < (Date.today.year - 1)
        rate_to_delete = {
          action: "delete",
          rateId: "#{rate["rateId"]}",
          roomId: "#{rate["roomId"]}"
      }
        rates_to_delete << rate_to_delete
      end
    end

    # Then we delete the rates older than 2 years
    client.set_rates(prop_key, setRates: rates_to_delete)

    # Then we get all the rates from this website

    vrental_rates = []

    vr_rates = rates.where("firstnight BETWEEN ? AND ?", Date.today.beginning_of_year, Date.today.end_of_year)


    vr_rates.each do |rate|

      general_rate =
        {
        action: "new",
        roomId: "#{self.beds_room_id}",
        firstNight: "#{rate.firstnight}",
        lastNight: "#{rate.lastnight}",
        name: "Tarifa #{I18n.l(rate.firstnight, format: :short)} - #{I18n.l(rate.lastnight, format: :short)} amb 10% desc. setmanal",
        minNights: "0",
        minAdvance: "2",
        allowEnquiry: "1",
        pricesPer: "1",
        color: "#{SecureRandom.hex(3)}",
        roomPrice: "#{rate.priceweek/6.295}",
        roomPriceEnable: "1",
        roomPriceGuests: "0",
        disc1Nights: "2",
        disc2Nights: "3",
        disc3Nights: "4",
        disc4Nights: "5",
        disc5Nights: "6",
        disc6Nights: "7",
        disc7Nights: "8",
        disc8Nights: "9",
        disc6Percent: "10.00"
        }
      weekly_rate =
        {
        action: "new",
        roomId: "#{self.beds_room_id}",
        firstNight: "#{rate.firstnight}",
        lastNight: "#{rate.lastnight}",
        name: "Tarifa setmanal només sistachrentals.com #{I18n.l(rate.firstnight, format: :short)} - #{I18n.l(rate.lastnight, format: :short)}",
        minAdvance: "2",
        allowEnquiry: "1",
        pricesPer: "7",
        color: "#{SecureRandom.hex(3)}",
        roomPrice: "#{rate.priceweek}",
        roomPriceEnable: "1",
        roomPriceGuests: "0",
        channel000: "1",
        channel999: "1",
        channel017: "0",
        channel046: "0",
        channel032: "0",
        channel027: "0",
        channel031: "0",
        channel052: "0",
        channel019: "0",
        channel002: "0",
        channel053: "0",
        channel059: "0",
        channel066: "0",
        channel014: "0",
        channel033: "0",
        channel012: "0",
        channel073: "0",
        channel013: "0",
        channel078: "0",
        channel044: "0",
        channel064: "0",
        channel024: "0",
        channel036: "0",
        channel057: "0",
        channel072: "0",
        channel035: "0",
        channel087: "0",
        channel051: "0",
        channel042: "0",
        channel023: "0",
        channel086: "0",
        channel050: "0",
        channel083: "0",
        channel056: "0",
        channel076: "0",
        channel055: "0",
        channel063: "0",
        channel030: "0",
        channel034: "0"
        }
        vrental_rates << general_rate
        vrental_rates << weekly_rate
    end

    # And finally we send the rates to Beds24
    response = client.set_rates(prop_key, setRates: vrental_rates)

    return unless response.code == 200

    vr_rates.each do |rate|
      rate.sent_to_beds = true
      rate.date_sent_to_beds = Time.zone.now
      rate.save!
    end
  end
end

class Vrental < ApplicationRecord
  require 'net/http'
  include ActionView::Helpers::NumberHelper
  belongs_to :user
  belongs_to :owner, optional: true
  belongs_to :town, optional: true
  belongs_to :office
  belongs_to :rate_plan, optional: true
  belongs_to :town, optional: true
  belongs_to :vrgroup, optional: true
  has_many :bedrooms, dependent: :destroy
  has_many :bathrooms, dependent: :destroy
  has_many :vragreements, dependent: :destroy
  has_many :rates, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :expenses, dependent: :nullify
  has_many :earnings, dependent: :nullify
  has_many :statements, dependent: :nullify
  has_many :invoices, dependent: :nullify
  has_and_belongs_to_many :features
  has_and_belongs_to_many :coupons
  has_many :image_urls, dependent: :destroy
  has_many_attached :photos
  scope :with_future_rates, -> { joins(:rates).where("rates.firstnight > ?", Date.today).distinct(:id) }
  scope :with_past_year_rates, -> {
    joins(:rates)
      .where("rates.firstnight >= ?", 1.year.ago.beginning_of_year)
      .distinct(:id)
  }

  scope :on_budget, -> {
    with_past_year_rates
      .joins(:rates)
      .where("rates.priceweek <= ? OR rates.pricenight <= ?", 300, 60)
      .distinct(:id)
  }

  geocoded_by :address
  after_validation :geocode

  CONTRACT_TYPES = ['commission', 'fixed_price'].freeze
  FIXED_PRICE_FREQUENCIES = ['monthly', 'yearly'].freeze
  RENTAL_TERMS = ['short_term', 'medium_term', 'long_term'].freeze

  validates_presence_of :name, :status, :address, :office_id, :min_price
  validates :name, uniqueness: true
  validates :contract_type, presence: true, inclusion: { in: CONTRACT_TYPES }
  validates :commission, presence: true, if: -> { contract_type == 'commission' }
  # validates :fixed_price_amount, presence: true, if: -> { contract_type == 'fixed_price' }
  # validates :fixed_price_frequency, presence: true, inclusion: { in: FIXED_PRICE_FREQUENCIES }, if: -> { contract_type == 'fixed_price' }

  PROPERTY_TYPES = {
    "1": "apartment",
    "17": "house"
  }

  EASTER_SEASON_FIRSTNIGHT = {
    2022 => Date.new(2022,4,2),
    2023 => Date.new(2023,4,1),
    2024 => Date.new(2024,3,23),
    2025 => Date.new(2025,4,12),
    2026 => Date.new(2026,3,28),
    2027 => Date.new(2027,3,20),
    2028 => Date.new(2028,4,8)
  }

  def all_group_photos_imported?
    return if vrgroup.nil?
    group_photos = vrgroup.photos.pluck(:id)
    group_photos.all? { |id| image_urls.pluck(:photo_id).include?(id) }
  end

  def display_name
    if send("title_#{I18n.locale.to_s}").present?
      send("title_#{I18n.locale.to_s}")
    else
      name
    end
  end

  def dates_with_rates
    rates.pluck(:firstnight, :lastnight).map do |range|
      { from: range[0], to: range[1] }
    end
  end

  def future_dates_with_rates
    rates.where("lastnight > ?", Date.today).pluck(:firstnight, :lastnight).map do |range|
      { from: range[0], to: range[1] }
    end
  end

  def future_booked_dates
    bookings.where("checkin > ?", Date.today).pluck(:checkin, :checkout).map do |range|
      { from: range[0], to: range[1] }
    end
  end

  def future_available_dates(start_date, end_date)
    # Calculate future dates with rates and future booked dates
    future_rates_ranges = future_dates_with_rates
    future_booked_ranges = future_booked_dates

    # Convert start_date and end_date to Date objects
    start_date = start_date.to_date
    end_date = end_date.to_date

    # Create a set of booked dates for faster lookup
    booked_dates_set = future_booked_ranges.flat_map { |range| (range[:from]..range[:to]).to_a }.to_set

    # Initialize an array to store available date ranges
    available_ranges = []

    # Iterate through the date range from start_date to end_date
    current_date = start_date
    while current_date <= end_date
      # Check if the current date is within any future date range with rates
      if future_rates_ranges.any? { |range| (range[:from]..range[:to]).cover?(current_date) }
        # Check if the current date is not booked
        unless booked_dates_set.include?(current_date)
          available_ranges << { from: current_date, to: current_date }
        end
      end

      # Move to the next day
      current_date += 1.day
    end

    return available_ranges
  end

  def other_statements_dates(statement=nil)
    other_statements = statement.nil? ? statements : statements.where.not(id: statement.id)
    other_statements.pluck(:start_date, :end_date).map do |range|
      { from: range[0], to: range[1] }
    end
  end

  def default_checkin
    last_rate = rates.find_by(lastnight: rates.maximum('lastnight'))
    last_rate.present? ? last_rate.lastnight + 1.day : Date.today
  end

  def commission_percentage
    number_to_percentage(commission * 100, precision: 4, separator: ',')
  end

  def default_statement_start
    last_statement = statements.find_by(end_date: statements.maximum('end_date'))
    last_statement.present? ? last_statement.end_date + 1.day : Date.new(Date.today.year, 1, 1)
  end

  def total_city_tax(from, to)
    return unless bookings.present?

    total_city_tax = { base: 0, vat: 0, tax: 0 }

    confirmed_bookings = self.bookings.where.not(status: "0")
    this_year_bookings = confirmed_bookings.where(checkin: from..to)

    this_year_bookings.each do |booking|
      city_tax_sum = booking.charges.where(charge_type: 'city_tax').sum(:price)

      total_city_tax[:tax] += city_tax_sum
      total_city_tax[:base] += city_tax_sum / 1.21
      total_city_tax[:vat] += city_tax_sum * 0.21
    end

    total_city_tax.each do |key, value|
      total_city_tax[key] = value.round(2)
    end

    total_city_tax
  end

  def upload_dates_to_rates(rate_plan)
    rate_plan.rate_periods&.each do |period|
      rate = Rate.new(
        firstnight: period.firstnight,
        lastnight: period.lastnight,
        min_stay: period.min_stay,
        arrival_day: period.arrival_day,
        vrental_id: id
      )
      unless rate.save(validate: false)
        logger.error "Unable to save rate for vrental_id: #{id}, errors: #{rate.errors.full_messages.join(", ")}"
      end
    end
  end

  def upload_dates_to_plan(year, rate_plan)
    rate_plan.rate_periods&.destroy_all
    year_rates = rates.where("DATE_PART('year', firstnight) = ?", year)

    if year_rates.empty?
      return :no_rates_found
    end

    year_rates.each do |rate|
      RatePeriod.create!(
        name: 'general',
        firstnight: rate.firstnight,
        lastnight: rate.lastnight,
        arrival_day: rate.arrival_day,
        min_stay: rate.min_stay,
        rate_plan_id: rate_plan.id
      )
    end
    :success
  end

  def rate_price(checkin, checkout)
    checkin = checkin.is_a?(Date) ? checkin : Date.parse(checkin)
    checkout = checkout.is_a?(Date) ? checkout : Date.parse(checkout)

    overlapping_rates = rates.where(
      "(firstnight <= ? AND lastnight >= ?) OR (firstnight <= ? AND lastnight >= ?) OR (firstnight >= ? AND lastnight <= ?)",
      checkin, checkin, checkout, checkout, checkin, checkout
    )
    return if overlapping_rates.empty?
    total_price = 0.0
    overlapping_rates.each do |rate|
      rate_start = [checkin, rate.firstnight].max
      rate_end = [checkout - 1, rate.lastnight].min  # Adjusted checkout to consider last affecting night

      days_overlap = (rate_end - rate_start + 1).to_i

      if rate.pricenight.present?
        price = checkout - checkin < 7 ? rate.pricenight * 1.11 : rate.pricenight
      elsif rate.priceweek.present?
        price = checkout - checkin < 7 ? rate.priceweek / 6.295 : rate.priceweek / 7
      end

      total_price += price * days_overlap
    end

    return total_price
  end

  def total_rate_price
    return unless bookings.present?
    total_rate_price = 0
    initial_bookings = bookings.where.not("firstname ILIKE ?", "%propietari%").where.not("lastname ILIKE ?", "%propietari%")
    real_bookings = initial_bookings.select { |booking| booking.price_with_portal != 0 }

    real_bookings.each do |booking|
      rate_price = booking.vrental.rate_price(booking.checkin, booking.checkout)
      total_rate_price += rate_price if rate_price
    end
    return total_rate_price
  end

  def self.calculate_total_rate_price_for_all
    total_rate_price_for_all = 0
    all_vrentals = Vrental.all

    all_vrentals.each do |vrental|
      total_rate_price_for_all += vrental.total_rate_price if vrental.total_rate_price
    end

    total_rate_price_for_all
  end

  def total_bookings
    return unless bookings.present?
    total_bookings = 0
    real_bookings = bookings.where.not("firstname ILIKE ?", "%propietari%").where.not("lastname ILIKE ?", "%propietari%")
    # exclude cancelled bookings with payment?
    real_bookings.each do |booking|
      total_bookings += booking.price_no_portal
    end
    return total_bookings
  end

  def total_earnings
    earnings.where.not(amount: nil).sum(:amount)
  end

  def total_statements
    total = 0
    statements.each do |statement|
      total += statement.total_statement_earnings
    end
    total
  end

  def total_net_owner
    total = 0
    statements.each do |statement|
      total += statement.net_income_owner
    end
    total
  end

  def total_owner_payments
    total = 0
    statements.each do |statement|
      total += statement.total_owner_payments if statement.total_owner_payments.present?
    end
    total
  end

  def owner_payment_difference
    total_net_owner - total_owner_payments
  end

  def difference_bookings
    total_rate_price - total_bookings
  end

  def difference_earnings
    total_rate_price - total_earnings
  end

  def agency_fees
    (total_earnings.present? && !commission.nil?) ? total_earnings * commission : nil
  end

  def self.total_agency_fees
    total_agency_fees = 0
    all_vrentals = Vrental.all

    all_vrentals.each do |vrental|
      total_agency_fees += vrental.agency_fees unless vrental.agency_fees.nil?
    end

    total_agency_fees
  end

  def this_year_statements(year)
    statements.where("EXTRACT(YEAR FROM start_date) = ?", year).order(:start_date)
  end

  def covered_periods(year)
    this_year_statements(year).map do |statement|
      [statement.start_date, statement.end_date]
    end.sort
  end

  def bookings_missing_statement(year)
    year_bookings = bookings.where("EXTRACT(YEAR FROM checkin) = ?", year)

    year_bookings.select do |booking|
      covered_periods(year).none? { |range| range[0] <= booking.checkin && booking.checkin <= range[1] }
    end.sort_by(&:checkin)
  end

  def periods_missing_statement(year)
    uncovered_periods = []

    covered = covered_periods(year)
    bookings = bookings_missing_statement(year)

    return uncovered_periods if bookings.empty?

    earliest_checkin = bookings.min_by(&:checkin).checkin
    latest_checkout = bookings.max_by(&:checkout).checkout

    if covered.empty?
      uncovered_periods = [[earliest_checkin, latest_checkout]]
    else
      if covered[0][0] > earliest_checkin
        uncovered_periods << [earliest_checkin, covered[0][0] - 1]
      end

      if covered[-1][1] < latest_checkout
        uncovered_periods << [covered[-1][1] + 1, latest_checkout]
      end
    end

    uncovered_periods
  end

  def expenses_without_statement
    expenses.where(statement_id: nil)
  end

  def this_year_invoices(year)
    invoices.where("EXTRACT(YEAR FROM date) = ?", year)
  end

  def statements_without_invoice(year)
    this_year_statements(year).where(invoice_id: nil)
  end

  def first_friday_on_or_after_june_20(year = Date.current.year)
    date = Date.new(year, 6, 20)
    date += 1 until date.friday?
    date
  end

  def delete_year_rates(year)
    rates.where("DATE_PART('year', firstnight) = ?", year).destroy_all
  end

  def copy_rates_to_next_year(current_year)
    current_rates = rates.where("DATE_PART('year', firstnight) = ?", current_year)
    current_rates.each do |existingrate|
    next_year = existingrate.firstnight.year + 1
    easter_season_firstnight = EASTER_SEASON_FIRSTNIGHT

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
      elsif easter_season_firstnight.value?(existingrate.firstnight - 10) && (existingrate.lastnight - existingrate.firstnight).to_i == 10 && !rates.where(firstnight: easter_season_firstnight[next_year] + 10).exists?
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
      else
        return
      end
    end
  end

  def beds_details
    all_beds = bedrooms.flat_map { |bedroom| bedroom.beds.pluck(:bed_type) }

    all_beds = all_beds.map { |bed_type| bed_type == "BED_BUNK" ? ["BED_SINGLE", "BED_SINGLE"] : bed_type }.flatten.tally

    abbreviation_mapping = {
      "BED_DOUBLE" => "DBL",
      "BED_SOFA" => "DSF"
    }
    details = []
    all_beds.each do |bed_type, count|
      abbr_type = abbreviation_mapping[bed_type] || "SGL"

      details << "#{count}#{I18n.t(abbr_type, count: count, locale: office.company.language)}"
    end

    details
  end


  def beds_room_type
    details = beds_details.join(", ")
    {
      "name": "#{I18n.t(property_type, locale: office.company.language)} #{name} #{details if details}",
      "qty": "1",
      "minPrice": min_price,
      "maxPeople": max_guests
    }
  end

  def get_availability_from_beds(checkin, checkout, guests)
    begin
      client = BedsHelper::Beds.new

      options = {
        "propId": beds_prop_id,
        "checkIn": checkin.delete("-"),
        "checkOut": checkout.delete("-"),
        "numAdult": guests || 1
      }

      response = client.get_availabilities(options)

      if response.code != 200
        raise StandardError, "Error: HTTP request failed with status code #{response.code}"
      end

      parsed_response = JSON.parse(response.body)

      result = {}
      if parsed_response[beds_room_id]["roomsavail"] != "0"
        rate_price = rate_price(checkin, checkout)
        result["ratePrice"] = rate_price.round(2) if rate_price
        result["updatedPrice"] = parsed_response[beds_room_id]["price"]
        if (parsed_response[beds_room_id]["price"]).nil?
          result["notAvailable"] = "No availability"
        end
      elsif parsed_response[beds_room_id]["roomsavail"] == "0"
        result["notAvailable"] = "No availability"
      end
      return result

    rescue StandardError => e
      # Handle any exceptions that occurred during execution
      puts "Error: #{e.message}"
      return {} # Return an empty hash or handle the error as needed
    end
  end

  def update_vrental_on_beds
    client = BedsHelper::Beds.new(office.beds_key)
    beds24rentals_prop_names = Set.new(client.get_properties.map { |bedsrental| bedsrental["name"] })

    if beds24rentals_prop_names.include?(name)
      bedsrental = [
          {
            "action": "modify",
            "roomTypes": [
              {
                "action": "modify",
                "roomId": beds_room_id
              }.merge(beds_room_type)
            ]
          }
      ]
      client.set_property(prop_key, setProperty: bedsrental)
    else
      new_bedrentals = []
      new_bedrental = {
        name: name,
        prop_key: prop_key,
        roomTypes: [
          beds_room_type
        ]
      }
      new_bedrentals << new_bedrental
      response = client.create_properties(createProperties: new_bedrentals)

      beds_prop_id = response[0]["propId"]
      beds_room_id = response[0]["roomTypes"][0]["roomId"]
      save!
    end
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

      image_url = image_urls.find_or_initialize_by(url: new_url)

      if image_url.persisted?
        image_url.update!(position: photo_hash["position"])
      else
        image_url.position = photo_hash["position"]
        image_url.vrental_id = id
        image_url.save!
      end
    end
  end

  def send_photos_to_beds
    images_array = []
    external = {}

    image_urls.each_with_index do |image, index|
      if image.url.include?("cloudinary") && !image.url.include?("q_auto:good")
        url = image.url.gsub(/\/upload\//, '/upload/q_auto:good/')
      else
        url = image.url
      end
      external["#{index + 1}"] = {
        url: url,
        map: [
          {
            propId: "#{beds_prop_id}",
            position: "#{image.position}"
          }
        ]
      }
    end

    if town.present? && town.photos.attached?
      town.photos.each do |photo|
        external["#{external.length + 1}"] = {
          url: photo.url.gsub(/\/upload\//, '/upload/q_auto:good/'),
          map: [
            {
              propId: "#{beds_prop_id}",
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
            propId: "#{beds_prop_id}",
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

    client = BedsHelper::Beds.new(office.beds_key)
    client.set_property_content(prop_key, setPropertyContent: images_array)
  end

  def update_owner_from_beds
    client = BedsHelper::Beds.new(office.beds_key)
    begin
      property = client.get_property(prop_key)[0]
      existing_owner = Owner.find_by(fullname: property["template1"])
      if owner.present?
        if existing_owner.present? && existing_owner != owner
          self.update!(owner: existing_owner)
        elsif existing_owner.present? && existing_owner == owner
          owner.update!(
            fullname: property["template1"],
            document: property["template5"],
            address: property["template2"],
            email: property["template4"],
            phone: property["template3"],
            account: property["template6"],
            beds_room_id: property["roomTypes"][0]["roomId"],
            )
        end
      elsif !owner.present? && existing_owner.present?
        self.update!(owner: existing_owner)
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
          user: user,
          vrental_id: id
          )
      end
      sleep 2
    rescue StandardError => e
      Rails.logger.error("Error al importar propietari de Beds24: #{e.message}")
    end
  end

  def api_call_get_property_content
    @cached_property_content ||= nil

    if @cached_property_content.nil?
      client = BedsHelper::Beds.new(office.beds_key)
      begin
        @cached_property_content = client.get_property_content(prop_key, images: true, roomIds: true)[0]
      rescue => e
        puts "Error getting property content for #{name}: #{e.message}"
      end
      sleep 2
    end

    @cached_property_content
  end

  def get_property_photos_from_beds
    beds24content = api_call_get_property_content

    return beds24content["images"]["external"].select { |key, image| image["url"] != "" }
  end

  def get_room_photos_from_beds
    beds24content = api_call_get_property_content

    return beds24content["roomIds"][beds_room_id]["images"]["external"].select { |key, image| image["url"] != "" }
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
              propId: "#{self.beds_prop_id}",
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
              propId: "#{self.beds_prop_id}",
              position: "#{index}"
            }
          ]
        }
      end

      # delete all hosted images (api doesn't allow this currently)
      # beds24photos_hosted = beds24content["images"]["hosted"]

      # hosted_photos = {}
      # number_of_hosted_photos = beds24photos_hosted.length
      # number_of_hosted_photos.times do |index|
      #   hosted_photos["#{index + 1}"] = {
      #     url: "",
      #     map: beds24photos_hosted["#{index + 1}"]["map"]
      #   }
      # end
      # trying another way
      # beds24photos_hosted.each do |key, photo|
      #   hosted_photos[key] = {}
      # end

      images_array = []
      property_images = {
        action: "modify",
        images: {
          external: external
        }
      }
      images_array << property_images

      client.set_property_content(prop_key, setPropertyContent: images_array)
    rescue => e
      puts "Error deleting photos for #{name}: #{e.message}"
    end
    sleep 2
  end

  def update_vrental_from_beds
    client = BedsHelper::Beds.new(office.beds_key)
    begin
      property = client.get_property(prop_key, includeRooms: true)[0]
      vrental_room = property["roomTypes"].find { |room| room["roomId"] == beds_room_id }
        self.update!(
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

  def get_content_from_beds
    # add check for minimum stay, and set min_stay and rental_term accordingly
    # also get the booking conditions (deposit payment (30%?) cancellation policy (14 days?))
    # also set status to inactive if no rates or no bookings this year, whatever's easier
    client = BedsHelper::Beds.new(office.beds_key)
    begin
      vrental_property = client.get_property_content(prop_key, roomIds: true, texts: true, includeAirbnb: true)[0]
      vrental_room = vrental_property["roomIds"][beds_room_id]

      update!(
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

      puts "Updated titles and texts for #{name}!"

      if vrental_room["featureCodes"].present?
        accepted_features = Feature::FEATURES
        # beds24features = vrental_room["featureCodes"].flatten.map(&:downcase)
        beds24features = vrental_room["featureCodes"].flatten.map do |code|
          code.downcase == 'ocean_view' ? 'sea_view' : code.downcase
        end

        puts "beds24features: #{beds24features}"

        selected_features = beds24features.select { |feature| accepted_features.include?(feature) }

        if selected_features.include?("beach_view")
          features << Feature.where(name: "sea_view")
        end

        selected_features.each do |feature|
          existing_feature = Feature.find_or_create_by(name: feature)
          features << existing_feature unless features.include?(existing_feature)
        end

        save!

        features.each do |feature|
          unless selected_features.include?(feature.name)
            features.delete(feature)
            save!
          end
        end

        beds24bedrooms = vrental_room["featureCodes"].select { |feature| feature.any? { |word| word.starts_with?("BEDROOM") } }

        puts "these are the bedrooms for #{name}: #{beds24bedrooms}"

        beds24bedrooms.each_with_index do |room_data, index|
          room_type = room_data.select { |word| word.starts_with?("BEDROOM") }.first
          room_bed_types = room_data.select { |word| word.starts_with?("BED_") }

          bedroom = bedrooms[index]

          if bedroom
            room_bed_types.each do |bed_type|
              bedroom.beds.find_or_create_by(bed_type: bed_type, bedroom: bedroom)
            end
          else
            bedroom = bedrooms.create!(bedroom_type: room_type, vrental_id: id)
            room_bed_types.each do |bed_type|
              bedroom.beds.create!(bed_type: bed_type, bedroom: bedroom)
            end
          end
        end

        if beds24bedrooms.length < bedrooms.length
          bedrooms.last(bedrooms.length - beds24bedrooms.length).each do |bedroom|
            bedroom.destroy
          end
        end

        beds24bathrooms = vrental_room["featureCodes"].select { |feature| feature.any? { |word| word.starts_with?("BATHROOM") } }
        existing_bathrooms = {}
        bathrooms.each { |bathroom| existing_bathrooms[bathroom.bathroom_type] ||= [] }
        bathrooms.each { |bathroom| existing_bathrooms[bathroom.bathroom_type] << bathroom }

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
            bathrooms.create!(bathroom_type: bathroom_type, vrental_id: id)
          end
        end
        existing_bathrooms.values.flatten.each(&:destroy)
        puts "Imported features, bedrooms and bathrooms for #{name}!"
      end
    rescue => e
      puts "Error importing content for #{name}: #{e.message}"
    end
    sleep 2
  end

  def get_rates_from_beds
    client = BedsHelper::Beds.new(office.beds_key)

    beds24rates = client.get_rates(prop_key)

    if beds24rates.success?
      parsed_response = beds24rates.parsed_response
      found_error = false
      if parsed_response.is_a?(Hash) && parsed_response.key?("error")
        found_error = true
        error_message = parsed_response["error"]
        error_code = parsed_response["errorCode"]
        # Handle the error message and error code as needed
        puts "Error: #{error_message}, ErrorCode: #{error_code}"
        return error_message
      end

      unless found_error
        if beds24rates.empty?
          return
        end
        rates_by_firstnight = beds24rates.group_by { |rate| rate["firstNight"] }
        selected_rates = []
        rates_by_firstnight.each do |_firstnight, rates|
          rates_with_prices_per_7 = rates.select { |rate| rate["pricesPer"] == "7" }
          if rates_with_prices_per_7.any?
            selected_rates.concat(rates_with_prices_per_7)
          else
            selected_rates << rates.find { |rate| rate["pricesPer"] == "1" }
          end
        end
        selected_rates.each do |rate|
            if rate["firstNight"].delete("-").to_i > 20230101

              existing_rate = rates.find_by(firstnight: rate["firstNight"].to_date)

              if existing_rate
                existing_rate.update!(
                  beds_rate_id: rate["rateId"],
                  lastnight: rate["lastNight"],
                  priceweek: rate["pricesPer"] == "7" ? rate["roomPrice"].to_f : (rate["roomPrice"].to_f * 6.295),
                  beds_room_id: rate["roomId"],
                )
              else
                Rate.create!(
                  beds_rate_id: rate["rateId"],
                  firstnight: rate["firstNight"],
                  lastnight: rate["lastNight"],
                  priceweek: rate["pricesPer"] == "7" ? rate["roomPrice"].to_f : (rate["roomPrice"].to_f * 6.295),
                  beds_room_id: rate["roomId"],
                  vrental_id: id,
                  min_stay: 5,
                  arrival_day: 'everyday'
                )
              end
            end
          end
      else
        return
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

  def get_bookings_from_beds(from_date)
    client = BedsHelper::Beds.new(office.beds_key)
    options = {
      "arrivalFrom": from_date || Date.today.beginning_of_year.to_s,
      "arrivalTo": Date.today.to_s,
      "includeInvoice": true,
    }
    beds24bookings = client.get_bookings(prop_key, options)

    if beds24bookings.success?
      parsed_response = beds24bookings.parsed_response
      found_error = false
      if parsed_response.is_a?(Hash) && parsed_response.key?("error")
        found_error = true
        error_message = parsed_response["error"]
        error_code = parsed_response["errorCode"]
        # Handle the error message and error code as needed
        puts "#{self.name} with prop_key: #{self.prop_key}: Error: #{error_message}, ErrorCode: #{error_code}"
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
          if booking = bookings.find_by(beds_booking_id: beds_booking["bookId"].to_i)
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

        bookings_to_delete = bookings.where('checkin >= ?', from_date.to_date).where.not(beds_booking_id: selected_bookings.map { |beds_booking| beds_booking['bookId'] })

        if bookings_to_delete.any?
          bookings_to_delete.destroy_all
        end
      end
    else
      return
    end
    sleep 3
  end

  def add_booking(beds_booking, tourist)
    status = beds_booking["status"] == "2" ? "1" : beds_booking["status"]
    Booking.create!(
      vrental_id: self.id,
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
    rate_price = booking.vrental.rate_price(booking.checkin, booking.checkout)&.round(2)
    if rate_price.present?
      price = [booking.net_price, rate_price].min

      discount = rate_price == 0 ? 0 : (rate_price - price) / rate_price

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

  def delete_this_year_rates_on_beds
    client = BedsHelper::Beds.new(office.beds_key)
    beds24rates = client.get_rates(prop_key)
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
    client.set_rates(prop_key, setRates: rates_to_delete)
    rates_to_send_again = Rate.where("lastnight > ?", Date.today)
    rates_to_send_again.each do |rate|
      rate.sent_to_beds = nil
      rate.date_sent_to_beds = nil
      rate.save!
    end
  end

  def send_rates_to_beds
    client = BedsHelper::Beds.new(office.beds_key)

    beds24rates = client.get_rates(prop_key)
    # Then we select the rates older than 2 years for deletion
    rates_to_delete = []
    beds24rates.each do |rate|
      if rate["firstNight"].to_date.year < (Date.today.year - 2)
        rate_to_delete = {
          action: "delete",
          rateId: "#{rate["rateId"]}",
          roomId: "#{rate["roomId"]}"
      }
        rates_to_delete << rate_to_delete
      end
    end

    client.set_rates(prop_key, setRates: rates_to_delete)

    vrental_rates = []

    vr_rates = rates.where("lastnight > ?", Date.today)

    vr_rates.each do |rate|
      rate_exists_on_beds_id = beds24rates.any? { |beds_rate| beds_rate["rateId"] == rate.beds_rate_id }

      general_rate_exists_on_beds_dates = beds24rates.any? { |beds_rate| beds_rate["firstNight"].to_date == rate.firstnight && beds_rate["lastNight"].to_date == rate.lastnight && beds_rate["pricesPer"] == "1" }

      weekly_rate_exists_on_beds_dates = beds24rates.any? { |beds_rate| beds_rate["firstNight"].to_date == rate.firstnight && beds_rate["lastNight"].to_date == rate.lastnight && beds_rate["pricesPer"] == "7" }

      general_rate =
        {
        action: (rate_exists_on_beds_id || general_rate_exists_on_beds_dates) ? "modify" : "new",
        roomId: "#{beds_room_id}",
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
        action: (rate_exists_on_beds_id || weekly_rate_exists_on_beds_dates) ? "modify" : "new",
        roomId: "#{beds_room_id}",
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

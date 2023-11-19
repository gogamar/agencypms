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
  belongs_to :master_vrental, class_name: 'Vrental', optional: true
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
  PRICE_PER = ['night', 'week'].freeze
  RATE_OFFSET_TYPE = {
    "1" => "percentage offset",
    "2" => "per booking offset",
    "3" => "per day offset",
    "4" => "per person per day offset",
    "5" => "no offset",
    "6" => "per period offset"
}.freeze

  validates_presence_of :name, :status, :address, :office_id
  # validates_presence_of :min_price
  validates :name, uniqueness: true
  validates :contract_type, presence: true, inclusion: { in: CONTRACT_TYPES }
  validates :commission, presence: true, if: -> { contract_type == 'commission' }
  # validates :price_per, presence: true, inclusion: { in: PRICE_PER }
  validates :weekly_discount_included, presence: true, if: -> { price_per == 'week' && weekly_discount.present? }
  # validate :cannot_reference_self_as_master
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

  def real_bedrooms
    bedrooms.where(bedroom_type: "BEDROOM")
  end

  def living_room_bedrooms
    bedrooms.where(bedroom_type: "BEDROOM_LIVING_SLEEPING_COMBO")
  end

  def future_rates
    rates.where('lastnight > ?', Date.today)
  end

  def years_with_rates
    years_with_rates = rates.map { |rate| rate.firstnight.year }
    unique_years_with_rates = years_with_rates.uniq
    unique_years_with_rates.sort.reverse
  end

  def dates_with_rates(fnight = nil, lnight = nil)
    rates.pluck(:firstnight, :lastnight).map do |range|
      from = range[0]
      to = range[1]

      # Check if the current range overlaps with or is contained within the specified period
      if fnight.present? && lnight.present? && from <= fnight && to >= lnight
        nil # Exclude this range
      else
        { from: from, to: to }
      end
    end.compact # Remove any nil entries
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

  def years_possible_contract
    return if rates.empty?
    years_with_contract = vragreements.pluck(:year)

    last_rate_year = rates.order(firstnight: :desc).first.firstnight.year
    current_year = Date.today.year

    if last_rate_year > current_year
      (current_year..last_rate_year).to_a - years_with_contract
    elsif last_rate_year == current_year
      [current_year] - years_with_contract
    else
      []
    end
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

  private

  def cannot_reference_self_as_master
    if id == master_vrental_id
      errors.add(:master_vrental_id, "cannot reference itself")
    end
  end
end

class Vrental < ApplicationRecord
  require 'net/http'
  include ActionView::Helpers::NumberHelper
  extend FriendlyId
  friendly_id :name, use: :slugged
  belongs_to :owner, optional: true
  belongs_to :office, optional: true
  belongs_to :town, optional: true
  belongs_to :rate_plan, optional: true
  belongs_to :rate_master, class_name: 'Vrental', optional: true
  has_many :sub_rate_vrentals, class_name: 'Vrental', foreign_key: 'rate_master_id'
  has_many :bedrooms, dependent: :destroy
  has_many :bathrooms, dependent: :destroy
  accepts_nested_attributes_for :bedrooms,
                                allow_destroy: true,
                                reject_if: proc { |att| att['bedroom_type'].blank? }
  accepts_nested_attributes_for :bathrooms,
                                allow_destroy: true,
                                reject_if: proc { |att| att['bathroom_type'].blank? }
  has_many :vragreements, dependent: :destroy
  has_many :rates, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :owner_bookings, dependent: :destroy
  has_many :expenses
  has_many :earnings
  has_many :statements
  has_many :invoices
  has_many :availabilities, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :cleaning_schedules, dependent: :destroy
  has_and_belongs_to_many :features
  has_and_belongs_to_many :coupons
  has_and_belongs_to_many :vrgroups
  has_many :image_urls, dependent: :destroy
  has_many_attached :photos

  scope :with_valid_prop_key, -> { where.not(prop_key: [nil, ""]) }

  scope :with_future_rates, lambda {
    where(
      "rate_master_id IS NULL AND EXISTS (SELECT 1 FROM rates WHERE rates.vrental_id = vrentals.id AND rates.firstnight > ?)" +
      " OR " +
      "rate_master_id IS NOT NULL AND EXISTS (SELECT 1 FROM rates WHERE rates.vrental_id = vrentals.rate_master_id AND rates.firstnight > ?)",
      Date.today,
      Date.today
    )
  }
  scope :with_image_urls, -> { joins(:image_urls).where.not(image_urls: { id: nil }).distinct }

  scope :with_availabilities, -> {
    joins(:availabilities)
      .where("availabilities.date >= ? AND availabilities.override = ?", Date.today, 0)
      .distinct
  }

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

  validates_presence_of :name, :address, :property_type
  validates :name, uniqueness: true
  validates :commission, presence: true, if: -> { contract_type == 'commission' }
  before_update :update_slug

  # fixme check and apply validations
  # validates :unit_number, numericality: { greater_than_or_equal_to: 0 }
  # validates_presence_of :min_price
  # validates :contract_type, presence: true, inclusion: { in: CONTRACT_TYPES }
  # validates :price_per, presence: true, inclusion: { in: PRICE_PER }
  # fixme - on copying this kept giving error, perhaps because it's nil and nil == nil
  # validate :cannot_reference_self_as_rate_master
  # validates :fixed_price_amount, presence: true, if: -> { contract_type == 'fixed_price' }
  # validates :fixed_price_frequency, presence: true, inclusion: { in: FIXED_PRICE_FREQUENCIES }, if: -> { contract_type == 'fixed_price' }

  CONTRACT_TYPES = ['commission', 'fixed_price'].freeze
  FIXED_PRICE_FREQUENCIES = ['monthly', 'yearly'].freeze
  RENTAL_TERMS = ['short_term', 'medium_term', 'long_term'].freeze
  PRICE_PER = ['night', 'week'].freeze

  # fixme: there is inconsistency with airbnb settings for property in beds24 api so it's better to just use the word here and send it to beds24 according to their api
  PROPERTY_TYPES = {
    "1" => "apartment",
    "17" => "house"
  }

  PROPERTY_STATUS = ["proposal", "active", "inactive"].freeze

  EASTER_SEASON_FIRSTNIGHT = {
    2022 => Date.new(2022,4,2),
    2023 => Date.new(2023,4,1),
    2024 => Date.new(2024,3,23),
    2025 => Date.new(2025,4,12),
    2026 => Date.new(2026,3,28),
    2027 => Date.new(2027,3,20),
    2028 => Date.new(2028,4,8)
  }

  NO_CHECKIN = {
    1 => 'monday',
    2 => 'tuesday',
    3 => 'wednesday',
    4 => 'thursday',
    5 => 'friday',
    6 => 'saturday',
    0 => 'sunday',
    7 => 'checkin_any_day'
  }

  CONTROL_RESTRICTIONS = [
    "calendar_beds24",
    "rates"
  ]

  def owner_attr
    { "status" => status.present? ? I18n.t(status) : "",
      "property_type" => property_type.present? ? I18n.t(property_type) : "",
      "name" => name,
      "address" => address,
      "licence" => licence,
      "cadastre" => cadastre,
      "habitability" => habitability,
      "max_guests" => max_guests,
      "min_stay" => min_stay,
      "rental_term" => rental_term.present? ? I18n.t(rental_term) : "",
      "price_per" => price_per.present? ? I18n.t(price_per, count: 1) : "",
      "weekly_discount" => weekly_discount.present? ? number_to_percentage(weekly_discount, precision: 0, separator: ',') : "",
      "min_advance" => min_advance.present? ? "#{min_advance}h" : "" }
  end

  def admin_attr
    { "contract_type" => contract_type.present? ? I18n.t(contract_type) : "",
      "commission" => commission.present? ? number_to_percentage(commission * 100, precision: 2, separator: ',') : "",
      "res_fee" => res_fee.present? ? number_to_percentage(res_fee * 100, precision: 2, separator: ',') : "",
      "free_cancel" => free_cancel.present? ? "#{free_cancel} #{I18n.t('days')}" : "",
      "min_price" => min_price.present? ? number_to_currency(min_price, unit: "€", separator: ",", delimiter: ".", precision: 2, format: "%n%u") : "",
      "cleaning_fee" => cleaning_fee.present? && cleaning_fee != 0 ? number_to_currency(cleaning_fee, unit: "€", separator: ",", delimiter: ".", precision: 2, format: "%n%u") : "",
      "cut_off_hour" => cut_off_hour.present? && cut_off_hour != 0 ? "#{cut_off_hour}h" : "",
      "checkin_start_hour" => checkin_start_hour.present? && checkin_start_hour != '0.0' ? "#{checkin_start_hour}h" : "",
      "checkin_end_hour" => checkin_end_hour.present? && checkin_end_hour != '0.0' ? "#{checkin_end_hour}h" : "",
      "checkout_end_hour" => checkout_end_hour.present? && checkout_end_hour != '0.0' ? "#{checkout_end_hour}h" : "" }
  end

  def vrental_company
    if office.present?
      office.company
    elsif owner.present?
      owner.user.company
    end
  end

  def all_group_photos_imported(vrgroup)
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

  def display_name_max_guests(language)
    if property_type.present?
      "#{I18n.t(property_type, locale: language)&.upcase} #{name&.upcase} (#{max_guests} #{I18n.t('guests', locale: language)} max.)"
    end
  end

  def real_bedrooms
    bedrooms.where(bedroom_type: "BEDROOM")
  end

  def living_room_bedrooms
    bedrooms.where(bedroom_type: "BEDROOM_LIVING_SLEEPING_COMBO")
  end

  def future_rates
    if rate_master.present?
      rate_master.rates.where('lastnight > ?', Date.today)
    else
      rates.where('lastnight > ?', Date.today)
    end
  end

  def find_price(date)
    specific_date = date.is_a?(Date) ? date : Date.parse(date)

    matching_rate = future_rates.find do |future_rate|
      (future_rate.firstnight..future_rate.lastnight).cover?(specific_date)
    end

    matching_rate.pricenight if matching_rate
  end

  def price_with_coupon(price)
    coupon_discount = coupons.first.amount_discounted(price)
    price.to_f - coupon_discount
  end

  def years_with_rates
    years_with_rates = rates.map { |rate| rate.firstnight.year }
    unique_years_with_rates = years_with_rates.uniq
    unique_years_with_rates.sort.reverse
  end

  def dates_with_rates(fnight = nil, lnight = nil)
    future_rates.pluck(:firstnight, :lastnight).map do |range|
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

  def first_future_date_without_rate
    future_rates = rates.where("lastnight > ?", Date.today).order(:firstnight)
    date_without_rate = Date.today

    future_rates.each do |rate|
      if rate.firstnight > date_without_rate
        return date_without_rate
      end
      date_without_rate = rate.lastnight + 1.day
    end
    return date_without_rate
  end

  def add_availability(from, to)
    from = from.is_a?(Date) ? from : Date.parse(from)
    to = to.is_a?(Date) ? to : Date.parse(to)

    dates_with_rates(from, to).each do |range|
      from = range[:from]
      to = range[:to]

      (from..to).each do |date|
        availabilities.create(date: date, inventory: unit_number)
      end
    end
  end

  def future_dates_with_rates
    vrental_instance = rate_master_id.present? ? rate_master : self
    vrental_instance.rates.where("lastnight >= ?", Date.today).pluck(:firstnight, :lastnight).map do |range|
      { from: range[0], to: range[1] }
    end
  end

  def future_booked_dates
    bookings_dates = future_booked_dates_for_table(:bookings)
    owner_bookings_dates = future_booked_dates_for_table(:owner_bookings)

    bookings_dates.concat(owner_bookings_dates)
  end

  def future_bookings
    bookings.where("checkout > ?", Date.today)
  end

  def future_availabilities
    if min_advance.present?
      limit_date = Date.today + min_advance.hours
    else
      limit_date = Date.today
    end
    @future_availabilities ||= availabilities.where("date >= ?", limit_date).where("inventory > 0").order(:date)
  end

  def available_dates
    @available_dates ||= future_availabilities.pluck(:date)
  end



  def available_for_checkin
    @available_for_checkin ||= begin
      checkin_dates = future_availabilities.where.not(override: [2, 4]).pluck(:date)

      checkin_dates = checkin_dates.select do |date|
        possible_lastnight = date + (rate_min_stay(date) - 1)
        available_dates.include?(possible_lastnight)
      end

      checkin_dates.sort
    end
  end


  def available_for_checkout(checkin_date=nil)
    if checkin_date
      # return only the checkout dates that fulfill the min_stay requirement & there are no reservations in between
      checkin_date = checkin_date.is_a?(Date) ? checkin_date : Date.parse(checkin_date)
      first_possible_checkout_date = checkin_date + rate_min_stay(checkin_date).days
      available_after_checkin = future_availabilities.where("date >= ?", checkin_date)
      if available_after_checkin.present?
        checkout_dates = available_after_checkin.pluck(:date).map { |date| date + 1.day }
      end

      viable_checkout_dates = []
      current_date = first_possible_checkout_date

      while checkout_dates.include?(current_date)
        # fixme: currently not importing availabilities with inventory 0 so this wouldn't do anything if the date is not among availabilites
        # available_date = availabilities.find_by(date: current_date)
        # checkout_allowed = available_date.override != 3 && available_date.override != 4
        # if checkout_allowed
          viable_checkout_dates << current_date
        # end
        current_date += 1.day
      end
      viable_checkout_dates
    else
      future_available_dates = future_availabilities.where.not(override: [3, 4])
      if future_available_dates.present?
        future_available_dates.pluck(:date).map { |date| date + 1.day }
      end
    end
  end

  def rate_min_stay(checkin)
    if checkin.present?
      checkin = checkin.is_a?(Date) ? checkin : Date.parse(checkin)
      vrental_instance = rate_master_id.present? ? rate_master : self
      days_till_checkin = (checkin - Date.today).to_i
      checkin_rates = vrental_instance.rates.where("firstnight <= ? AND lastnight >= ? AND max_advance >= ?", checkin, checkin, days_till_checkin)

      checkin_rate = checkin_rates.order(:min_stay).first
      return (checkin_rate.present? && checkin_rate.min_stay != 0) ? (checkin_rate.min_stay || self.min_stay || 1) : (self.min_stay || 1)
    else
      return self.min_stay || 1
    end
  end

  def lowest_future_price
    vrental_rate_instance = rate_master_id.present? ? Vrental.find_by(id: rate_master_id) : self

    if vrental_rate_instance.future_rates.present?
      lowest_rate_price = vrental_rate_instance.future_rates.minimum(:pricenight)
    end

    future_discounts = availabilities.where("date > ?", Date.today).where("multiplier < ? AND multiplier > ?", 100, 0)

    if future_discounts
      biggest_discount = future_discounts.order(multiplier: :asc).first
      price_on_date = vrental_rate_instance.find_price(biggest_discount.date) if biggest_discount.present?
      lowest_discount_price = price_on_date * (biggest_discount.multiplier.to_f / 100.0) if price_on_date.present?
    end

    best_price = [lowest_rate_price, lowest_discount_price].compact.min

    if rate_offset.present?
      best_price = best_price + (best_price * (rate_offset / 100))
    end

    best_price
  end

  def other_statements_dates(statement=nil)
    other_statements = statement.nil? ? statements : statements.where.not(id: statement.id)
    other_statements.pluck(:start_date, :end_date).map do |range|
      { from: range[0], to: range[1] }
    end
  end

  def years_possible_contract
    return if future_rates.empty?
    years_with_contract = vragreements.pluck(:year)
    puts "years_with_contract: #{years_with_contract}"
    vrental_instance = rate_master.present? ? rate_master : self

    last_rate_year = vrental_instance.rates.order(firstnight: :desc).first.firstnight.year
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

    vrental_instance = rate_master_id.present? ? rate_master : self

    overlapping_rates = vrental_instance.rates.where(
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
        price = rate_offset.present? ? rate.pricenight + (rate.pricenight * (self.rate_offset / 100)) : rate.pricenight
      end

      total_price += (price * days_overlap)
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

  def total_net_owner_year(year)
    total = 0
    this_year_statements(year).each do |statement|
      total += statement.net_income_owner
    end
    total
  end

  def total_owner_payments_year(year)
    total = 0
    this_year_statements(year).each do |statement|
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
    next_year = current_year.to_i + 1

    current_rates = rates.where("DATE_PART('year', firstnight) = ?", current_year)
    current_easter_date = EASTER_SEASON_FIRSTNIGHT[current_year.to_i]

    current_easter_rate = current_rates.where("firstnight = ? OR lastnight = ? OR (firstnight < ? AND lastnight > ?)", current_easter_date, current_easter_date, current_easter_date, current_easter_date).first

    next_easter_date = EASTER_SEASON_FIRSTNIGHT[next_year]

    if current_easter_rate
      puts "current_easter_rate: #{current_easter_rate.firstnight}"
      starts_x_days_before_easter = (current_easter_date - current_easter_rate.firstnight).to_i
      ends_x_days_after_easter = (current_easter_rate.lastnight - current_easter_date).to_i
    end

    current_rates.each do |current_rate|
      rate_firstnight = current_rate.firstnight + 364
      rate_lastnight = current_rate.lastnight + 364

      if current_easter_rate
        if current_rate == current_easter_rate
          rate_firstnight = next_easter_date - starts_x_days_before_easter
          rate_lastnight = next_easter_date + ends_x_days_after_easter
          # if the rate is immediately before the easter rate
        elsif current_rate.lastnight == current_easter_rate.firstnight - 1
          rate_lastnight = next_easter_date - starts_x_days_before_easter - 1
          copy_duration_firstnight = rate_lastnight - (current_rate.lastnight - current_rate.firstnight).to_i
          rate_firstnight = copy_duration_firstnight > rate_firstnight ? rate_firstnight : copy_duration_firstnight
          # if rate with normal restriction is overlapping before this one, move its lastnight back
          overlapping_rates = rates.where("firstnight < :firstnight AND lastnight > :firstnight AND restriction = :restriction", firstnight: rate_firstnight, lastnight: rate_lastnight, restriction: current_rate.restriction)
          if overlapping_rates.present?
            overlapping_rates.each do |overlapping_rate|
              overlapping_rate.update(lastnight: rate_firstnight - 1)
            end
          end
        # if the rate is immediately after the easter rate
        elsif current_rate.firstnight == current_easter_rate.lastnight + 1
          rate_firstnight = next_easter_date + ends_x_days_after_easter + 1
          copy_duration_lastnight = rate_firstnight + (current_rate.lastnight - current_rate.firstnight).to_i
          rate_lastnight = copy_duration_lastnight < rate_lastnight ? rate_lastnight : copy_duration_lastnight
          # if rate with normal restriction is overlapping after this one, move its firstnight forward
          overlapping_rates = rates.where("firstnight < :lastnight AND lastnight > :lastnight AND restriction = :restriction", firstnight: rate_firstnight, lastnight: rate_lastnight, restriction: current_rate.restriction)
          if overlapping_rates.present?
            overlapping_rates.each do |overlapping_rate|
              overlapping_rate.update(firstnight: rate_lastnight + 1)
            end
          end
        end
      end

      if self.rates.where(pricenight: current_rate.pricenight, firstnight: rate_firstnight, lastnight: rate_lastnight).exists?
        next
      else
        Rate.create!(
          firstnight: rate_firstnight,
          lastnight: rate_lastnight,
          priceweek: current_rate.priceweek,
          pricenight: current_rate.pricenight,
          beds_room_id: current_rate.beds_room_id,
          vrental_id: current_rate.vrental_id,
          min_stay: current_rate.min_stay,
          arrival_day: current_rate.arrival_day,
          nights: current_rate.nights,
          max_stay: current_rate.max_stay,
          min_advance: current_rate.min_advance,
          restriction: current_rate.restriction,
          max_advance: current_rate.max_advance
        )
      end
    end
  end

  def feature_codes_bedroom_bathrooms
    feature_codes = []
    features.each do |feature|
      feature_codes << [feature.name.upcase]
    end
    bedroom_codes = []
    bedrooms.each do |bedroom|
      bedroom_code = [bedroom.bedroom_type.upcase]
      bedroom.beds.each do |bed|
        bedroom_code << [bed.bed_type.upcase]
      end
      bedroom_codes << bedroom_code.flatten
    end
    bathroom_codes = []
    bathrooms.each do |bathroom|
      bathroom_codes << ["BATHROOM", bathroom.bathroom_type.upcase]
    end
    feature_codes + bedroom_codes + bathroom_codes
  end

  def wifi_status
    if features && features.any? { |feature| feature.name == "wifi" }
      "HAS_WIFI"
    else
      "NO_WIFI"
    end
  end

  def pets_json
    if features && features.any? { |feature| feature.name == "pets_considered" }
      {
        "type": "1",
        "price": "7.0000",
        "unit": "0",
        "period": "0",
        "vat": "0.00",
        "image": "0",
        "description": {
          "EN": "Pet fee",
          "CA": "Mascota",
          "ES": "Mascota",
          "FR": "Animal de compagnie"
        }
      }
    else
      {
        "type": "",
        "price": "",
        "unit": "",
        "period": "",
        "vat": "",
        "image": "",
        "description": {
          "EN": "",
          "CA": "",
          "ES": "",
          "FR": ""
        }
      }
    end
  end

  def city_tax_daily_json
    if town && town.city_tax
      daily_city_tax = number_to_currency(town.city_tax, unit: "€", separator: ",", delimiter: ".", precision: 2, format: "%n%u")
      {
        "type": "1",
        "price": daily_city_tax,
        "unit": "2",
        "period": "1",
        "vat": "10.00",
        "image": "0",
        "description": {
          "EN": "Tourist tax #{town.city_tax} per adult / per night",
          "CA": "Taxa turística #{town.city_tax} per adult / per nit",
          "ES": "Tasa turística #{town.city_tax} por adulto / por noche",
          "FR": "Taxe de séjour #{town.city_tax} par adulte / par nuit"
        }
      }
    end
  end

  def city_tax_weekly_json
    if town && town.city_tax
      weekly_city_tax = number_to_currency((town.city_tax * 7), unit: "€", separator: ",", delimiter: ".", precision: 2, format: "%n%u")
      {
        "type": "1",
        "price": weekly_city_tax,
        "unit": "2",
        "period": "1",
        "vat": "10.00",
        "image": "0",
        "description": {
          "EN": "Tourist tax #{town.city_tax} per adult / per night (for the first 7 nights)",
          "CA": "Taxa turística #{town.city_tax} per adult / per nit (les 7 primeres nits)",
          "ES": "Tasa turística #{town.city_tax} por adulto / por noche (las 7 primeras noches)",
          "FR": "Taxe de séjour #{town.city_tax} par adulte / par nuit (les 7 premières nuits)"
        }
      }
    end
  end

  def baby_cot_json
    estartit_office = Office.where("name ILIKE ?", "%estartit%").first
    if office && office == estartit_office
      {
        "type": "1",
        "price": "15.0000",
        "unit": "0",
        "period": "0",
        "vat": "21.00",
        "image": "0",
        "description": {
        "EN": "Baby cot and high-chair",
        "CA": "Cuna i trona",
        "ES": "Cuna y trona",
        "FR": "Lit bébé et chaise haute"
        }
      }
    else
      {
        "type": "1",
        "price": "0.0000",
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
      }
    end
  end

  def portable_wifi_json
    if features && features.any? { |feature| feature.name == "wifi" }
      {
        "type": "",
        "price": "",
        "unit": "",
        "period": "",
        "vat": "",
        "image": "",
        "description": {
          "EN": "",
          "CA": "",
          "ES": "",
          "FR": ""
        }
      }
    else
      {
        "type": "1",
        "price": "35.0000",
        "unit": "4",
        "period": "0",
        "vat": "21.00",
        "image": "0",
        "description": {
          "EN": "Portable Wifi",
          "CA": "Wifi portàtil",
          "ES": "Wifi portátil",
          "FR": "Wifi portable"
        }
      }
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

  def beds_detail_full_words
    all_beds = bedrooms.flat_map { |bedroom| bedroom.beds.pluck(:bed_type) }

    all_beds = all_beds.map { |bed_type| bed_type == "BED_BUNK" ? ["BED_SINGLE", "BED_SINGLE"] : bed_type }.flatten.tally

    name_mapping = {
      "BED_DOUBLE" => "DOUBLE",
      "BED_SOFA" => "DOUBLE_SOFA"
    }
    details = []
    all_beds.each do |bed_type, count|
      bed_type = name_mapping[bed_type] || "SINGLE"

      details << "#{count} #{I18n.t(bed_type, count: count)}"
    end

    details
  end

  def beds_room_type
    details = beds_details.join(", ")
    {
      name: "#{I18n.t(property_type, locale: office&.company&.language || 'ca')} #{name} #{details if details.present?}".strip,
      qty: 1,
      minStay: min_stay,
      maxPeople: max_guests,
      minPrice: min_price,
      cleaningFee: cleaning_fee
    }
  end

  def top_review
    if reviews.present?
      reviews.order(rating: :desc, created_at: :desc).first
    end
  end

  def reviews_median
    reviews = self.reviews.where.not(rating: nil)
    return if reviews.empty?
    rating_array = reviews.pluck(:rating)
    median(rating_array)
  end

  def median(array)
    return nil if array.empty?
    sorted = array.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def full_description(locale=nil)
    locale = locale || I18n.locale.to_s
    short_desc = send("short_description_#{locale}")
    long_desc = send("description_#{locale}")
    if short_desc.present? && long_desc.present?
      "<p>#{send("short_description_#{locale}")}</p><p>#{send("description_#{locale}")}</p>"
    elsif short_desc.present?
      "<p>#{send("short_description_#{locale}")}</p>"
    elsif long_desc.present?
      "<p>#{send("description_#{locale}")}</p>"
    else
      ""
    end
  end

  def overbookings
    confirmed_bookings = self.bookings.where.not(status: "0").order(checkin: :asc)
    overbookings = []

    confirmed_bookings.each do |booking|
      this_booking_overbookings = booking.overlapping_bookings
      overbookings.concat(this_booking_overbookings) if this_booking_overbookings.present?
    end
    overbookings
  end

  def get_reviews_from_airbnb
    ["ca", "es", "en", "fr"].each do |site|

      browser = Ferrum::Browser.new
      if site == "en"
        url = "https://www.airbnb.com/rooms/#{airbnb_listing_id}/reviews"
      elsif site == "ca"
        url = "https://www.airbnb.cat/rooms/#{airbnb_listing_id}/reviews"
      else
        url = "https://www.airbnb.#{site}/rooms/#{airbnb_listing_id}/reviews"
      end
      browser.go_to(url)
      sleep 30
      browser.network.wait_for_idle(timeout: 30)

      # reviews_modal = browser.at_css('div._1ymlq18')
      reviews_modal = browser.at_xpath("//div[contains(@class, '_1ymlq18')]")
      if reviews_modal
        modal_html = reviews_modal.property('outerHTML')
      else
        puts "Review modal not found"
      end
      browser.quit

      nokogiri_doc = Nokogiri::HTML(modal_html)

      review_elements = nokogiri_doc.css('[data-review-id]')

      reviews_array = []

      review_location = "client_location_#{site}".to_sym
      review_comment = "comment_#{site}".to_sym

      if site == "ca"
        review_elements.each do |review_element|
          review_data = {}
          review_data[:review_id] = review_element['data-review-id']
          review_data[:client_name] = review_element.at_css('.atm_7l_1kw7nm4').text.strip if review_element.at_css('.atm_7l_1kw7nm4')
          review_data[review_location] = review_element.at_css('.s9v16xq').text.strip if review_element.at_css('.s9v16xq')
          review_data[:rating] = review_element.at_css('.c5dn5hn').text.strip if review_element.at_css('.c5dn5hn')
          review_data[review_comment] = review_element.at_css('.r1bctolv').text.strip if review_element.at_css('.r1bctolv')

          reviews_array << review_data
        end
      else
        review_elements.each do |review_element|
          review_data = {}
          review_data[:review_id] = review_element['data-review-id']
          review_data[review_location] = review_element.at_css('.s9v16xq').text.strip if review_element.at_css('.s9v16xq')
          review_data[review_comment] = review_element.at_css('.r1bctolv').text.strip if review_element.at_css('.r1bctolv')

          reviews_array << review_data
        end
      end

      reviews_array.each do |airbnb_review|
        if site == "ca"
          rate_match = airbnb_review[:rating].match(/\d+/)
          rate_integer = rate_match ? rate_match[0].to_i : nil

          if rate_integer.present? && rate_integer >= 3
            review = Review.find_or_create_by(review_id: airbnb_review[:review_id])
            review.update(
              client_name: airbnb_review[:client_name],
              source: "airbnb",
              "client_location_#{site}": airbnb_review[review_location],
              rating: rate_integer,
              "comment_#{site}": airbnb_review[review_comment],
              vrental_id: self.id
            )
          end
        else
          review = Review.find_or_create_by(review_id: airbnb_review[:review_id])
          review.update(
            "client_location_#{site}": airbnb_review[review_location],
            "comment_#{site}": airbnb_review[review_comment],
          )
        end
      end
      puts "Got reviews from #{url} for #{name} with id #{id}"
      sleep 3
    end
  end

  def vrentals_same_vrgroups
    vrgroups.flat_map(&:vrentals).uniq
  end

  def same_vrgroup_masters
    vrentals_same_vrgroups.select { |vrental| vrental.rate_master_id.nil? }
  end

  def vrentals_same_vrgroups_images
    Vrental.joins(:image_urls).where(id: vrentals_same_vrgroups.pluck(:id)).distinct
  end

  def available_from
    return nil if availabilities.blank?

    available_dates = availabilities.where("inventory > 0").where("date > ?", Date.today)

    return nil if available_dates.blank?

    first_available_date = available_dates.order(:date).first.date
    current_date = first_available_date
    current_date_min_stay = rate_min_stay(current_date)
    min_stay_end = current_date + current_date_min_stay.days

    while current_date < min_stay_end
      its_available = availabilities.find_by(date: current_date)

      if its_available.present?
        current_date += 1.day
      else
        first_available_date = availabilities.where("date > ?", current_date).order(:date).first&.date
        return nil if first_available_date.nil?

        current_date = first_available_date
        current_date_min_stay = rate_min_stay(current_date)
        min_stay_end = current_date + current_date_min_stay.days
      end
    end

    first_available_date
  end

  def default_checkin
    available_for_checkin.first if available_for_checkin.present?
  end

  def default_checkout
    return unless default_checkin.present?
    rate_min = rate_min_stay(default_checkin)
    if rate_min
      self.default_checkin + rate_min.days
    else
      self.default_checkin + 1.day
    end
  end

  def create_image_urls(target_photos=nil)
    existing_urls = image_urls.pluck(:url).to_set

    photos_to_process = target_photos.nil? ? photos : target_photos

    photos_to_process.each_with_index do |photo, index|
      url = photo.url
      url_with_q_auto = url.gsub(/upload\//, 'upload/q_auto/')

      unless existing_urls.include?(url_with_q_auto)
        image_urls.create(url: url_with_q_auto, position: index + 1, photo_id: photo.id)
        existing_urls.add(url_with_q_auto)  # Add the new URL to the set
      end
    end
  end

  def create_image_urls(target_photos=nil)
    existing_urls = image_urls.pluck(:url).to_set

    photos_to_process = target_photos.nil? ? photos : target_photos

    photos_to_process.each_with_index do |photo, index|
      url = photo.url
      url_with_q_auto = url.gsub(/upload\//, 'upload/q_auto/')

      unless existing_urls.include?(url_with_q_auto)
        image_urls.create(url: url_with_q_auto, position: index + 1, photo_id: photo.id)
        existing_urls.add(url_with_q_auto)  # Add the new URL to the set
      end
    end
  rescue => e
    # Handle any errors that occur during the process
    Rails.logger.error("Error creating image URLs: #{e.message}")
  end

  def cleaned_more_than_5_days_ago?(date)
    past_cleaning_schedules = cleaning_schedules.where("cleaning_date < ?", date)

    if past_cleaning_schedules.any?
      latest_cleaning_schedule = past_cleaning_schedules.order(:cleaning_date).last
      return latest_cleaning_schedule.cleaning_date < date - 5.days
    elsif bookings.where("checkout = ?", date).any?
      return false
    elsif owner_bookings.where("checkout = ?", date).any?
      return false
    else
      return true  # No past cleaning schedules, so return true (assuming it needs cleaning)
    end
  end

  def this_year_confirmed_guest_bookings
    bookings.where.not(status: "0").where("checkin >= ?", Date.today.beginning_of_year)
  end

  def this_year_confirmed_owner_bookings
    owner_bookings.where.not(status: "0").where("checkin >= ?", Date.today.beginning_of_year)
  end

  def previous_booking(date)
    previous_guest_booking = this_year_confirmed_guest_bookings.where("checkout <= ?", date)&.order(checkout: :desc).first
    previous_owner_booking = this_year_confirmed_owner_bookings.where("checkout <= ?", date)&.order(checkout: :desc).first
    return [previous_guest_booking, previous_owner_booking].compact.max_by(&:checkout)
  end

  def next_booking(date)
    next_guest_booking = this_year_confirmed_guest_bookings.where("checkin >= ?", date).order(checkin: :asc).first
    next_owner_booking = this_year_confirmed_owner_bookings.where("checkin >= ?", date).order(checkin: :asc).first
    return [next_guest_booking, next_owner_booking].compact.min_by(&:checkin)
  end

  def last_cleaning(checkin_date)
    previous_booking = previous_booking(checkin_date)
    if previous_booking.present?
      cleaning_schedules.where("cleaning_date <= ? AND cleaning_date >= ?", checkin_date, previous_booking.checkout).order(cleaning_date: :desc).first
    else
      cleaning_schedules.where("cleaning_date <= ?", checkin_date).order(cleaning_date: :desc).first
    end
  end

  def needs_cleaning(checkin_date)
    last_cleaning_schedule = last_cleaning(checkin_date)
    last_cleaning_schedule.nil? || (last_cleaning_schedule.present? && last_cleaning_schedule.cleaning_type.in?(["checkout_laundry_pickup", "checkout_no_laundry"]))
  end

  def cleanings_overlap_booking
    overlap_cleanings = []

    this_year_confirmed_guest_bookings.each do |booking|
      overlapping_cleanings = cleaning_schedules.where("cleaning_date > ? AND cleaning_date < ?", booking.checkin, booking.checkout)
      overlapping_cleanings.each do |cleaning|
        overlap_cleanings << { booking: booking, cleaning: cleaning }
      end
    end

    this_year_confirmed_owner_bookings.each do |booking|
      overlapping_cleanings = cleaning_schedules.where("cleaning_date > ? AND cleaning_date < ?", booking.checkin, booking.checkout)
      overlapping_cleanings.each do |cleaning|
        overlap_cleanings << { booking: booking, cleaning: cleaning }
      end
    end
    overlap_cleanings
  end

  private

  def update_slug
    self.slug = name.downcase.gsub(/\s+/, '-')
  end

  def update_price_per
    if control_restrictions == "rates"
      self.price_per = "night"
      self.rates.each do |rate|
        rate.priceweek = nil
        rate.save!
      end
    end
  end

  def cannot_reference_self_as_rate_master
    if id == rate_master_id
      errors.add(:rate_master_id, "cannot reference itself")
    end
  end
end

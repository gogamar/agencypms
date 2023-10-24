class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :list_map, :book_property, :confirm_booking, :get_availability]
  layout 'booking_website'
  include ActionView::Helpers::NumberHelper

  def dashboard
    @vragreements = policy_scope(Vragreement)
    @owners = policy_scope(Owner)
    @task = Task.new
    @tasks = Task.where(start_date: Time.now.beginning_of_month.beginning_of_week..Time.now.end_of_month.end_of_week).order(start_date: :asc)
  end

  def home
    @towns = Town.all
    @property_types = Vrental::PROPERTY_TYPES.values

    @highest_bedroom_count = Vrental.joins(:bedrooms)
                                    .group('vrentals.id')
                                    .order('COUNT(bedrooms.id) DESC')
                                    .limit(1)
                                    .count('bedrooms.id')
                                    .values.first
    @highest_bathroom_count = Vrental.joins(:bathrooms)
                                      .group('vrentals.id')
                                      .order('COUNT(bathrooms.id) DESC')
                                      .limit(1)
                                      .count('bathrooms.id')
                                      .values.first
    @features = Feature.all.uniq
    # @towns_with_photo = Town.joins(:photos_attachments).distinct
    @featured_towns = Town.joins(:vrentals).select('towns.*, COUNT(vrentals.id) AS vrentals_count').group('towns.id').order('vrentals_count DESC').distinct.limit(4)

    @properties_in_town = Vrental.joins(:town).group('towns.id').count


    # FIXME: make these featured rentals
    vrentals_with_future_rates = Vrental.with_future_rates
    vrentals_cl_good = vrentals_with_future_rates
                          .joins("INNER JOIN image_urls ON image_urls.vrental_id = vrentals.id")
                          .where("image_urls.url LIKE ? AND image_urls.position = (SELECT MIN(position) FROM image_urls WHERE image_urls.vrental_id = vrentals.id)", "%q_auto:good%")
                          .select("vrentals.id")
                          .distinct

    @featured_vrentals = Vrental.where(id: vrentals_cl_good)
                                .select do |vrental|
                                  first_future_rate_date = vrental.rates.where("lastnight > ?", Date.today).minimum(:firstnight)
                                  if first_future_rate_date.present?
                                    available_dates = vrental.future_available_dates(first_future_rate_date, first_future_rate_date + 30.days)
                                    available_dates.any?
                                  else
                                    false
                                  end
                                end
    if @featured_vrentals.count >= 6
      @featured_vrentals = @featured_vrentals.first(6)
    else
      @featured_vrentals = @featured_vrentals.first(3)
    end

  end

  def list_map
    fetch_vrentals
    @checkin = params[:check_in]
    @checkout = params[:check_out]
    @guests = params[:guests]
    prop_ids = @vrentals.pluck(:beds_prop_id)
    # fixme - need to get the company from url (subdomain)
    @company = Company.first
    @available_vrentals = []
    @company.offices.each do |office|
      owner_id = office.beds_owner_id
      availability_data = get_availability_from_beds(owner_id, @checkin, @checkout, @guests, prop_ids)
      @available_vrentals.concat(availability_data)
    end
    vrental_ids = @available_vrentals.map { |item| item.keys.first.to_i }
    @vrentals = @vrentals.where(id: vrental_ids)
    @vrentals_number = @vrentals.count
    @vrentals = Vrental.joins(:features).where(features: { name: 'pool' }) if params[:pool].present?
    @vrentals = Vrental.joins(:rates).where('rates.priceweek <= ?', 350).distinct if params[:economy].present?
    @pagy, @vrentals = pagy(@vrentals, page: params[:page], items: 10)
    puts "these are the available_vrentals: #{@available_vrentals}"
    @markers = @available_vrentals.map do |property|
      vrental = Vrental.find_by(id: property.keys.first)
      price = property.values.first
      if vrental&.geocoded?
        generate_marker(vrental, price)
      else
        nil
      end
    end.compact

    params_hash = params.to_unsafe_h
    @type_bedrooms_bathrooms = params_hash.slice(:type, :bedrooms, :bathrooms).select { |k, v| v.present? }
    @selected_features = params_hash[:selected_features]
  end

  def get_availability
    @vrental = Vrental.find(params[:vrentalId])
    checkin = params[:checkIn]
    checkout = params[:checkOut]
    guests = params[:numAdult]
    response = @vrental.get_availability_from_beds(checkin, checkout, guests)
    render json: response
  end

  def book_property
    @vrental = Vrental.find(params[:vrental_id])
    @checkin = params[:checkin] || (Date.today + 14.days).strftime("%Y-%m-%d")
    @checkout = params[:checkout] || (Date.today + 21.days).strftime("%Y-%m-%d")
    @guests = params[:guests] || 1
    response = @vrental.get_availability_from_beds(@checkin, @checkout, @guests)
    @price = response["updatedPrice"]
    @rate_price = response["updatedPrice"]
    @not_available = response["notAvailable"]
    @discount = params[:discount]
    @markers = []
    @markers << generate_marker(@vrental)
  end

  def confirm_booking
    @vrental = Vrental.find(params[:vrental_id])
    @checkin = params[:check_in].to_date
    @checkout = params[:check_out].to_date
    @nights = @checkout - @checkin
    @guests = params[:guests]
  end

  def submit_property
  end

  private

  def generate_marker(vrental, price=nil)
    {
      lat: vrental.latitude,
      lng: vrental.longitude,
      info_window: render_to_string(partial: "info_window", locals: { vrental: vrental }),
      # move this pin to the assets folder or cloudinary used for this project
      image_url: helpers.asset_url("https://res.cloudinary.com/dlzusxobf/image/upload/v1674377649/location_khgiyz.png"),
      # image_url: vrental.image_urls.first.url,
      price: price.present? ? number_to_currency(price, unit: "€", separator: ",", delimiter: ".", precision: 2) : nil,
      name: vrental.name
    }
  end

  def fetch_vrentals
    guest_count = params[:guests].to_i
    selected_type = params[:type]
    selected_location = params[:location]
    selected_bedrooms_count = params[:bedrooms].to_i
    selected_bathrooms_count = params[:bathrooms].to_i
    selected_features = params[:selected_features]

    @vrentals = Vrental.joins(:bedrooms, :bathrooms, :features)

    @vrentals = @vrentals.where(property_type: selected_type) unless selected_type.blank?
    @vrentals = @vrentals.where(town: selected_location) unless selected_location.blank?
    @vrentals = @vrentals.where("vrentals.max_guests >= ?", guest_count) if guest_count.present?
    @vrentals = @vrentals.where(features: { id: selected_features }) if selected_features.present?

    # Add the bedrooms and bathrooms counts only if their respective values are provided
    if selected_bedrooms_count > 0
      @vrentals = @vrentals.joins(:bedrooms).group('vrentals.id').having('COUNT(DISTINCT bedrooms.id) = ?', selected_bedrooms_count)
    end

    if selected_bathrooms_count > 0
      @vrentals = @vrentals.joins(:bathrooms).group('vrentals.id').having('COUNT(DISTINCT bathrooms.id) = ?', selected_bathrooms_count)
    end

    # If both bedroom and bathroom counts are provided, make sure features count condition is added
    if selected_features.present? && (selected_bedrooms_count > 0 || selected_bathrooms_count > 0)
      @vrentals = @vrentals.having('COUNT(DISTINCT features.id) = ?', selected_features.length)
    elsif selected_features.present?
      @vrentals = @vrentals.group('vrentals.id').having('COUNT(DISTINCT features.id) = ?', selected_features.length)
    end
    @vrentals = @vrentals.distinct
  end

end

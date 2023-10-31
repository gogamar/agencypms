class PagesController < ApplicationController
  before_action :filter_params
  skip_before_action :authenticate_user!, only: [:home, :list_map, :list, :book_property, :confirm_booking, :get_availability]
  layout 'booking_website'
  include ActionView::Helpers::NumberHelper

  def dashboard
    @vragreements = policy_scope(Vragreement)
    @owners = policy_scope(Owner)
    @task = Task.new
    @tasks = Task.where(start_date: Time.now.beginning_of_month.beginning_of_week..Time.now.end_of_month.end_of_week).order(start_date: :asc)
  end

  def home
    @locations = Town.pluck(:name).sort
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

  def list
    simple_search
    @checkin = params[:check_in]
    @checkout = params[:check_out]
    @guests = params[:guests]
    prop_ids = @vrentals.pluck(:beds_prop_id)
    # fixme - company from url (subdomain)
    @company = Company.first
    @available_vrentals = @company.available_vrentals(@checkin, @checkout, @guests, prop_ids)
    @available_vrentals_with_price = @available_vrentals.select { |item| item.values.first.present? }
    @vrentals = @vrentals.where(id: @available_vrentals_with_price.map { |item| item.keys.first.to_i }) if @available_vrentals_with_price.present?

    @property_types = Vrental::PROPERTY_TYPES.values
    @selected_property_types = params[:pt]
    property_bedrooms = Vrental.all.map { |vrental| vrental.bedrooms.count }.uniq.sort
    @property_bedrooms = property_bedrooms.map { |num| [num, 'bedroom', 'or_more'] }
    @selected_property_bedrooms = params[:pb]
    @property_features = Feature.where(highlight: true).map { |feature| feature.name }
    @selected_property_features = params[:pf]
    @all_vrentals_number = Vrental.all.count
    @dates_selected = params[:check_in].present? && params[:check_out].present?
    @guests_selected = params[:guests].present?

    if params[:pt] || params[:pb] || params[:pf]
      advanced_search(params[:pt], params[:pb], params[:pf])
    end

    @pagy, @vrentals = pagy(@vrentals, page: params[:page], items: 10)
  end

  def list_map
    # simple_search
    # @checkin = params[:check_in]
    # @checkout = params[:check_out]
    # @guests = params[:guests]
    # prop_ids = @vrentals.pluck(:beds_prop_id)
    # # fixme - need to get the company from url (subdomain)
    # @company = Company.first
    # vrental_ids = @vrentals.map { |item| item.keys.first.to_i }
    # @vrentals = @vrentals.where(id: vrental_ids)
    # @vrentals_number = @vrentals.count
    # @vrentals = Vrental.joins(:features).where(features: { name: 'pool' }) if params[:pool].present?
    # @vrentals = Vrental.joins(:rates).where('rates.priceweek <= ?', 350).distinct if params[:economy].present?
    @vrentals = Vrental.all
    @available_vrentals_with_price = params[:avp]
    @vrentals = @vrentals.where(id: @available_vrentals_with_price.map { |item| item.keys.first.to_i }) if @available_vrentals_with_price.present?
    @pagy, @vrentals = pagy(@vrentals, page: params[:page], items: 10)

    if @available_vrentals_with_price.present?

    @markers = @available_vrentals_with_price.map do |property|
      vrental = Vrental.find_by(id: property.keys.first)
      price = property.values.first
      if vrental&.geocoded?
        generate_marker(vrental, price)
      else
        nil
      end
    end.compact
    else
      @markers = @vrentals.geocoded.map do |vrental|
        generate_marker(vrental)
      end
    end

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

  def filter_params
    params.reject! { |_, value| value.blank? }
  end

  def generate_marker(vrental, price=nil)
    {
      lat: vrental.latitude,
      lng: vrental.longitude,
      info_window: render_to_string(partial: "info_window", locals: { vrental: vrental }),
      # move this pin to the assets folder or cloudinary used for this project
      image_url: helpers.asset_url("https://res.cloudinary.com/dlzusxobf/image/upload/v1674377649/location_khgiyz.png"),
      # image_url: vrental.image_urls.first.url,
      price: price.present? ? number_to_currency(price, unit: "€", separator: ",", delimiter: ".", precision: 2, format: "%n%u") : nil,
      name: vrental.name
    }
  end

  def simple_search
    @vrentals = Vrental.all
    guest_count = params[:guests].to_i
    @vrentals = @vrentals.where("vrentals.max_guests >= ?", guest_count) if guest_count.present?
    selected_location = params[:location]
    @vrentals = @vrentals.joins(:town).where("towns.name ILIKE ?", "%#{selected_location}%") if selected_location.present?
    puts "these are the vrentals after simple search: #{@vrentals.count}"
    return @vrentals
  end

  def advanced_search(pt=nil, pb=nil, pf=nil)
    if pt.present?
      pt_translation_keys = pt.map { |type| I18n.backend.translations[I18n.locale].key type}
      @vrentals.where(property_type: pt_translation_keys)
    end

    if pf.present?
      pf_translation_keys = pf.map { |feature| I18n.backend.translations[I18n.locale].key feature}
      @vrentals = @vrentals.joins(:features).where("features.name ILIKE ANY (array[?])", pf_translation_keys)
    end

    if pb.present?
      @vrentals = @vrentals.joins(:bedrooms)
                         .group('vrentals.id')
                         .having('COUNT(bedrooms.id) >= ?', pb.to_i)
    end
  end
end

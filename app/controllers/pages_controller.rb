class PagesController < ApplicationController
  before_action :filter_params
  before_action :load_vrentals, only: [:list, :filter]
  before_action :load_filters, only: [:home, :list, :filter]
  before_action :load_search_params, only: [:list, :filter]
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
    load_availability
    load_advanced_search
    paginate_vrentals
  end

  def filter
    if params[:request_context].present? && params[:request_context] == 'availability'
      load_availability
    end

    if params[:sort_order]
      sort_order = params[:sort_order]
      avail_props = JSON.parse(params[:avp])
      if sort_order == 'asc'
        @available_vrentals_with_price = avail_props.sort_by! { |hash| hash.values.first }
      elsif sort_order == 'desc'
        @available_vrentals_with_price = avail_props.sort_by! { |hash| -hash.values.first }
      end

      sorted_property_ids = @available_vrentals_with_price.map { |item| item.keys.first.to_i }

      @vrentals = @vrentals.where(id: sorted_property_ids).order(
        Arel.sql("CASE id #{sorted_property_ids.map.with_index { |id, index| "WHEN #{id} THEN #{index}" }.join(' ')} END")
      )
      @checkin = params[:check_in]
      @checkout = params[:check_out]
      @guests = params[:guests]
    end

    load_advanced_search
    paginate_vrentals

    render(partial: 'properties')
  end

  def list_map
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
    @guests = params[:num_adults]
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

  def load_vrentals
    @vrentals = Vrental.all
  end

  def load_search_params
    @guests = params[:guests]
    @location = params[:location]
    simple_search(@vrentals, @guests, @location) if @guests.present? || @location.present?
    @checkin = params[:check_in]
    @checkout = params[:check_out]
  end

  def load_availability
    return unless @checkin.present? && @checkout.present?
    prop_ids = @vrentals.pluck(:beds_prop_id)
    check_availability_on_api(params[:check_in], params[:check_out], params[:guests], prop_ids)

    if @available_vrentals_with_price.present?
      property_ids = @available_vrentals_with_price.map { |item| item.keys.first.to_i }
      @vrentals = @vrentals.where(id: property_ids)
    end
  end

  def check_availability_on_api(checkin, checkout, guests, prop_ids)
    # fixme - company from url (subdomain)
    @company = Company.first
    @available_vrentals = @company.available_vrentals(checkin, checkout, guests, prop_ids)
    @available_vrentals_with_price = @available_vrentals.select { |item| item.values.first.present? }
  end

  def load_advanced_search
    advanced_search(params[:pt], params[:pb], params[:pf], params[:n]) if params[:pt] || params[:pb] || params[:pf] || params[:n]
  end

  def paginate_vrentals
    @all_vrentals_number = Vrental.all.count
    @pagy, @vrentals = pagy(@vrentals, page: params[:page], items: 10)
  end

  def simple_search(vrentals, guests, location)
    @vrentals = vrentals.where("vrentals.max_guests >= ?", guests.to_i) if guests.present?
    @vrentals = vrentals.joins(:town).where("towns.name ILIKE ?", "%#{location}%") if location.present?
  end

  def advanced_search(pt, pb, pf, n)
    @vrentals = @vrentals.where("name ILIKE ?", "%#{params[:n]}%") if params[:n].present?
    @vrentals = @vrentals.where(property_type: pt_translation_keys(pt)) if pt.present?
    @vrentals = @vrentals.joins(:features).where("features.name ILIKE ANY (array[?])", feature_translation_keys(pf)) if pf.present?
    @vrentals = @vrentals.joins(:bedrooms).group('vrentals.id').having('COUNT(bedrooms.id) >= ?', pb.to_i) if pb.present?
  end

  def pt_translation_keys(pt)
    pt.map { |type| I18n.backend.translations[I18n.locale].key(type) }
  end

  def feature_translation_keys(pf)
    pf.map { |feature| I18n.backend.translations[I18n.locale].key(feature) }
  end

  def load_filters
    @locations = Town.pluck(:name).sort
    @property_types = Vrental::PROPERTY_TYPES.values
    @property_features = Feature.where(highlight: true).map { |feature| feature.name }
    max_bedsrooms = Vrental.left_joins(:bedrooms)
       .group('vrentals.id')
       .order('COUNT(bedrooms.id) DESC')
       .limit(1)
       .count('bedrooms.id')
    property_bedrooms = (2..max_bedsrooms.values.first).to_a
    @property_bedrooms = property_bedrooms.map { |num| [num, 'bedroom', 'or_more'] }
  end
end

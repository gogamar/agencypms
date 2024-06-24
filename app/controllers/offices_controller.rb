class OfficesController < ApplicationController
  before_action :set_office, only: %i[ show edit update destroy import_properties import_bookings destroy_all_properties get_reviews_from_airbnb organize_cleaning cleaning_checkout cleaning_checkin]
  before_action :set_company, except: %i[ destroy import_properties import_bookings destroy_all_properties get_reviews_from_airbnb]

  def index
    @offices = policy_scope(Office)
  end

  def show
  end

  def new
    @office = Office.new
    authorize @office
  end

  def edit
  end

  def create
    @office = Office.new(office_params)
    authorize @office
    @office.company = @company

    if @office.save
      redirect_to root_path, notice: "Oficina creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @office.update(office_params)
      redirect_to root_path, notice: "Oficina actualitzada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @office.destroy

    redirect_to offices_url, notice: "Oficina esborrada."
  end

  def destroy_all_properties
    @office.vrentals.destroy_all
  end

  def import_properties
    no_import = params[:no_import] if params[:no_import].present?
    import_name = params[:import_name] if params[:import_name].present?
    VrentalApiService.new(@office).import_properties_from_beds(no_import, import_name)
    redirect_to vrentals_path, notice: "Immobles importats de Beds24."
  end

  def import_bookings
    job = JobRecord.create(status: "pending")
    if job.persisted?
      begin
        GetAllBookingsJob.perform_later(@office, job.id)
        render json: { job_id_url: job_status_path(job_id: job.id) }
      rescue => e
        job.update(status: "failed")
        puts "Error importing bookings: #{e.message}"
        render json: { error: e.message }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Failed to create job record' }, status: :unprocessable_entity
    end
  end

  def organize_cleaning
    @start_date = Date.today
    @end_date = Date.today + 14.days
  end

  def cleaning_checkout
    @start_date = Date.today
    @end_date = Date.today + 14.days
    checkout_bookings = @office.checkout_bookings(@office.bookings, @start_date, @end_date)
    checkout_owner_bookings = @office.checkout_bookings(@office.owner_bookings, @start_date, @end_date)

    @checkout_all = (checkout_bookings + checkout_owner_bookings).sort_by { |booking| [booking[:checkout]] }
    @pagy, @checkout_all = pagy_array(@checkout_all, page: params[:page], items: 5)
  end

  def cleaning_checkin
    @start_date = Date.today
    @end_date = Date.today + 14.days
    checkin_bookings = @office.checkin_bookings(@office.bookings, @start_date, @end_date)
    checkin_owner_bookings = @office.checkin_bookings(@office.owner_bookings, @start_date, @end_date)

    # Filter bookings based on vrental's previous cleanings conditions
    no_previous_cleaning = checkin_bookings.select do |booking|
      previous_cleanings = booking.vrental.previous_cleanings(booking.checkin)
      previous_cleanings.none? || previous_cleanings.last.cleaning_type.in?(["checkout_laundry_pickup", "checkout_no_laundry"])
    end

    no_previous_cleaning_owner = checkin_owner_bookings.select do |booking|
      previous_cleanings = booking.vrental.previous_cleanings(booking.checkin)
      previous_cleanings.none? || previous_cleanings.last.cleaning_type.in?(["checkout_laundry_pickup", "checkout_no_laundry"])
    end

    @checkin_all = (no_previous_cleaning + no_previous_cleaning_owner).sort_by { |booking| [booking[:checkin]] }

    @pagy, @checkin_all = pagy_array(@checkin_all, page: params[:page], items: 5)
  end

  def get_reviews_from_airbnb
    @office.vrentals.each do |vrental|
      if vrental.prop_key.present? && vrental.airbnb_listing_id.present?
        vrental.get_reviews_from_airbnb
        puts "Updated reviews for #{vrental.id} - #{vrental.name}"
      end
      sleep 5
    end
    redirect_to vrentals_path, notice: "Comentaris importats de Airbnb."
  end

  private

  def set_office
    @office = Office.find(params[:id])
    authorize @office
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def office_params
    params.require(:office).permit(:name, :street, :city, :post_code, :region, :country, :phone, :mobile, :email, :website, :opening_hours, :manager, :company_id, :local_realtor_number, :beds_owner_id, :beds_key, office_photos: [])
  end
end

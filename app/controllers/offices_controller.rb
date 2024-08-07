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
    @end_date = 14.days.from_now
    @no_previous_cleaning = (@office.no_previous_cleaning(@office.bookings, @start_date, @end_date) + @office.no_previous_cleaning(@office.owner_bookings, @start_date, @end_date)).sort_by(&:checkin)

    @cleaned_6_days_ago = (@office.cleaned_6_days_ago(@office.bookings, @start_date, @end_date) + @office.cleaned_6_days_ago(@office.owner_bookings, @start_date, @end_date)).sort_by(&:checkin)

    @previous_cleaning_incomplete = (@office.previous_cleaning_incomplete(@office.bookings, @start_date, @end_date) + @office.previous_cleaning_incomplete(@office.owner_bookings, @start_date, @end_date)).sort_by(&:checkin)
  end

  def cleaning_checkout
    @start_date = Date.today
    @end_date = Date.today + 14.days
    @vrentals = @office.vrentals.order(:name)
    from = params[:from]
    to = params[:to]
    rental = @office.vrentals.find_by(id: params[:vrental_id]) if params[:vrental_id].present?

    checkout_bookings = @office.checkout_bookings(@office.bookings, @start_date, @end_date, rental, from, to)

    checkout_owner_bookings = @office.checkout_bookings(@office.owner_bookings, @start_date, @end_date, rental, from, to)

    @checkout_all = (checkout_bookings + checkout_owner_bookings).sort_by { |booking| [booking[:checkout]] }

    @pagy, @checkout_all = pagy_array(@checkout_all, page: params[:page], items: 5)
  end

  def cleaning_checkin
    @start_date = Date.today
    @end_date = Date.today + 14.days
    @vrentals = @office.vrentals.order(:name)
    from = params[:from]
    to = params[:to]
    rental = @office.vrentals.find_by(id: params[:vrental_id]) if params[:vrental_id].present?
    checkin_bookings = @office.checkin_bookings(@office.bookings, @start_date, @end_date, rental, from, to)
    checkin_owner_bookings = @office.checkin_bookings(@office.owner_bookings, @start_date, @end_date, rental, from, to)

    @checkin_all = (checkin_bookings + checkin_owner_bookings).sort_by { |booking| [booking[:checkin]] }

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

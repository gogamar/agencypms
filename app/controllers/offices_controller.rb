class OfficesController < ApplicationController
  before_action :set_office, only: %i[ show edit update destroy import_properties destroy_all_properties get_reviews_from_airbnb]
  before_action :set_company, except: %i[ destroy import_properties destroy_all_properties get_reviews_from_airbnb import_bookings]

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
    office = Office.find(params[:office_id])
    authorize office
    to_date = params[:to]
    puts "Importing bookings from Beds24 for #{office.name} to #{to_date}"

    office.vrentals.each do |vrental|
      if vrental.prop_key.present?
        VrentalApiService.new(vrental).get_bookings_from_beds(nil, to_date)
      end
    end
    redirect_to cleaning_schedules_path, notice: "Reserves actualitzades."
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

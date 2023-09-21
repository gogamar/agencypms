class OfficesController < ApplicationController
  before_action :set_office, only: %i[ show edit update destroy ]
  before_action :set_company

  def index
    @offices = policy_scope(Office)
  end

  def show
    authorize @office
  end

  def new
    @office = Office.new
    authorize @office
  end

  def edit
    authorize @office
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
    authorize @office

    if @office.update(office_params)
      redirect_to root_path, notice: "Oficina actualitzada."
    else
      puts "OFFICE ERRORS: #{@office.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @office
    @office.destroy

    redirect_to offices_url, notice: "Oficina esborrada."
  end

  private
    def set_office
      @office = Office.find(params[:id])
    end

    def set_company
      @company = Company.find(params[:company_id])
    end

    def office_params
      params.require(:office).permit(:name, :street, :city, :post_code, :region, :country, :phone, :mobile, :email, :website, :opening_hours, :manager, :company_id)
    end
end

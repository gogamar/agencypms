class AvailabilitiesController < ApplicationController
  before_action :set_vrental, only: [ :new, :create, :edit, :update ]
  before_action :set_availability, only: [:edit, :update, :destroy]

  def index
    @vrental = Vrental.find(params[:vrental_id])
    @availabilities = policy_scope(@vrental.availabilities)
    @available_dates = @availabilities.where('inventory > ?', 0)
    @availability = Availability.new
  end

  def new
    @availability = Availability.new
    authorize @availability
  end

  def edit
  end

  def create
    @availability = Availability.new(availability_params)
    authorize @availability
    @availability.vrental = @vrental

    if @availability.save
      redirect_to vrental_availabilities_path, notice: "La regla de disponibilitat s'ha creat correctament."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @availability.update(availability_params)
      redirect_to vrental_availabilities_path(@vrental), notice: "La regla de disponibilitat s'ha modificat correctament."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @availability
    @availability.destroy
    redirect_to vrental_availabilities_path(@vrental), notice: "S'ha esborrat la regla de disponibilitat."
  end

  private

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
    authorize @vrental
  end

  def set_availability
    @availability = Availability.find(params[:id])
    authorize @availability
  end

  def availability_params
    params.require(:availability).permit(:date, :inventory, :multiplier, :override, :vrental_id)
  end
end

class BookingsController < ApplicationController
  before_action :set_vrental
  before_action :set_booking, only: %i[edit update destroy]

  def index
    @bookings = policy_scope(Booking).order(checkin: :asc)
    @bookings = @vrental.bookings.order(checkin: :asc)
    @total_price = @vrental.bookings.pluck(:price)&.sum
    @total_commission = @vrental.bookings.pluck(:commission)&.sum
    @total_cleaning = @vrental.bookings.map do |booking|
      booking.charges.where(charge_type: 'cleaning').sum(:price)
    end.sum
    @total_city_tax = @vrental.bookings.map do |booking|
      booking.charges.where(charge_type: 'city_tax').sum(:price)
    end.sum
    @total_rent = @vrental.bookings.map do |booking|
      booking.charges.where(charge_type: 'rent').sum(:price)
    end.sum
    @total_net = @total_rent - @total_commission
  end

  def new
    @booking = Booking.new
    authorize @booking
  end

  def edit
    authorize @booking
  end

  def create
    @booking = Booking.new(booking_params)
    authorize @booking

    if @booking.save
      redirect_to vrental_bookings_path, notice: "La reserva s'ha creat correctament."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @booking

    if @booking.update(booking_params)
      @booking.locked = true
      @booking.save
      redirect_to vrental_earnings_path, notice: "La reserva s'ha modificat correctament."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @booking
    @booking.destroy
    redirect_to vrental_earnings_path, notice: "Booking was successfully destroyed."
  end

  private
    def set_booking
      @booking = Booking.find(params[:id])
    end

    def set_vrental
      @vrental = Vrental.find(params[:vrental_id])
    end

    def booking_params
      params.require(:booking).permit(:status, :checkin, :checkout, :price, :commission, :referrer, :beds_booking_id, charges_attributes: [:id, :description, :quantity, :price, :charge_type], payment_attributes: [:id, :description, :quantity, :price])
    end
end

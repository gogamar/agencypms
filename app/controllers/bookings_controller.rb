class BookingsController < ApplicationController
  before_action :set_vrental
  before_action :set_booking, only: %i[edit update destroy show_booking]

  def index
    @bookings = policy_scope(@vrental.bookings).order(checkin: :asc)

    if @bookings.present?
      booking_ids = @bookings.pluck(:id)
      charges = Charge.where(booking_id: booking_ids)

      @total_price = @bookings.sum(:price)
      @total_commission = @bookings.sum(:commission)

      @total_cleaning = charges.where(charge_type: 'cleaning').sum(:price)
      @total_city_tax = charges.where(charge_type: 'city_tax').sum(:price)
      @total_rent = charges.where(charge_type: 'rent').sum(:price)

      @total_net = @total_rent - @total_commission
    else
      # Handle case where @vrental has no bookings
      @total_price = 0
      @total_commission = 0
      @total_cleaning = 0
      @total_city_tax = 0
      @total_rent = 0
      @total_net = 0
    end
  end

  def show_booking
    render partial: 'booking_on_calendar'
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
      authorize @booking
    end

    def set_vrental
      @vrental = Vrental.friendly.find(params[:vrental_id])
    end

    def booking_params
      params.require(:booking).permit(:status, :checkin, :checkout, :price, :commission, :referrer, :beds_booking_id, :notes, charges_attributes: [:id, :description, :quantity, :price, :charge_type], payment_attributes: [:id, :description, :quantity, :price])
    end
end

class BookingsController < ApplicationController
  before_action :set_vrental
  before_action :set_booking, only: %i[show edit update destroy]

  def index
    @bookings = policy_scope(Booking)
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

  def show
    authorize @booking
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

    respond_to do |format|
      if @booking.save
        format.html { redirect_to booking_url(@booking), notice: "Booking was successfully created." }
        format.json { render :show, status: :created, location: @booking }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @booking
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to booking_url(@booking), notice: "Booking was successfully updated." }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @booking
    @booking.destroy

    respond_to do |format|
      format.html { redirect_to bookings_url, notice: "Booking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_booking
      @booking = Booking.find(params[:id])
    end

    def set_vrental
      @vrental = Vrental.find(params[:vrental_id])
    end

    def booking_params
      params.require(:booking).permit(:status, :checkin, :checkout, :price, :commission, :referrer, :beds_booking_id)
    end
end

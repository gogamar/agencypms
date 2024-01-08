class OwnerBookingsController < ApplicationController
  before_action :set_vrental
  before_action :set_owner_booking, only: %i[edit update show_form]

  def index
    @owner_bookings = policy_scope(OwnerBooking).includes(:vrental).where(vrental_id: @vrental.id).order(checkin: :asc)
    @availabilities = @vrental.availabilities.to_a.group_by(&:date)
    @pagy, @owner_bookings = pagy(@owner_bookings, page: params[:page], items: 10)
  end

  def new
    @owner_booking = OwnerBooking.new
    authorize @owner_booking
  end

  def edit; end

  def show_form
    render partial: 'calendar_modal'
  end

  def create
    @owner_booking = OwnerBooking.new(owner_booking_params)
    authorize @owner_booking
    @owner_booking.vrental = @vrental
    @owner_booking.status = "1"

    if @owner_booking.valid? && @owner_booking.save
      SendOwnerBookingJob.perform_later(@owner_booking.id)

      redirect_to vrental_owner_bookings_path(@vrental), notice: t('owner_booking_created')
    else
      render :new
    end
  end

  def update
    # fixme check if owner bookings are being correctly cancelled
    if @owner_booking.update(owner_booking_params)
      SendOwnerBookingJob.perform_later(@owner_booking.id)

      redirect_to vrental_owner_bookings_path(@vrental), notice: t('owner_booking_edited')
    else
      render :edit
    end
  end

  private

  def set_owner_booking
    @owner_booking = OwnerBooking.find(params[:id])
    authorize @owner_booking
  end

  def set_vrental
    @vrental = Vrental.find(params[:vrental_id])
  end

  def owner_booking_params
    params.require(:owner_booking).permit(:checkin, :checkout, :note, :vrental_id, :status)
  end
end

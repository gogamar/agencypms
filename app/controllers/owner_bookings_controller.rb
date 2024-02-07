class OwnerBookingsController < ApplicationController
  before_action :set_vrental
  before_action :set_owner_booking, only: %i[edit update show_form]

  def index
    owner_bookings = policy_scope(OwnerBooking).where('checkin > ?', Date.today.beginning_of_year).where.not(status: "0").where(vrental_id: @vrental.id)
    confirmed_bookings = @vrental.bookings.where('checkin > ?', Date.today.beginning_of_year).where.not(status: "0")
    @all_bookings = (owner_bookings + confirmed_bookings).sort_by(&:checkin)
    @availabilities = @vrental.availabilities.to_a.group_by(&:date)
    @latest_owner_booking = owner_bookings.order(updated_at: :desc).first if owner_bookings.any?
    # @pagy, @all_bookings = pagy_array(@all_bookings, page: params[:page], items: 10)
  end

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
      redirect_to vrental_owner_bookings_path(@vrental), notice: @owner_booking.errors.full_messages.join(', ')
    end
  end

  def update
    if @owner_booking.update(owner_booking_params)
      SendOwnerBookingJob.perform_later(@owner_booking.id)

      redirect_to vrental_owner_bookings_path(@vrental), notice: t('owner_booking_edited')
    else
      redirect_to vrental_owner_bookings_path(@vrental), notice: @owner_booking.errors.full_messages.join(', ')
    end
  end

  private

  def set_owner_booking
    @owner_booking = OwnerBooking.find(params[:id])
    authorize @owner_booking
  end

  def set_vrental
    @vrental = Vrental.friendly.find(params[:vrental_id])
  end

  def owner_booking_params
    params.require(:owner_booking).permit(:checkin, :checkout, :note, :vrental_id, :status)
  end
end

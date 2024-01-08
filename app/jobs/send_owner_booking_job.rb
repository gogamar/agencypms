class SendOwnerBookingJob < ApplicationJob
  queue_as :default

  def perform(owner_booking_id)
    owner_booking = OwnerBooking.find(owner_booking_id)
    ob_vrental = owner_booking.vrental

    VrentalApiService.new(ob_vrental).send_owner_booking(owner_booking)
    VrentalApiService.new(ob_vrental).get_availabilities_from_beds_24
  end
end

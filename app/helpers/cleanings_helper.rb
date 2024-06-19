module CleaningsHelper

  def booking_or_owner_name(booking)
    booking.is_a?(Booking) ? "#{booking.firstname} #{booking.lastname}" : "#{t('owner')} #{booking.note}"
  end
end

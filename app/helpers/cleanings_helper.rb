module CleaningsHelper

  def booking_or_owner_name(booking)
    booking.is_a?(Booking) ? "#{booking.firstname} #{booking.lastname}" : "#{t('owner')} #{booking.note}"
  end

  def previous_booking_info(booking)
    if booking.is_a?(Booking)
      "#{l(booking.checkout, format: :long_day)} <br> #{booking.firstname} #{booking.lastname}".html_safe
    elsif booking.is_a?(OwnerBooking)
      "#{l(booking.checkout, format: :long_day)} <br> #{booking.note}".html_safe
    end
  end

  def next_booking_info(booking)
    if booking.is_a?(Booking)
      "#{l(booking.checkin, format: :long_day)} <br> #{booking.firstname} #{booking.lastname} <br> #{t('adults')}: #{booking.adults} #{t('children')}: #{booking.children}".html_safe
    elsif booking.is_a?(OwnerBooking)
      "#{l(booking.checkin, format: :long_day)} <br> #{booking.note}".html_safe
    end
  end
end

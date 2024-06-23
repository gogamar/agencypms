module CleaningsHelper

  def booking_or_owner_name(booking)
    booking.is_a?(Booking) ? "#{booking.firstname} #{booking.lastname}" : "#{t('owner')} #{booking.note}"
  end

  def previous_booking_info(previous_booking)
    if previous_booking.is_a?(Booking)
      previous_booking.checkout < Date.today ? "#{previous_booking.firstname} #{previous_booking.lastname} #{t('left_on', date: l(previous_booking.checkout))}".html_safe : "#{previous_booking.firstname} #{previous_booking.lastname} #{t('leaves_on', date: l(previous_booking.checkout))}".html_safe
    elsif previous_booking.is_a?(OwnerBooking)
      previous_booking.checkout < Date.today ? "#{t('owner')} (#{previous_booking.note}) #{t('left_on', date: l(previous_booking.checkout))}".html_safe : "#{t('owner')} (#{previous_booking.note}) #{t('leaves_on', date: l(previous_booking.checkout))}".html_safe
    end
  end

  def booking_info(booking)
    if booking.is_a?(Booking)
      "#{booking.firstname} #{booking.lastname} <br> #{t('adults')}: #{booking.adults} #{t('children')}: #{booking.children}".html_safe
    elsif booking.is_a?(OwnerBooking)
      booking.note
    end
  end
end

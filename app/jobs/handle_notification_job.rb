class HandleNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_data)
    bookid = notification_data[:bookid]
    notification_status = notification_data[:notification_status]
    w_property = notification_data[:w_property]
    w_firstname = notification_data[:w_firstname]
    w_lastname = notification_data[:w_lastname]
    w_checkin = notification_data[:w_checkin]
    w_checkout = notification_data[:w_checkout]
    w_nights = notification_data[:w_nights]
    w_adults = notification_data[:w_adults]
    w_children = notification_data[:w_children]
    w_referrer = notification_data[:w_referrer]
    w_price = notification_data[:w_price]

    vrental = Vrental.find_by(beds_prop_id: w_property)

    case notification_status
    when "new"
      new_booking = Booking.create(
        status: '1',
        firstname: w_firstname,
        lastname: w_lastname,
        checkin: w_checkin,
        checkout: w_checkout,
        nights: w_nights,
        adults: w_adults,
        children: w_children,
        referrer: w_referrer,
        price: w_price,
        beds_booking_id: bookid,
        vrental_id: vrental.id
      )
      # fixme - need to create a tourist also
    when "modify"
      existing_booking = vrental.bookings.find_by(beds_booking_id: bookid)
      existing_booking&.update(
        firstname: w_firstname,
        lastname: w_lastname,
        checkin: w_checkin,
        checkout: w_checkout,
        nights: w_nights,
        adults: w_adults,
        children: w_children,
        referrer: w_referrer,
        price: w_price,
        vrental_id: vrental.id
      )
    when "cancel"
      existing_booking = vrental.bookings.find_by(beds_booking_id: bookid)
      existing_booking&.destroy
    end

    if vrental.vrgroups.present?
      process_vrgroups(vrental)
    else
      VrentalApiService.new(vrental).get_availabilities_from_beds_24
    end
  end

  private

  def process_vrgroups(vrental)
    vrgroup_prevent_gaps = vrental.vrgroups.where.not(gap_days: nil).first
    if vrgroup_prevent_gaps.present?
      VrentalApiService.new(vrental).prevent_gaps_on_beds(vrgroup_prevent_gaps.gap_days)
    end
  end
end

class HandleNotificationJob < ApplicationJob
  queue_as :default

  def perform(params)
    bookid = params[:bookid]
    notification_status = params[:status]
    w_property = params[:property]
    w_firstname = params[:firstname]
    w_lastname = params[:lastname]
    w_checkin = params[:checkin]
    w_checkout = params[:checkout]
    w_nights = params[:nights]
    w_adults = params[:adults]
    w_children = params[:children]
    w_referrer = params[:referrer]
    w_price = params[:price]
    vrental = Vrental.find_by(beds_prop_id: w_property)

    case notification_status
    when "new"
      create_booking_and_update_inventory(vrental, bookid, w_checkin, w_checkout, -1)
    when "modify"
      existing_booking = Booking.find_by(beds_booking_id: bookid)
      if existing_booking
        update_existing_booking(existing_booking, w_firstname, w_lastname, w_checkin, w_checkout, w_nights, w_adults, w_children, w_referrer, w_price, vrental)
        update_inventory(vrental, existing_booking.checkin, existing_booking.checkout, 1)
        update_inventory(vrental, w_checkin, w_checkout, -1)
      end
    when "cancel"
      existing_booking = Booking.find_by(beds_booking_id: bookid)
      cancel_booking(existing_booking, vrental)
    end

    process_vrgroups(vrental)
  end

  private

  def create_booking_and_update_inventory(vrental, bookid, checkin, checkout, inventory_change)
    booking = Booking.create(
      status: '1',
      firstname: w_firstname,
      lastname: w_lastname,
      checkin: checkin,
      checkout: checkout,
      nights: w_nights,
      adults: w_adults,
      children: w_children,
      referrer: w_referrer,
      price: w_price,
      beds_booking_id: bookid,
      vrental_id: vrental.id
    )

    (checkin..checkout).each do |date|
      update_inventory(vrental, date, inventory_change)
    end
  end

  def update_existing_booking(existing_booking, firstname, lastname, checkin, checkout, nights, adults, children, referrer, price, vrental)
    existing_booking.update(
      firstname: firstname,
      lastname: lastname,
      checkin: checkin,
      checkout: checkout,
      nights: nights,
      adults: adults,
      children: children,
      referrer: referrer,
      price: price,
      vrental_id: vrental.id
    )
  end

  def update_inventory(vrental, start_date, end_date, inventory_change)
    (start_date..end_date).each do |date|
      availability = vrental.availabilities.find_or_initialize_by(date: date.to_date)
      availability.inventory += inventory_change
      availability.save
    end
  end

  def cancel_booking(existing_booking, vrental)
    if existing_booking
      existing_booking.update(status: '0')
      update_inventory(vrental, existing_booking.checkin, existing_booking.checkout, 1)
    end
  end

  def process_vrgroups(vrental)
    if vrental.vrgroups.present?
      vrgroup_prevent_gaps = vrental.vrgroups.where.not(gap_days: nil).first
      if vrgroup_prevent_gaps.present?
        VrentalApiService.new(vrental).prevent_gaps_on_beds(vrgroup_prevent_gaps.gap_days)
      end
    end
  end
end

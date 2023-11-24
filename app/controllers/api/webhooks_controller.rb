module Api
  class WebhooksController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :verify_authentication_token

    def handle_notification
      bookid = params[:bookid]
      property = params[:property]
      booking_status = params[:booking_status]
      firstname = params[:firstname]
      lastname = params[:lastname]
      checkin = params[:checkin]
      checkout = params[:checkout]
      nights = params[:nights]
      adults = params[:adults]
      children = params[:children]
      referrer = params[:referrer]
      price = params[:price]

      vrental = Vrental.find_by(beds_prop_id: property)
      existing_booking = Booking.find_by(beds_booking_id: bookid)

      if existing_booking
        existing_booking.update(status: booking_status, firstname: firstname, lastname: lastname, checkin: checkin, checkout: checkout, nights: nights, adults: adults, children: children, referrer: referrer, price: price, commission: commission, vrental_id: vrental.id )
      else
        Booking.create(status: booking_status, firstname: firstname, lastname: lastname, checkin: checkin, checkout: checkout, nights: nights, adults: adults, children: children, referrer: referrer, price: price, commission: commission, beds_booking_id: bookid, vrental_id: vrental.id )
      end

      head :ok
    end

    private

    def verify_authentication_token
      expected_token = ENV['WEBHOOK_TOKEN']
      provided_token = request.headers['X-Webhook-Token']

      unless ActiveSupport::SecurityUtils.secure_compare(expected_token, provided_token)
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end

module Api
  class WebhooksController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :verify_authentication_token

    def handle_notification
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
        Booking.create(
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
      when "modify"
        existing_booking = Booking.find_by(beds_booking_id: bookid)
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
        existing_booking = Booking.find_by(beds_booking_id: bookid)
        existing_booking&.update(status: '0')
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

module Api
  class WebhooksController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :verify_authentication_token

    def handle_notification
      begin
        bookid = params["bookid"]
        booking_status = params["booking_status"]
        property = params["property"]
        firstname = params["firstname"]
        lastname = params["lastname"]
        checkin = params["checkin"].to_date
        checkout = params["checkout"].to_date
        adults = params["adults"]
        children = params["children"]
        referrer = params["referrer"]
        price = params["price"]

        vrental = Vrental.find_by(beds_prop_id: property)

        if booking_status == "Cancelled" || booking_status == "Cancelado" || booking_status == "0"
          existing_booking = vrental.bookings.find_by(beds_booking_id: bookid)
          existing_booking&.destroy
        else
          existing_booking = vrental.bookings.find_by(beds_booking_id: bookid)
          num_nights = (checkout - checkin).to_i

          if existing_booking
            existing_booking.update(
              status: '1',
              firstname: firstname,
              lastname: lastname,
              checkin: checkin,
              checkout: checkout,
              nights: num_nights,
              adults: adults,
              children: children,
              referrer: referrer,
              price: price,
              vrental_id: vrental.id
            )
          else
            vrental.bookings.create(
              beds_booking_id: bookid,
              status: '1',
              firstname: firstname,
              lastname: lastname,
              checkin: checkin,
              checkout: checkout,
              nights: num_nights,
              adults: adults,
              children: children,
              referrer: referrer,
              price: price,
              vrental_id: vrental.id
            )
          end
          # fixme - need to create a tourist also
        end

        if vrental.vrgroups.present?
          process_vrgroups(vrental)
        else
          VrentalApiService.new(vrental).get_availabilities_from_beds_24
        end
        head :ok
      rescue StandardError => e
        Rails.logger.error "Error in handle_notification: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        head :internal_server_error
      end
    end

    private

    def verify_authentication_token
      expected_token = ENV['WEBHOOK_TOKEN']
      provided_token = request.headers['X-Webhook-Token']

      unless ActiveSupport::SecurityUtils.secure_compare(expected_token, provided_token)
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end

    def process_vrgroups(vrental)
      vrgroup_prevent_gaps = vrental.vrgroups.where.not(gap_days: nil).first
      if vrgroup_prevent_gaps.present?
        VrentalApiService.new(vrental).prevent_gaps_on_beds(vrgroup_prevent_gaps.gap_days)
        virtual_vrentals = vrgroup_prevent_gaps.vrentals.where('unit_number > ?', 1)
        virtual_vrentals.each do |virtual_vrental|
          VrentalApiService.new(virtual_vrental).prevent_gaps_on_beds(vrgroup_prevent_gaps.gap_days)
        end
      end
      # fixme: it would be better to have an attribute "virtual" or similar
    end
  end
end

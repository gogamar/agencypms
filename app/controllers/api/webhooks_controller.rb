module Api
  class WebhooksController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :verify_authentication_token

    def handle_notification
      begin
        bookid = params["bookid"]
        booking_status = params["bs"]
        property = params["prop"]
        firstname = params["fn"]
        lastname = params["ln"]
        checkin = params["in"].to_date
        checkout = params["out"].to_date
        adults = params["ad"]
        children = params["ch"]
        price = params["pr"]
        notes = params["nt"]
        referrer = params["ref"]

        vrental = Vrental.find_by(beds_prop_id: property)

        if booking_status == "Cancelled" || booking_status == "Cancelado" || booking_status == "0"
          existing_booking = vrental.bookings.find_by(beds_booking_id: bookid)
          existing_booking&.destroy
          existing_owner_booking = vrental.owner_bookings.find_by(beds_booking_id: bookid)
          existing_owner_booking&.destroy
        else
          existing_booking = vrental.bookings.find_by(beds_booking_id: bookid)
          existing_owner_booking = vrental.owner_bookings.find_by(beds_booking_id: bookid)
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
              notes: notes,
              price: price,
              vrental_id: vrental.id
            )
          elsif existing_owner_booking
            existing_owner_booking.update(
              status: '1',
              checkin: checkin,
              checkout: checkout
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
              notes: notes,
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

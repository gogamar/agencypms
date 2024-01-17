module Api
  class WebhooksController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :verify_authentication_token

    def handle_notification
      notification_data = {
        bookid: params["bookid"],
        w_property: params["property"],
        w_checkin: params["checkin"].to_date,
        w_checkout: params["checkout"].to_date,
        w_firstname: params["firstname"],
        w_lastname: params["lastname"],
        w_guests: params["guests"],
        w_price: params["price"],
        w_status: params["booking_status"]
      }

      HandleNotificationJob.perform_later(notification_data)
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

class UpdateBookingsJob < ApplicationJob
  queue_as :default

  def perform
    connected_vrentals = Vrental.with_valid_prop_key
    from_date = Date.today

    connected_vrentals.each do |vrental|
      begin
        VrentalApiService.new(vrental).get_bookings_from_beds(from_date)
      rescue StandardError => e
        Rails.logger.error "Error processing Vrental #{vrental.id}: #{e.message}"
      ensure
        sleep 3
      end
    end
  end
end

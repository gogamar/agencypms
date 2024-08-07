class UpdateAvailabilityJob < ApplicationJob
  queue_as :default

  def perform
    connected_vrentals = Vrental.with_valid_prop_key

    connected_vrentals.each do |vrental|
      begin
        VrentalApiService.new(vrental).get_availabilities_from_beds_24
      rescue StandardError => e
        Rails.logger.error "Error processing Vrental #{vrental.id}: #{e.message}"
      ensure
        sleep 3
      end
    end
  end
end

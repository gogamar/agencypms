class UpdateAvailabilityJob < ApplicationJob
  queue_as :default

  def perform
    @connected_vrentals = Vrental.with_valid_prop_key
    @connected_vrentals.each do |vrental|
      VrentalApiService.new(vrental).get_availabilities_from_beds_24
    end
  end
end

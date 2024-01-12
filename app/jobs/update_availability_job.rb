class UpdateAvailabilityJob < ApplicationJob
  queue_as :default

  def perform
    @connected_vrentals = Vrental.where.not(prop_key: nil)
    @connected_vrentals.each do |vrental|
      VrentalApiService.new(vrental).get_availabilities_from_beds_24
    end
  end
end

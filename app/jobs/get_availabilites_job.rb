class GetAvailabilitesJob < ApplicationJob
  queue_as :default

  def perform(vrental_id)
    vrental = Vrental.find(vrental_id)
    VrentalApiService.new(vrental).get_availabilities_from_beds_24
  end
end

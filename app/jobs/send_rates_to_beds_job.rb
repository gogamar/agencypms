class SendRatesToBedsJob < ApplicationJob
  queue_as :default

  def perform(vrental_id)
    vrental = Vrental.find(vrental_id)
    VrentalApiService.new(vrental).send_rates_to_beds
    if vrental.control_restrictions == "calendar_beds24"
      VrentalApiService.new(vrental).send_availabilities_to_beds_24
    end
  end
end

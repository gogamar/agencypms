class SendRatesToBedsJob < ApplicationJob
  queue_as :default

  def perform(vrental_id)
    vrental = Vrental.find(vrental_id)
    VrentalApiService.new(vrental).send_rates_to_beds
    VrentalApiService.new(vrental).update_min_stay_on_beds
    VrentalApiService.new(vrental).send_availabilities_to_beds_24
    VrentalApiService.new(vrental).get_availabilities_from_beds_24
  end
end

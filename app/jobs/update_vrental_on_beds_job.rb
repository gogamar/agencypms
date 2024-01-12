class UpdateVrentalOnBedsJob < ApplicationJob
  queue_as :default

  def perform(vrental_id)
    vrental = Vrental.find(vrental_id)
    VrentalApiService.new(vrental).update_vrental_on_beds
  end
end

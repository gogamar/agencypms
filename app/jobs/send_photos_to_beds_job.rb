class SendPhotosToBedsJob < ApplicationJob
  queue_as :default

  def perform(vrental_id)
    vrental = Vrental.find(vrental_id)
    VrentalApiService.new(vrental).send_photos_to_beds
  end
end

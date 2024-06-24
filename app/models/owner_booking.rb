class OwnerBooking < ApplicationRecord
  belongs_to :vrental
  validate :no_overlapping
  validates :checkin, :checkout, :vrental, presence: true
  validates :checkout, comparison: { greater_than: :checkin }
  # validate :checkin_and_checkout_not_in_past
  # after_create :perform_api_calls
  # after_update :perform_api_calls


  private

  def checkin_and_checkout_not_in_past
    if checkin.present? && checkin < Date.today
      errors.add(:checkin, I18n.t('cant_be_in_past'))
    end

    if checkout.present? && checkout < Date.today
      errors.add(:checkout, I18n.t('cant_be_in_past'))
    end
  end

  def no_overlapping
    return unless checkin && checkout && vrental_id

    overlapping_bookings = vrental.bookings.where.not(status: "0").where(
      "((checkin <= ? AND checkout > ?) OR
        (checkin >= ? AND checkout <= ?) OR
        (checkin < ? AND checkout > ?))",
      checkin, checkin, checkin, checkout, checkout, checkout
    )

    overlapping_owner_bookings = vrental.owner_bookings.where.not(id: id).where.not(status: "0").where(
      "((checkin <= ? AND checkout > ?) OR
      (checkin >= ? AND checkout <= ?) OR
      (checkin < ? AND checkout > ?))",
    checkin, checkin, checkin, checkout, checkout, checkout
    )

    if overlapping_bookings.any? || overlapping_owner_bookings.any?
      errors.add(:base, I18n.t('booking_dates_overlap'))
    end
  end

  def perform_api_calls
    VrentalApiService.new(self.vrental).get_bookings_from_beds(Date.today)
    VrentalApiService.new(self.vrental).send_owner_booking(self)
  end
end

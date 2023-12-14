class Booking < ApplicationRecord
  belongs_to :vrental
  belongs_to :tourist, optional: true
  has_many :charges, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_one :earning, dependent: :destroy
  accepts_nested_attributes_for :charges, allow_destroy: true
  validates :checkin, presence: true
  validates :checkout, presence: true
  validate :checkout_is_later_than_checkin
  validates :beds_booking_id, uniqueness: true, allow_nil: true

  STATUS = {
    "O" => "cancelled",
    "1" => "confirmed",
    "2" => "new"
  }

  def has_overbooking?
    return false if overlapping_bookings.empty?

    overlapping_bookings.any? do |overlapping_booking|
      overlapping_booking.checkout > checkin
    end
  end

  def overlapping_bookings
    if vrental_id && checkin && checkout

      overlapping_bookings = vrental.bookings.where.not(id: id).where.not(status: "0").where(
        "((checkin <= ? AND checkout > ?) OR
          (checkin >= ? AND checkout <= ?) OR
          (checkin < ? AND checkout > ?))",
        checkin, checkin, checkin, checkout, checkout, checkout
      )
    end
  end

  def price_with_portal
    charges.where(charge_type: "rent").sum(:price).round(2) || 0
  end

  def price_portal_no_commission
    price_with_portal - (price_with_portal * 0.15).round(2)
  end

  def price_no_portal
    price_with_portal - commission
  end

  def net_price
    if referrer == "sistach_rentals" || referrer == "sistachrentals_web" || referrer == "direct" || referrer == "miquel"
      price_no_portal.round(2)
    else
      [price_portal_no_commission, price_no_portal].min.round(2)
    end
  end

  def city_tax_value
    charges.where(charge_type: "city_tax")&.sum(:price)
  end

  def cleaning_value
    charges.where(charge_type: "cleaning")&.sum(:price)
  end

  def other_charges
    charges.where(charge_type: "other")&.sum(:price)
  end

  private

  def checkout_is_later_than_checkin
    if checkin && checkout && checkin >= checkout
      errors.add(:checkout, "must be later than checkin")
    end
  end
end

class Rate < ApplicationRecord
  belongs_to :vrental
  validates :firstnight, presence: true
  validates :lastnight, presence: true
  validates :lastnight, comparison: { greater_than: :firstnight }
  validates :firstnight, uniqueness: { scope: :vrental_id, message: 'Aquesta tarifa ja existeix.' }
  validates :lastnight, uniqueness: { scope: :vrental_id, message: 'Aquesta tarifa ja existeix.' }
  validates :min_stay, presence: true
  validates :arrival_day, presence: true
  validates :priceweek, presence: true, if: ->(rate) { rate.vrental.price_per == 'week' }
  validates :pricenight, presence: true, if: ->(rate) { rate.vrental.price_per == 'night' }

  after_create :create_nightly_rate, if: ->(rate) { rate.vrental.price_per == 'week' }

  def nightly_price_based_on_week
    decimal_discount = vrental.weekly_discount / 100 if vrental.weekly_discount.present?
    discount_rate = vrental.weekly_discount_included ? (1 - decimal_discount) : decimal_discount
    weekly_room_price = vrental.weekly_discount.present? ? priceweek / discount_rate : priceweek
    vrental.weekly_discount_included ? weekly_room_price / 7 : priceweek / 7
  end

  private

  def create_nightly_rate
    nightly_rate = Rate.new(
      firstnight: self.firstnight,
      lastnight: self.lastnight,
      beds_room_id: self.beds_room_id,
      arrival_day: self.arrival_day,
      min_stay: self.vrental.min_stay,
      vrental_id: self.vrental_id,
      pricenight: self.nightly_price_based_on_week
    )
    nightly_rate.save
  end
end

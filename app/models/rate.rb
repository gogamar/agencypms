class Rate < ApplicationRecord
  belongs_to :vrental
  validates :firstnight, :lastnight, :min_stay, :max_stay, :arrival_day, presence: true
  validates :lastnight, comparison: { greater_than: :firstnight }
  validate :check_uniqueness

  RESTRICTION = ['normal', 'gap_fill'].freeze

  def nightly_price_based_on_week
    decimal_discount = vrental.weekly_discount / 100 if vrental.weekly_discount.present?
    discount_rate = vrental.weekly_discount_included ? (1 - decimal_discount) : decimal_discount
    weekly_room_price = vrental.weekly_discount.present? ? priceweek / discount_rate : priceweek
    nightly_price = vrental.weekly_discount_included ? weekly_room_price / 7 : priceweek / 7
    nightly_price.round(2)
  end

  def create_nightly_rate
    existing_nightly_rate = vrental.rates.find_by(
      firstnight: self.firstnight,
      pricenight: self.nightly_price_based_on_week
    )

    if existing_nightly_rate
      existing_nightly_rate.update_attributes(
        arrival_day: self.arrival_day,
        min_stay: self.min_stay,
        pricenight: self.nightly_price_based_on_week
      )
    else
      Rate.create(
        vrental_id: self.vrental_id,
        beds_room_id: self.beds_room_id,
        firstnight: self.firstnight,
        lastnight: self.lastnight,
        arrival_day: self.arrival_day,
        min_stay: self.min_stay,
        pricenight: self.nightly_price_based_on_week
      )
    end
  end

  def delete_nightly_rate
    nightly_rate = vrental.rates.find_by(
      firstnight: self.firstnight,
      pricenight: self.nightly_price_based_on_week
    )
    nightly_rate&.destroy!
  end

  private

  def check_uniqueness
    existing_records =
      if self.priceweek.present?
        vrental.rates.where(
          'firstnight = ? AND priceweek = ? AND restriction = ?',
          self.firstnight, self.priceweek, self.restriction
        )
      elsif self.pricenight.present?
        vrental.rates.where(
          'firstnight = ? AND pricenight = ? AND restriction = ?',
          self.firstnight, self.pricenight, self.restriction
        )
      end

    existing_records = existing_records.where.not(id: self.id) if self.persisted?

    if existing_records.exists?
      errors.add(:base, 'A record with the same combination of firstnight, restriction and pricenight or priceweek already exists.')
    end
  end
end

class Rate < ApplicationRecord
  belongs_to :vrental
  validates :firstnight, :lastnight, presence: true
  validates :lastnight, comparison: { greater_than: :firstnight }
  # validate :check_uniqueness
  before_save :calculate_pricenight, if: -> { priceweek.present? }


  RESTRICTION = ['normal', 'gap_fill', 'short_stay'].freeze
  ARRIVAL_DAY = {
    7 => 'everyday',
    1 => 'monday',
    2 => 'tuesday',
    3 => 'wednesday',
    4 => 'thursday',
    5 => 'friday',
    6 => 'saturday',
    0 => 'sunday'
  }

  def calculate_pricenight
    decimal_discount = vrental.weekly_discount / 100 if vrental.weekly_discount.present?
    discount_rate = 1 - decimal_discount if decimal_discount.present?
    weekly_room_price = vrental.weekly_discount.present? ? priceweek / discount_rate : priceweek
    nightly_price = weekly_room_price / 7
    self.pricenight = nightly_price.round(2)
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

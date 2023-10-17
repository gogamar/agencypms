class Charge < ApplicationRecord
  belongs_to :booking

  CHARGE_TYPES = %w(rent cleaning city_tax other)
end

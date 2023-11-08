class Coupon < ApplicationRecord
  belongs_to :office
  has_and_belongs_to_many :vrentals
  validates :name, uniqueness: true

  DISCOUNT_TYPES = %w[percent fixed_amount].freeze
end

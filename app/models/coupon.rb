class Coupon < ApplicationRecord
  belongs_to :office
  has_and_belongs_to_many :vrentals
  validates :name, uniqueness: true

  DISCOUNT_TYPES = %w[percent fixed_amount].freeze

  def amount_discounted(full_price)
    if discount_type == "percent"
      amount_discounted = (amount/100) * full_price.to_f
    elsif discount_type == "fixed_amount"
      amount_discounted = amount
    end
    return amount_discounted
  end

end

class Booking < ApplicationRecord
  belongs_to :vrental
  belongs_to :tourist, optional: true
  has_many :charges, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_one :earning, dependent: :destroy
  accepts_nested_attributes_for :charges, allow_destroy: true

  def price_with_portal
    charges.where(charge_type: "rent")&.sum(:price)
  end

  def price_portal_no_commission
    price_with_portal - (price_with_portal * 0.15)
  end

  def price_no_portal
    price_with_portal - commission
  end

  def net_price
    unless referrer == "sistach_rentals" || "sistachrentals_web" || "direct" || "miquel"
      price_portal_no_commission
    else
      price_no_portal
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

  # @bookings = Booking.all.order('checkin ASC')
  # @rentalswithhighcom = Rental.joins(:bookings).where('compercent > ?', 15.5).uniq.sort_by(&:name)
  # @pricecontractsum = Booking.where(status: [1,2]).sum(:rateprice) - Booking.where("client ilike '%prop%'").sum(:rateprice)
  # @pricebookingsum = Booking.where(status: [1,2] ).sum(:price)
  # @commissionsum = Booking.where(status: [1,2] ).sum(:commission)
  # @netrevenue = @pricebookingsum - @commissionsum
  # @bookingsnochnopay = Booking.where.missing(:charges).where.not("client ILIKE ?", "%CONTR%").where.not("client ILIKE ?", "%PROP%")
end

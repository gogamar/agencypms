class Booking < ApplicationRecord
  belongs_to :vrental
  belongs_to :tourist, optional: true
  has_many :charges, dependent: :destroy
  has_many :payments, dependent: :destroy
  accepts_nested_attributes_for :charges, allow_destroy: true

  # @bookings = Booking.all.order('checkin ASC')
  # @rentalswithhighcom = Rental.joins(:bookings).where('compercent > ?', 15.5).uniq.sort_by(&:name)
  # @pricecontractsum = Booking.where(status: [1,2]).sum(:rateprice) - Booking.where("client ilike '%prop%'").sum(:rateprice)
  # @pricebookingsum = Booking.where(status: [1,2] ).sum(:price)
  # @commissionsum = Booking.where(status: [1,2] ).sum(:commission)
  # @netrevenue = @pricebookingsum - @commissionsum
  # @bookingsnochnopay = Booking.where.missing(:charges).where.not("client ILIKE ?", "%CONTR%").where.not("client ILIKE ?", "%PROP%")
end

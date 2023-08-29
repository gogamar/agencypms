class Statement < ApplicationRecord
  belongs_to :vrental
  belongs_to :invoice, optional: true
  has_many :expenses
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true

  def total_rent_charges
    statement_bookings = vrental.bookings.where(checkin: start_date..end_date)
    total_rent = statement_bookings.sum do |booking|
      booking.charges.where(charge_type: 'rent').sum(:price)
    end
    return total_rent
  end

  def agency_commission
    vrental.commission * total_rent_charges
  end

  def agency_commission_vat
    agency_commission * 0.21
  end

end

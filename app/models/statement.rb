class Statement < ApplicationRecord
  belongs_to :vrental
  validate :no_overlapping_statements
  validates :start_date, :end_date, :date, :location, presence: true
  belongs_to :invoice, optional: true
  has_many :expenses, dependent: :nullify
  has_many :earnings, dependent: :nullify
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :earnings, reject_if: :all_blank, allow_destroy: true

  def statement_bookings
    vrental.bookings.where(checkin: start_date..end_date)
  end

  def statement_earnings
    vrental.earnings.where(date: start_date..end_date).order(:date)
  end

  def total_statement_earnings
    statement_earnings.sum(:amount)
  end

  def agency_commission
    total_statement_earnings * (vrental.commission || 1)
  end

  def agency_commission_vat
    agency_commission * 0.21
  end

  def total_expenses
    expenses.sum(:amount)
  end

  def net_income_owner
    total_statement_earnings - agency_commission - agency_commission_vat - total_expenses
  end

  private

  def no_overlapping_statements
    overlapping_statements = vrental.statements.where.not(id: id).where(
      '(start_date <= ? AND end_date >= ?) OR (start_date >= ? AND start_date <= ?)',
      end_date, start_date, start_date, end_date
    )

    errors.add(:base, 'Ja existeix una liquidació per aquest periode o part d\'aquest periode') if overlapping_statements.any?
  end

end

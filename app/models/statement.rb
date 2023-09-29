class Statement < ApplicationRecord
  belongs_to :vrental
  validate :no_overlapping_statements
  validates :start_date, :end_date, :date, :location, presence: true
  belongs_to :invoice, optional: true
  has_many :expenses, dependent: :nullify
  has_many :earnings, dependent: :nullify
  has_many :vrowner_payments, dependent: :destroy
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :earnings, reject_if: :all_blank, allow_destroy: true
  validate :start_and_end_dates_within_same_year

  def start_and_end_dates_within_same_year
    if start_date.present? && end_date.present? && start_date.year != end_date.year
      errors.add(:end_date, ": la data final ha de ser al mateix any com la data inici")
    end
  end

  def statement_bookings
    vrental.bookings.where(checkin: start_date..end_date)
  end

  def statement_earnings
    vrental.earnings.where(date: start_date..end_date).order(:date)
  end

  def confirmed_statement_earnings
    statement_earnings.where.not(amount: 0)
  end

  def total_statement_earnings
    earnings.sum(:amount)
  end

  def agency_commission
    total_statement_earnings * (vrental.commission || 0)
  end

  def agency_commission_vat
    agency_commission * 0.21
  end

  def agency_commission_vat_total
    agency_commission + agency_commission_vat
  end

  def total_expenses
    expenses.pluck(:amount)&.sum
  end

  def total_vrowner_payments
    vrowner_payments.pluck(:amount)&.sum
  end

  def total_expenses_owner
    expenses.where(expense_type: 'owner').pluck(:amount)&.sum
  end

  def net_income_owner
    (total_statement_earnings - agency_commission - agency_commission_vat - total_expenses_owner).round(2)
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

class Invoice < ApplicationRecord
  belongs_to :vrental
  belongs_to :company
  has_many :statements
  validates :date, presence: true
  validates :number, uniqueness: true
  validate :at_least_one_statement_with_positive_earnings

  before_create :generate_invoice_number
  before_create :set_invoice_date

  def invoice_number_formatted
    if number < 10
      formatted_number = "000#{number}"
    elsif number < 100
      formatted_number = "00#{number}"
    else
      formatted_number = "0#{number}"
    end
    "52#{formatted_number}"
  end

  def year
    date.year
  end

  def total_earnings
    total = 0
    statements.each do |statement|
      total += statement.total_statement_earnings
    end
    total
  end

  def agency_commission_total
    statements&.sum { |statement| statement.agency_commission }&.round(2) || 0.0
  end

  def agency_vat_total
    (agency_commission_total * 0.21).round(2)
  end

  def agency_total
    agency_commission_total + agency_vat_total
  end

  def total_net_owner
    total_earnings - agency_total
  end

  private

  def generate_invoice_number
    current_year = Date.current.year
    last_invoice = Invoice.where("extract(year from created_at) = ?", current_year).order(number: :desc).first

    if last_invoice
      if last_invoice.created_at.year == current_year
        self.number = last_invoice.number + 1
      else
        self.number = 1
      end
    else
      self.number = 1
    end
  end

  def set_invoice_date
    self.date = Date.current
  end

  def at_least_one_statement_with_positive_earnings
    unless statements.any? { |statement| statement.earnings.any? { |earning| earning.amount > 0 } }
      errors.add(:base, I18n.t('invoice_zero_amount_error'))
    end
  end
end

class VrownerPayment < ApplicationRecord
  belongs_to :statement
  validates :statement_id, uniqueness: true
  validates :amount, :date, presence: true
  validate :amount_cannot_be_zero


  PAYMENT_METHODS = %w(transfer check cash).freeze

  private

  def amount_cannot_be_zero
    if amount.present? && amount.zero?
      errors.add(:amount, "no pot ser zero")
    end
  end
end

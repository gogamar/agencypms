class VrownerPayment < ApplicationRecord
  belongs_to :vrowner
  belongs_to :statement
  validates :statement_id, uniqueness: true

  PAYMENT_METHODS = %w(transfer check cash).freeze
end

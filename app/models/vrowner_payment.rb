class VrownerPayment < ApplicationRecord
  belongs_to :vrowner
  belongs_to :statement, optional: true

  PAYMENT_METHODS = %w(transfer check cash).freeze
end

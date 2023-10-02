class Expense < ApplicationRecord
  belongs_to :vrental, optional: false
  belongs_to :statement, optional: true
  validates :amount, presence: true
  validates :expense_type, presence: true, inclusion: { in: %w(agency owner) }

  EXPENSE_TYPES = %w(agency owner).freeze
end

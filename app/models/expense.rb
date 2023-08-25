class Expense < ApplicationRecord
  belongs_to :vrental, optional: false
  belongs_to :statement, optional: true

  EXPENSE_TYPES = %w(agency owner).freeze

end

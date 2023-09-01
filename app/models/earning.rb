class Earning < ApplicationRecord
  belongs_to :vrental
  belongs_to :statement, optional: true
  belongs_to :booking, optional: true
end

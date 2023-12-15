class Bathroom < ApplicationRecord
  belongs_to :vrental

  BATHROOM_TYPES = ["BATH_SHOWER", "BATH_TUB"]
end

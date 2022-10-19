class Owner < ApplicationRecord
  has_many :rentals
  has_many :agreements, through: :rentals
end

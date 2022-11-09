class Renter < ApplicationRecord
  belongs_to :user
  has_many :agreements
end

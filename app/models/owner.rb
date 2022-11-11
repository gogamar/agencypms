class Owner < ApplicationRecord
  belongs_to :user
  has_many :rentals
  has_many :agreements, through: :rentals
  validates :fullname, presence: true
end

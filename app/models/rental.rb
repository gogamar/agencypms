class Rental < ApplicationRecord
  belongs_to :owner
  has_many :agreements
  validates :address, presence: true
  validates :city, presence: true
  validates :owner, presence: true
end

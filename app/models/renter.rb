class Renter < ApplicationRecord
  belongs_to :user
  has_many :agreements
  validates :fullname, presence: true
end

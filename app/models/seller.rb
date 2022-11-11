class Seller < ApplicationRecord
  belongs_to :user
  has_many :realestates
  has_many :contracts, through: :realestates
  validates :fullname, presence: true
end

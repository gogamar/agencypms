class Buyer < ApplicationRecord
  belongs_to :user
  has_many :contracts
  validates :fullname, presence: true
end

class Realestate < ApplicationRecord
  belongs_to :user
  belongs_to :seller, optional: true
  has_many :contracts, dependent: :destroy
  validates :address, presence: true
  validates :city, presence: true
  validates :status, presence: true
end

class Rental < ApplicationRecord
  belongs_to :user
  belongs_to :owner, optional: true
  has_many :agreements, dependent: :destroy
  validates :address, presence: true
  validates :city, presence: true
  validates :status, presence: true
end

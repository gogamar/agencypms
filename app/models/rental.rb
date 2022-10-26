class Rental < ApplicationRecord
  belongs_to :user
  belongs_to :owner
  has_many :agreements, dependent: :destroy
  validates :address, presence: true
  validates :city, presence: true
  validates :owner, presence: true
end

class Vrental < ApplicationRecord
  belongs_to :user
  belongs_to :vrowner, optional: true
  has_many :vragreements, dependent: :destroy
  has_many :rates, dependent: :destroy
  has_many :features, dependent: :destroy
  validates :name, presence: true
  validates :status, presence: true
  validates :name, uniqueness: true
end

class Vrental < ApplicationRecord
  belongs_to :user
  belongs_to :vrowner, optional: true
  has_many :vragreements, dependent: :destroy
  has_many :rates, dependent: :destroy
  has_and_belongs_to_many :features
  validates :name, presence: true
  validates :status, presence: true
  validates :name, uniqueness: true
end

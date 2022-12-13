class Feature < ApplicationRecord
  has_and_belongs_to_many :vrentals
  belongs_to :user
  validates :name, uniqueness: true
end

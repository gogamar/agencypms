class Vrowner < ApplicationRecord
  belongs_to :user
  has_many :vrentals
  has_many :vragreements, through: :vrentals
end

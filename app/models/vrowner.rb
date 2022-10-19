class Vrowner < ApplicationRecord
  has_many :vrentals
  has_many :vragreements, through: :vrentals
end

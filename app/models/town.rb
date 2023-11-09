class Town < ApplicationRecord
  has_many :vrentals
  has_many_attached :photos
  belongs_to :region, optional: true
end

class Region < ApplicationRecord
  has_many :towns
  has_many_attached :photos
end
